# Vroxal Design Swift

`VroxalDesign` is a Swift Package for sharing Vroxal Design tokens in SwiftUI apps.

The package currently provides:

- Semantic color tokens with light and dark mode support
- Typography tokens based on the Vroxal type scale
- Shared spacing, radius, border-width, and icon-size constants
- Reusable SwiftUI components (actions, forms, feedbacks, displays)
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

### Colors (Naming Structure)

Use semantic color tokens with this format:

`Color.vd{AreaOfUse}{SemanticName}{ColorName}`

- `AreaOfUse`: `Content`, `Background`, `Border`
- `SemanticName`: `Default`, `Primary`, `Success`, `Error`, `Warning`, `Info`, `Neutral`, `Overlay` (background only)
- `ColorName` (variant): `Base`, `Secondary`, `Tertiary`, `Disabled`, `OnBase`, `OnSecondary`, `OnTertiary`, `BaseHover`, `SecondaryHover`, `TertiaryHover`, `AlwaysLight`, `AlwaysDark`

Not every combination exists for every semantic group. Use available tokens following the pattern above.

Examples:

```swift
Text("Heading")
    .foregroundStyle(Color.vdContentDefaultBase)

Text("Primary button")
    .foregroundStyle(Color.vdContentPrimaryOnBase)
    .padding(.horizontal, VdSpacing.md)
    .padding(.vertical, VdSpacing.sm)
    .background(Color.vdBackgroundPrimaryBase)

RoundedRectangle(cornerRadius: VdRadius.lg)
    .strokeBorder(Color.vdBorderDefaultSecondary, lineWidth: VdBorderWidth.sm)
```

### Typography

Typography is exposed through `VdFont`, `VdTextStyle`, `VdTracking`, and `View.vdFont(_:)`.

Initialize typography once at app startup:

```swift
@main
struct MyApp: App {
    init() {
        VdFont.register()
    }

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```

Use typography in views:

```swift
Text("Section title")
    .vdFont(.titleLarge)
    .foregroundStyle(Color.vdContentDefaultBase)

Text("Body copy")
    .vdFont(.bodyMedium)
    .foregroundStyle(Color.vdContentDefaultSecondary)
```

| Variant            | Size | Line Height | Weight        | Tracking |
| ------------------ | ---- | ----------- | ------------- | -------- |
| `displayLarge`     | 60   | 72          | semibold      | -1.5     |
| `displayMedium`    | 48   | 56          | semibold      | -1.0     |
| `displaySmall`     | 40   | 48          | semibold      | -0.5     |
| `headlineLarge`    | 34   | 40          | semibold      | -0.3     |
| `headlineMedium`   | 28   | 36          | semibold      | -0.3     |
| `headlineSmall`    | 24   | 32          | semibold      | -0.3     |
| `titleLarge`       | 20   | 28          | semibold      | 0        |
| `titleMedium`      | 16   | 24          | semibold      | 0        |
| `titleSmall`       | 14   | 20          | semibold      | 0        |
| `labelLarge`       | 16   | 24          | medium        | 0.2      |
| `labelMedium`      | 14   | 24          | medium        | 0.2      |
| `labelSmall`       | 12   | 16          | medium        | 0.2      |
| `labelExtraSmall`  | 10   | 16          | medium        | 0.2      |
| `bodyExtraLarge`   | 24   | 36          | regular       | 0        |
| `bodyLarge`        | 16   | 24          | regular       | 0        |
| `bodyMedium`       | 14   | 24          | regular       | 0        |
| `bodyMediumItalic` | 14   | 24          | regularItalic | 0        |
| `bodySmall`        | 12   | 16          | regular       | 0        |
| `bodyExtraSmall`   | 10   | 16          | regular       | 0        |

### Scale

Layout and sizing use a shared scale system.

Scale steps (pt): `0, 1, 2, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96, 120`  
Negative spacing steps (pt): `-2, -4, -8, -12, -16, -24`

- `VdSpacing`: padding, margin, and gaps
- `VdRadius`: corner radius
- `VdBorderWidth`: border/focus ring thickness
- `VdIconSize`: icon sizing

Usage:

```swift
VStack(spacing: VdSpacing.md) {
    Text("Card title").vdFont(.titleMedium)
}
.padding(VdSpacing.lg)
.background(Color.vdBackgroundDefaultSecondary)
.overlay(
    RoundedRectangle(cornerRadius: VdRadius.lg)
        .strokeBorder(Color.vdBorderDefaultSecondary, lineWidth: VdBorderWidth.sm)
)
```

## Package Structure

```text
vd-swift/
├── Package.swift
├── Sources/VroxalDesign/
│   ├── Components/
│   │   ├── Actions/
│   │   │   ├── VdButton.swift
│   │   │   └── VdIconButton.swift
│   │   ├── Displays/
│   │   │   ├── VdBadge.swift
│   │   │   └── VdDivider.swift
│   │   ├── Feedbacks/
│   │   │   ├── VdAlerts.swift
│   │   │   ├── VdEmptyState.swift
│   │   │   ├── VdLoadingState.swift
│   │   │   └── VdSnackbar.swift
│   │   └── Forms/
│   │       ├── VdCheckbox.swift
│   │       ├── VdCodeInput.swift
│   │       ├── VdDateTimeField.swift
│   │       ├── VdRadioButton.swift
│   │       ├── VdSelectField.swift
│   │       ├── VdSelectionCard.swift
│   │       ├── VdTextArea.swift
│   │       └── VdTextField.swift
│   ├── Resources/Fonts/
│   │   ├── Poppins-Italic.ttf
│   │   ├── Poppins-Medium.ttf
│   │   ├── Poppins-Regular.ttf
│   │   └── Poppins-SemiBold.ttf
│   ├── VroxalDesign.swift
│   └── Theme/
│       ├── Colors.swift
│       ├── Scale.swift
│       └── Typography.swift
└── Tests/VroxalDesignTests/
```

## Status

The package currently includes design tokens, shared helpers, and reusable SwiftUI components.

## License

MIT
