# Release Mizu $ARGUMENTS

Execute a full Mizu release using the canonical [release process](../../docs/RELEASE.md).
Read that guide before starting and follow its signing, notarization, Sparkle,
publication, and verification steps.

Use the supplied version (for example, `/release 2.4.3`). If omitted, choose the
next patch version for bug fixes; ask only if the changes leave the version
choice unclear. Increment the build number and derive concise, user-facing
release notes from the changes, honoring any notes provided by the user.

Inspect the worktree, preserve unrelated changes, and stage only intended release
files. Use conventional commits and push only the intended tag. Publish and
verify the assets before pushing the updated feed to `main`. Keep release
records and report the published version, release URL, and verification results.
