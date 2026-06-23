# Lexora Icon Setup

Phase 1 now includes app icon assets generated from the approved source image:

`/Users/umutbarisgungor/Desktop/image.png`

The original source image is not stored in this repository.

Place final app icon artwork in:

`Lexora/Assets.xcassets/AppIcon.appiconset`

Expected Xcode workflow for replacing the icon later:

1. Open `Lexora.xcodeproj`.
2. Select `Lexora/Assets.xcassets`.
3. Open `AppIcon`.
4. Drag replacement app icon images into the matching iPhone, iPad, and App Store slots.
5. In the `Lexora` target Build Settings, set App Icon to `AppIcon` if Xcode has not already done so.
6. Add `Lexora/Assets.xcassets` to the app target resources if the catalog is not compiled automatically.

The WidgetKit extension does not need a separate random icon asset in Phase 1. It should use the containing app identity unless a specific widget asset strategy is chosen later.
