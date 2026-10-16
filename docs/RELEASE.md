# Release Process

Mizu is released locally as a Developer ID signed, notarized app. GitHub Releases
hosts both `Mizu.zip` and `Mizu.dmg`; Sparkle downloads the DMG referenced by
`appcast.xml` on `main`. This workflow was verified for v2.5.1 (build 10).

Run commands from the repository root, in order. Replace the version placeholder
and use a fresh release directory; retain it until publication is verified.

## 1. Check prerequisites and prepare the version

Required: Xcode, GitHub CLI authenticated for `esoxjem/Mizu`, a Developer ID
Application certificate with its private key in Keychain, and notarization
credentials saved under the `notarytool` Keychain profile.

```bash
git status --short
git fetch origin
gh auth status
security find-identity -v -p codesigning
xcrun notarytool history --keychain-profile notarytool

version="<new-version>"
release_dir="$PWD/build/release-v$version"
mkdir -p "$release_dir"
```

Confirm `main` is up to date with `origin/main`. Inspect any local changes and
keep unrelated files out of release commits. Update `MARKETING_VERSION` and
increment `CURRENT_PROJECT_VERSION` in both app configurations in
`Mizu.xcodeproj/project.pbxproj`.

Locate the tools from the project's resolved Sparkle package and set
`sparkle_bin` to the directory containing `sign_update` and `generate_keys`:

```bash
rg --files --hidden --no-ignore "$HOME/Library/Developer/Xcode/DerivedData" -g sign_update
sparkle_bin="<resolved-Sparkle-bin-directory>"
"$sparkle_bin/generate_keys" -p
/usr/libexec/PlistBuddy -c 'Print :SUPublicEDKey' Mizu/Info.plist
```

The existing Keychain public key must match `SUPublicEDKey`. Use the same
Keychain account for both tools if the app uses a custom account. Do not generate
replacement keys as a routine release step; see [key rotation](#sparkle-key-rotation)
if the key is missing or differs.

Run the tests, then commit the version change and any other reviewed release
changes using conventional commit messages. Stage only the intended paths.

```bash
xcodebuild -project Mizu.xcodeproj -scheme Mizu -configuration Debug \
  -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO test
git add Mizu.xcodeproj/project.pbxproj
git commit -m "chore: prepare Mizu $version release"
git push origin main
```

## 2. Archive and export

Build from the committed source so unrelated working files cannot enter the app:

```bash
git rev-parse HEAD > "$release_dir/source-commit.txt"
git archive --format=tar --output="$release_dir/source.tar" HEAD
mkdir -p "$release_dir/source"
tar -xf "$release_dir/source.tar" -C "$release_dir/source"

xcodebuild -project "$release_dir/source/Mizu.xcodeproj" -scheme Mizu \
  -configuration Release -destination 'generic/platform=macOS' \
  -archivePath "$release_dir/Mizu.xcarchive" archive

cp exopt.plist "$release_dir/export-options.plist"
/usr/libexec/PlistBuddy -c 'Add :teamID string QTZUF46V7A' "$release_dir/export-options.plist"
xcodebuild -exportArchive -archivePath "$release_dir/Mizu.xcarchive" \
  -exportPath "$release_dir/export" \
  -exportOptionsPlist "$release_dir/export-options.plist"

app="$release_dir/export/Mizu.app"
codesign --verify --deep --strict --verbose=2 "$app"
codesign -dvvv "$app"
lipo -archs "$app/Contents/MacOS/Mizu"
/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Print :SUPublicEDKey' "$app/Contents/Info.plist"
```

Keep the project's automatic signing settings during archive. Passing a manual
Developer ID identity to this archive conflicts with those settings. The
`developer-id` export signs the app, Sparkle framework, and helpers for distribution.
Check the exported app for Developer ID Application signing, team `QTZUF46V7A`,
a secure timestamp, hardened runtime, both `arm64` and `x86_64`, and the intended
version, build, and Sparkle public key.

## 3. Notarize the app and create the final ZIP

```bash
ditto -c -k --keepParent "$app" "$release_dir/Mizu-notarize.zip"
xcrun notarytool submit "$release_dir/Mizu-notarize.zip" \
  --keychain-profile notarytool --wait
xcrun stapler staple "$app"
xcrun stapler validate "$app"
spctl --assess --type execute --verbose=2 "$app"
ditto -c -k --keepParent "$app" "$release_dir/Mizu.zip"
```

Continue only after notarization reports `Accepted`. Record the submission ID;
if interrupted, check it with `xcrun notarytool info <submission-id>
--keychain-profile notarytool`. The final ZIP must contain the stapled app.

## 4. Create, sign, and notarize the DMG

Use the same stapled app and include an Applications shortcut:

```bash
mkdir -p "$release_dir/dmg-root"
ditto "$app" "$release_dir/dmg-root/Mizu.app"
ln -s /Applications "$release_dir/dmg-root/Applications"
hdiutil create -volname Mizu -srcfolder "$release_dir/dmg-root" \
  -ov -format UDZO "$release_dir/Mizu.dmg"
codesign --sign "Developer ID Application: Arun Sasidharan (QTZUF46V7A)" \
  --timestamp "$release_dir/Mizu.dmg"
xcrun notarytool submit "$release_dir/Mizu.dmg" \
  --keychain-profile notarytool --wait
xcrun stapler staple "$release_dir/Mizu.dmg"
xcrun stapler validate "$release_dir/Mizu.dmg"
spctl --assess --type open --context context:primary-signature \
  --verbose=2 "$release_dir/Mizu.dmg"
```

Again, require `Accepted` and record the submission ID. Both the app and the DMG
need successful validation before proceeding.

## 5. Sign the final artifacts and prepare the feed

Sparkle signatures cover the final file bytes. Sign after all stapling and do
not modify either artifact afterward. These tools read the private key directly
from Keychain; exporting it is unnecessary.

```bash
"$sparkle_bin/sign_update" -p "$release_dir/Mizu.zip" > "$release_dir/Mizu.zip.signature"
"$sparkle_bin/sign_update" -p "$release_dir/Mizu.dmg" > "$release_dir/Mizu.dmg.signature"
"$sparkle_bin/sign_update" --verify "$release_dir/Mizu.dmg" "$(cat "$release_dir/Mizu.dmg.signature")"
stat -f%z "$release_dir/Mizu.dmg"
shasum -a 256 "$release_dir/Mizu.zip" "$release_dir/Mizu.dmg"
date -R
```

Update the item in `appcast.xml` with:

- The new title and `sparkle:shortVersionString` (marketing version).
- `sparkle:version` (the incremented build number).
- `pubDate` from `date -R` and the actual minimum supported macOS version.
- Enclosure URL `https://github.com/esoxjem/Mizu/releases/download/v<version>/Mizu.dmg`.
- Enclosure `length` and `sparkle:edSignature` from this exact DMG.

Write concise, user-facing release notes to `$release_dir/release-notes.md`.
Commit the feed locally and tag that commit, leaving the live feed unchanged
until the downloads are public:

```bash
git diff --check
git add appcast.xml
git commit -m "chore: update Sparkle feed for v$version"
git tag -a "v$version" -m "Release v$version"
git push origin "refs/tags/v$version"
gh release create "v$version" "$release_dir/Mizu.zip" "$release_dir/Mizu.dmg" \
  --verify-tag --draft --title "v$version" \
  --notes-file "$release_dir/release-notes.md"
```

## 6. Publish and verify

Inspect the draft notes and assets. Download both draft assets with
`gh release download` into a separate directory and compare their SHA-256 hashes
with the local artifacts. Then publish the release and confirm it is public:

```bash
gh release edit "v$version" --draft=false --latest
gh release view "v$version" --json isDraft,url,assets
```

Download both assets anonymously from the public release URLs and compare their
hashes again. Once the public downloads are verified, activate the feed:

```bash
git push origin main
git ls-remote origin refs/heads/main "refs/tags/v$version" "refs/tags/v$version^{}"
```

Verify the remote `main` and peeled tag match the local release commit. Fetch
the canonical feed at
`https://raw.githubusercontent.com/esoxjem/Mizu/main/appcast.xml`, confirm its
version, build, URL, size, and signature match the release, and confirm GitHub
marks the intended release as latest. A cache-busting query can help diagnose
a stale response.

Retain the source/release commit IDs, notarization submission IDs, hashes, and
Sparkle signatures with the release records. Clean up only this release's
workspace after verification; do not remove the entire `build/` directory or
push unrelated tags.

## 7. Refresh the local development app

Finish every successful local release by rebuilding and refreshing Mizu Dev:

```bash
python3 scripts/refresh_dev_app.py
```

The script builds Debug from the current checkout, verifies its signature and
development bundle identifier, then replaces and relaunches
`~/Applications/Mizu Dev.app`. It closes running dev copies, including ones
launched from Xcode, and opens the refreshed installation. It checks that the
installed version and build match the new build. Production remains separate.

Confirm the reported version/build match the release and include the dev refresh
result in the release summary. If this step fails, the public release is already
published: resolve the local failure and rerun this command without republishing.

## Sparkle key rotation

v2.4.2 rotated the Sparkle public key while retaining the existing Developer ID
identity and distributing a Developer ID signed DMG. Keep using the matching
Keychain key for later releases.

If a future rotation is necessary, follow Sparkle's
[key rotation documentation](https://sparkle-project.org/documentation/#rotating-signing-keys).
Rotate either the Sparkle key or the Apple signing identity in one release;
changing both breaks the update trust chain. Embed the new public key in the
app and sign the update with its matching private key. Verify the new app
against the previously shipped app's designated code requirement. For clients
that verify before extraction, the fallback also requires a Developer ID signed
DMG matching the existing app's team. Verify these conditions before publishing.
