# Release Mizu $ARGUMENTS

Execute a full release of Mizu to GitHub. The argument should be the new version number (e.g., `/release 2.4.0`).

If no version is provided, ask the user for the version number.

## Pre-flight Checks

1. Verify git working directory is clean (fail if uncommitted changes)
2. Read current MARKETING_VERSION and CURRENT_PROJECT_VERSION from project.pbxproj
3. Validate the new version argument is provided and reasonable

## Version Bump

4. Update MARKETING_VERSION in project.pbxproj to the new version
5. Increment CURRENT_PROJECT_VERSION by 1 in project.pbxproj
6. Commit with message: "Bump version to {VERSION}"

## Build & Archive

7. Build and archive:
   ```
   xcodebuild -project Mizu.xcodeproj -scheme Mizu -configuration Release archive -archivePath build/Mizu.xcarchive
   ```

## Export with Notarization

8. Create exportOptions.plist with automatic signing:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>method</key>
       <string>developer-id</string>
       <key>signingStyle</key>
       <string>automatic</string>
       <key>teamID</key>
       <string>QTZUF46V7A</string>
   </dict>
   </plist>
   ```

9. Export the archive:
   ```
   xcodebuild -exportArchive -archivePath build/Mizu.xcarchive -exportPath build/export -exportOptionsPlist build/exportOptions.plist
   ```

10. Create ZIP for notarization (notarytool requires ZIP/DMG/PKG, not raw .app):
    ```
    ditto -c -k --keepParent build/export/Mizu.app Mizu.zip
    ```

11. Notarize the ZIP (uses Keychain credentials):
    ```
    xcrun notarytool submit Mizu.zip --keychain-profile "notarytool" --wait
    ```

12. Staple the notarization ticket to the app:
    ```
    xcrun stapler staple build/export/Mizu.app
    ```

## Create Release Artifacts

13. Recreate ZIP with stapled app:
    ```
    rm Mizu.zip && ditto -c -k --keepParent build/export/Mizu.app Mizu.zip
    ```

14. Create DMG for distribution:
    ```
    hdiutil create -volname "Mizu" -srcfolder build/export/Mizu.app -ov -format UDZO Mizu.dmg
    ```

15. Get the ZIP file size:
    ```
    stat -f%z Mizu.zip
    ```

16. Sign for Sparkle (reads EdDSA key from Keychain):
    ```
    $(xcodebuild -project Mizu.xcodeproj -showBuildSettings 2>/dev/null | grep -m1 BUILD_DIR | awk '{print $3}' | sed 's|/Build/Products|/SourcePackages/artifacts/sparkle/Sparkle/bin/sign_update|') -p Mizu.zip
    ```
    Or find sign_update in your DerivedData: `find ~/Library/Developer/Xcode/DerivedData -name "sign_update" -path "*/Sparkle/*" 2>/dev/null | head -1`

## Update appcast.xml

17. Update appcast.xml with:
    - `<title>` → new version
    - `<pubDate>` → current date in RFC 2822 format (e.g., "Thu, 12 Dec 2025 10:30:00 +0000")
    - `<sparkle:version>` → new CURRENT_PROJECT_VERSION
    - `<sparkle:shortVersionString>` → new MARKETING_VERSION
    - `enclosure url` → `https://github.com/esoxjem/Mizu/releases/download/v{VERSION}/Mizu.zip`
    - `enclosure length` → file size from step 15
    - `enclosure sparkle:edSignature` → signature from step 16

18. Commit appcast.xml: "Update appcast.xml for v{VERSION}"

## Git Tag & Push

19. Create annotated tag: `git tag -a v{VERSION} -m "Release v{VERSION}"`
20. Push commits and tag: `git push && git push --tags`

## GitHub Release

21. Ask user for release notes (keep them user-focused, not technical)
22. Create GitHub release with both ZIP and DMG:
    ```
    gh release create v{VERSION} Mizu.zip Mizu.dmg --latest --title "v{VERSION}" --notes "<release_notes>"
    ```

## Cleanup

23. Remove build artifacts:
    ```
    rm -rf build/ Mizu.zip Mizu.dmg
    ```

24. Print summary: version released, GitHub release URL
