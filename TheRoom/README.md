# The Room — Xcode project

This directory has no committed `.xcodeproj` — it's generated from `project.yml` via
[XcodeGen](https://github.com/yonaskolb/XcodeGen) so the project can be authored on
Windows and turned into a real Xcode project the moment it reaches a Mac.

## First time on a Mac

```sh
brew install xcodegen
cd TheRoom
xcodegen generate
open TheRoom.xcodeproj
```

Then in Xcode:
1. Select the `TheRoom` target → Signing & Capabilities → set your Team.
2. Confirm the App Group `group.com.man.theroom` is enabled for both the `TheRoom`
   and `TheRoomWidgetExtension` targets (already declared in `project.yml`; Xcode
   may ask you to register it under your Apple ID the first time).
3. Build & run.

Re-run `xcodegen generate` any time `project.yml` changes or new files are added —
XcodeGen picks up new files under `TheRoom/` and `TheRoomWidget/` automatically
since sources are folder-referenced, not listed individually.

## Bundle IDs
- App: `com.man.TheRoom`
- Widget extension: `com.man.TheRoom.TheRoomWidget`
- App Group: `group.com.man.theroom`

Change the `bundleIdPrefix` in `project.yml` if your Apple Developer account needs
a different prefix.
