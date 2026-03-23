# VroxalDesign

Vroxal Design System for SwiftUI.

`VroxalDesign` is a Swift Package that provides reusable design tokens and UI components for iOS apps.

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

## Font Setup

VroxalDesign expects these bundled Poppins files:

- `Poppins-Regular.ttf`
- `Poppins-Medium.ttf`
- `Poppins-SemiBold.ttf`
- `Poppins-Italic.ttf`

Add them to `Sources/VroxalDesign/Resources/Fonts` in this package and include matching `UIAppFonts` entries in your app `Info.plist`.

Call `VdFont.register()` once at app startup:

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

struct OnboardingView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSubmitting = false

    var body: some View {
        VStack(spacing: VdSpacing.lg) {
            VdTextField(
                "Email",
                text: $email,
                placeholder: "you@example.com",
                leadingIcon: "envelope"
            )

            VdTextField(
                "Password",
                text: $password,
                placeholder: "Enter your password",
                isSecure: true,
                leadingIcon: "lock"
            )

            VdButton("Continue", fullWidth: true, isLoading: isSubmitting) {
                isSubmitting = true
            }
        }
        .padding(VdSpacing.lg)
        .background(Color.vdBackgroundDefaultBase)
    }
}
```

## Package Structure

```text
VroxalDesign/
├── Package.swift
├── Sources/VroxalDesign/
│   ├── VroxalDesign.swift
│   ├── Theme/
│   │   ├── Colors.swift
│   │   ├── Typography.swift
│   │   └── Scale.swift
│   ├── Components/
│   │   ├── Actions/
│   │   │   ├── VdButton.swift
│   │   │   └── VdIconButton.swift
│   │   ├── Forms/
│   │   │   ├── VdTextField.swift
│   │   │   ├── VdTextArea.swift
│   │   │   ├── VdSelectField.swift
│   │   │   ├── VdDateTimeField.swift
│   │   │   ├── VdCheckbox.swift
│   │   │   ├── VdRadioButton.swift
│   │   │   ├── VdSelectionCard.swift
│   │   │   └── VdCodeInput.swift
│   │   ├── Feedbacks/
│   │   │   ├── VdAlerts.swift
│   │   │   ├── VdEmptyState.swift
│   │   │   ├── VdSnackbar.swift
│   │   │   └── VdLoadingState.swift
│   │   └── Displays/
│   │       └── VdBadge.swift
│   └── Resources/
│       └── Fonts/
└── Tests/
```

## Public API Overview

### Theme Tokens

- Colors: `Color.vdContent*`, `Color.vdBackground*`, `Color.vdBorder*`
- Typography: `VdFont`, `VdTextStyle`, `VdTracking`, `.vdFont(_:)`
- Scale: `VdSpacing`, `VdRadius`, `VdBorderWidth`, `VdIconSize`

### Available Components

- Actions: `VdButton`, `VdIconButton`
- Forms: `VdTextField`, `VdTextArea`, `VdSelectField`, `VdDateTimeField`, `VdCheckbox`, `VdRadioButton`, `VdRadioGroup`, `VdRadioOption`, `VdSelectionCard`, `VdSelectionCardGroup`, `VdSelectionCardOption`, `VdCodeInput`
- Feedback: `VdAlert`, `VdSnackbar`, `VdSnackbarModifier`, `VdLoadingState`, `VdSpinner`, `VdEmptyState`
- Display: `VdBadge`

### Variant/State Types

- Buttons: `VdButtonColor`, `VdButtonStyle`, `VdButtonSize`
- Icon Buttons: `VdIconButtonColor`, `VdIconButtonStyle`, `VdIconButtonSize`
- Inputs: `VdInputState`, `VdSelectFieldState`, `VdDateTimeFieldMode`, `VdCodeInputState`
- Selection: `VdSelectionStyle`
- Feedback: `VdAlertColor`, `VdLoadingStyle`
- Badges: `VdBadgeColor`, `VdBadgeStyle`, `VdBadgeSize`

### View Helpers

- Snackbar presentation: `.vdSnackbar(...)`
- Skeleton loading: `.vdSkeleton(...)`

## License

MIT
