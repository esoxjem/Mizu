"""Build and refresh the local Mizu Dev installation."""

import os
from pathlib import Path
import plistlib
import signal
import subprocess
import time


def main():
    root = Path(__file__).resolve().parents[1]
    built = root / "build/dev/Build/Products/Debug/Mizu Dev.app"
    installed = Path.home() / "Applications/Mizu Dev.app"

    subprocess.run([
        "xcodebuild", "-project", str(root / "Mizu.xcodeproj"),
        "-scheme", "Mizu", "-configuration", "Debug",
        "-derivedDataPath", str(root / "build/dev"), "build",
    ], check=True)
    info = plistlib.loads((built / "Contents/Info.plist").read_bytes())
    if info.get("CFBundleIdentifier") != "com.esoxjem.mizu.dev":
        raise RuntimeError("Build is not the Mizu development bundle")
    subprocess.run(["codesign", "--verify", "--deep", "--strict", str(built)], check=True)
    if installed.exists():
        existing = plistlib.loads((installed / "Contents/Info.plist").read_bytes())
        if existing.get("CFBundleIdentifier") != "com.esoxjem.mizu.dev":
            raise RuntimeError("Installed app is not the Mizu development bundle")

    for line in subprocess.check_output(["ps", "-axo", "pid=,comm="], text=True).splitlines():
        fields = line.strip().split(None, 1)
        if len(fields) != 2 or not fields[1].endswith("/Contents/MacOS/Mizu Dev"):
            continue
        running_app = Path(fields[1]).parents[2]
        running_info = plistlib.loads((running_app / "Contents/Info.plist").read_bytes())
        if running_info.get("CFBundleIdentifier") != "com.esoxjem.mizu.dev":
            continue
        pid = int(fields[0])
        try:
            os.kill(pid, signal.SIGTERM)
        except ProcessLookupError:
            continue
        for _ in range(40):
            try:
                os.kill(pid, 0)
            except ProcessLookupError:
                break
            time.sleep(0.05)
        else:
            raise RuntimeError("Mizu Dev did not exit; installation left untouched")

    installed.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(["ditto", str(built), str(installed)], check=True)
    installed_info = plistlib.loads((installed / "Contents/Info.plist").read_bytes())
    if installed_info != info:
        raise RuntimeError("Installed Mizu Dev metadata differs from the new build")
    subprocess.run(["open", str(installed)], check=True)
    print(f"Refreshed Mizu Dev v{info['CFBundleShortVersionString']} (build {info['CFBundleVersion']})")


if __name__ == "__main__":
    main()
