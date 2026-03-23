# Vroxal Design Swift

`VroxalDesign` is a Swift Package for sharing Vroxal Design tokens in SwiftUI apps.

The package currently provides:

- Semantic color tokens with light and dark mode support
- Typography tokens based on the Vroxal type scale
- Shared spacing, radius, border-width, and icon-size constants
- A small `onChangeCompat` helper for iOS 16 and iOS 17+

## Requirements

- iOS 16+
- Swift 5.9+
- Xcode 15+

## Installation

### Xcode

1. Open your app project.
2. Go to `File` -> `Add Package Dependencies...`
3. Paste:

```text
https://github.com/vroxal/vd-swift
```

### Package.swift

```swift
.package(url: "https://github.com/vroxal/vd-swift", from: "1.0.0")
```

Then add `VroxalDesign` to your target dependencies and import it where needed:

```swift
import VroxalDesign
```

## Font Setup

Typography tokens are built around Poppins. If the font files are bundled in the package resources, `VdFont.register()` will register them automatically. If they are missing, the package falls back to system fonts so the app still renders.

Expected font files:

- `Poppins-Regular.ttf`
- `Poppins-Medium.ttf`
- `Poppins-SemiBold.ttf`
- `Poppins-Italic.ttf`

Place them under `Sources/VroxalDesign/Resources/Fonts/`.

Call `VdFont.register()` once during app startup:

```swift
import SwiftUI
import VroxalDesign

@main
struct MyApp: App {
    init() {
        VdFont.register()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Quick Start

```swift
import SwiftUI
import VroxalDesign

struct ProfileCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: VdSpacing.md) {
            Text("Vroxal")
                .vdFont(.headlineSmall)
                .foregroundStyle(Color.vdContentDefaultBase)

            Text("Design tokens for SwiftUI")
                .vdFont(.bodyMedium)
                .foregroundStyle(Color.vdContentDefaultSecondary)

            Text("Active")
                .vdFont(.labelSmall)
                .padding(.horizontal, VdSpacing.sm)
                .padding(.vertical, VdSpacing.xxs)
                .background(Color.vdBackgroundPrimarySecondary)
                .foregroundStyle(Color.vdContentPrimarySecondary)
                .clipShape(RoundedRectangle(cornerRadius: VdRadius.full))
        }
        .padding(VdSpacing.lg)
        .background(Color.vdBackgroundDefaultBase)
        .overlay(
            RoundedRectangle(cornerRadius: VdRadius.lg)
                .stroke(Color.vdBorderDefaultSecondary, lineWidth: VdBorderWidth.sm)
        )
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
    }
}
```

## Public API

### Colors

Use semantic color tokens from `Color` extensions. These resolve dynamically for light and dark appearance.

Examples:

- Content: `Color.vdContentDefaultBase`, `Color.vdContentDefaultSecondary`, `Color.vdContentPrimaryOnBase`
- Background: `Color.vdBackgroundDefaultBase`, `Color.vdBackgroundPrimaryBase`, `Color.vdBackgroundOverlayBase`
- Border: `Color.vdBorderDefaultBase`, `Color.vdBorderErrorSecondary`, `Color.vdBorderSuccessTertiary`

The package also exposes brand and raw palette colors such as `Color.vdPrimary500` and `Color.vdBlueGlow500`, but semantic tokens should be the default choice for app UI.

### Typography

Typography is exposed through `VdFont`, `VdTextStyle`, `VdTracking`, and the `View.vdFont(_:)` modifier.

Available text styles:

- Display: `displayLarge`, `displayMedium`, `displaySmall`
- Headline: `headlineLarge`, `headlineMedium`, `headlineSmall`
- Title: `titleLarge`, `titleMedium`, `titleSmall`
- Label: `labelLarge`, `labelMedium`, `labelSmall`, `labelExtraSmall`
- Body: `bodyExtraLarge`, `bodyLarge`, `bodyMedium`, `bodyMediumItalic`, `bodySmall`, `bodyExtraSmall`

Example:

```swift
Text("Section title")
    .vdFont(.titleLarge)
    .foregroundStyle(Color.vdContentDefaultBase)
```

### Scale

Layout and sizing tokens are exposed as simple static constants:

- `VdSpacing`
- `VdRadius`
- `VdBorderWidth`
- `VdIconSize`

Example:

```swift
Image(systemName: "star.fill")
    .font(.system(size: VdIconSize.md))
    .padding(VdSpacing.sm)
```

### Compatibility Helper

`onChangeCompat(of:perform:)` is available on `View` to smooth over the API difference between iOS 16 and iOS 17:

```swift
TextField("Name", text: $name)
    .onChangeCompat(of: name) { value in
        print(value)
    }
```

## Package Structure

```text
vd-swift/
├── Package.swift
├── Sources/VroxalDesign/
│   ├── VroxalDesign.swift
│   └── Theme/
│       ├── Colors.swift
│       ├── Scale.swift
│       └── Typography.swift
└── Tests/VroxalDesignTests/
```

## Status

The current package target contains design tokens and shared view helpers. Component implementations such as buttons, form controls, and feedback views are not part of this repository yet.

## License

MIT
