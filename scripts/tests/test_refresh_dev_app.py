import os
from pathlib import Path
import plistlib
import shutil
import signal
import subprocess
import tempfile
import unittest
from unittest.mock import patch

from scripts import refresh_dev_app


class RefreshDevAppTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.home = self.root / "home"
        self.built = self.root / "build/dev/Build/Products/Debug/Mizu Dev.app"
        self.installed = self.home / "Applications/Mizu Dev.app"
        self.production = self.home / "Applications/Mizu.app"
        self.write_info(self.built, "com.esoxjem.mizu.dev", "2.5.1", "10")
        self.write_info(self.installed, "com.esoxjem.mizu.dev", "2.5.0", "9")
        self.write_info(self.production, "com.esoxjem.mizu", "2.5.0", "9")
        self.original_production = (self.production / "Contents/Info.plist").read_bytes()
        self.commands = []
        self.signals = []
        self.addCleanup(patch.stopall)
        patch.object(refresh_dev_app, "__file__", str(self.root / "scripts/refresh_dev_app.py")).start()
        patch.object(Path, "home", return_value=self.home).start()
        patch.object(subprocess, "run", side_effect=self.run_command).start()
        patch.object(subprocess, "check_output", return_value=(
            f"101 {self.installed}/Contents/MacOS/Mizu Dev\n"
            f"202 {self.production}/Contents/MacOS/Mizu\n"
        )).start()
        patch.object(os, "kill", side_effect=self.send_signal).start()

    @staticmethod
    def write_info(app, identifier, version, build):
        (app / "Contents").mkdir(parents=True, exist_ok=True)
        (app / "Contents/Info.plist").write_bytes(plistlib.dumps({
            "CFBundleIdentifier": identifier,
            "CFBundleShortVersionString": version,
            "CFBundleVersion": build,
        }))

    def run_command(self, command, **kwargs):
        self.commands.append(command)
        if command[0] == "ditto":
            shutil.copytree(command[1], command[2], dirs_exist_ok=True)
        return subprocess.CompletedProcess(command, 0)

    def send_signal(self, pid, sig):
        self.signals.append((pid, sig))
        if sig == 0:
            raise ProcessLookupError

    def test_refreshes_dev_from_current_build_without_touching_production(self):
        refresh_dev_app.main()

        installed = plistlib.loads((self.installed / "Contents/Info.plist").read_bytes())
        self.assertEqual(installed["CFBundleShortVersionString"], "2.5.1")
        self.assertEqual(installed["CFBundleVersion"], "10")
        self.assertEqual((self.production / "Contents/Info.plist").read_bytes(), self.original_production)
        self.assertEqual(self.signals, [(101, signal.SIGTERM), (101, 0)])
        self.assertEqual(self.commands[0][0], "xcodebuild")
        self.assertIn("Debug", self.commands[0])
        self.assertEqual(self.commands[-1], ["open", str(self.installed)])

    def test_rejects_production_build_before_stopping_or_replacing_dev(self):
        self.write_info(self.built, "com.esoxjem.mizu", "2.5.1", "10")
        original = (self.installed / "Contents/Info.plist").read_bytes()

        with self.assertRaisesRegex(RuntimeError, "development bundle"):
            refresh_dev_app.main()

        self.assertEqual((self.installed / "Contents/Info.plist").read_bytes(), original)
        self.assertEqual(self.signals, [])

    def test_refreshes_dev_running_from_the_build_folder(self):
        processes = (
            f"101 {self.installed}/Contents/MacOS/Mizu Dev\n"
            f"202 {self.production}/Contents/MacOS/Mizu\n"
            f"303 {self.built}/Contents/MacOS/Mizu Dev\n"
        )
        with patch.object(subprocess, "check_output", return_value=processes):
            refresh_dev_app.main()

        self.assertEqual(self.signals, [
            (101, signal.SIGTERM), (101, 0),
            (303, signal.SIGTERM), (303, 0),
        ])
        self.assertEqual(self.commands[-1], ["open", str(self.installed)])

    def test_rejects_production_app_renamed_to_dev(self):
        self.write_info(self.installed, "com.esoxjem.mizu", "2.5.0", "9")
        original = (self.installed / "Contents/Info.plist").read_bytes()

        with self.assertRaisesRegex(RuntimeError, "development bundle"):
            refresh_dev_app.main()

        self.assertEqual((self.installed / "Contents/Info.plist").read_bytes(), original)
        self.assertEqual(self.signals, [])

    def test_build_or_signing_failure_preserves_existing_installation(self):
        original = (self.installed / "Contents/Info.plist").read_bytes()
        for failing_tool in ("xcodebuild", "codesign"):
            with self.subTest(tool=failing_tool):
                def run(command, **kwargs):
                    if command[0] == failing_tool:
                        raise subprocess.CalledProcessError(1, command)
                    return self.run_command(command, **kwargs)

                with patch.object(subprocess, "run", side_effect=run):
                    with self.assertRaises(subprocess.CalledProcessError):
                        refresh_dev_app.main()

                self.assertEqual((self.installed / "Contents/Info.plist").read_bytes(), original)
                self.assertEqual(self.signals, [])


if __name__ == "__main__":
    unittest.main()
