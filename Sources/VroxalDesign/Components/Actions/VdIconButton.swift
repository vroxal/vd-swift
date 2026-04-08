// Components/Actions/VdIconButton.swift — Vroxal Design

import SwiftUI
import VroxalIcons

// ─────────────────────────────────────────────────────────────
// MARK: — Supporting types
// ─────────────────────────────────────────────────────────────

public enum VdIconButtonColor {
    case primary
    case neutral
}

public enum VdIconButtonStyle {
    case solid
    case subtle
    case outlined
    case transparent
}

public enum VdIconButtonSize {
    case small
    case medium
    case large

    var dimension: CGFloat {
        iconSize + (padding * 2)
    }

    var padding: CGFloat {
        switch self {
        case .small:  return VdSpacing.xs    // 4pt
        case .medium: return VdSpacing.sm    // 8pt
        case .large:  return VdSpacing.smMd  // 12pt
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .small:  return VdIconSize.md   
        case .medium: return VdIconSize.md   
        case .large:  return VdIconSize.lg   
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .small, .medium:
            return VdRadius.md
        case .large:
            return VdRadius.lg
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdIconButton
// ─────────────────────────────────────────────────────────────

public struct VdIconButton: View {

    private let icon:       VdIconSource        // SF Symbol or package icon asset
    private let color:      VdIconButtonColor
    private let style:      VdIconButtonStyle
    private let size:       VdIconButtonSize
    private let rounded:    Bool
    private let isLoading:  Bool
    private let action:     () -> Void

    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isFocused: Bool

    public init(
        icon:       String,
        color:      VdIconButtonColor = .primary,
        style:      VdIconButtonStyle = .solid,
        size:       VdIconButtonSize  = .medium,
        rounded:    Bool              = false,
        isLoading:  Bool              = false,
        isDisabled: Bool              = false,
        action:     @escaping () -> Void
    ) {
        self.icon       = .parse(icon)
        self.color      = color
        self.style      = style
        self.size       = size
        self.rounded    = rounded
        self.isLoading  = isLoading
        self.action     = action
        // isDisabled parameter is preserved for backward compatibility;
        // it is applied via .disabled() in body below.
        self._backCompatDisabled = isDisabled
    }

    public init(
        iconSource: VdIconSource,
        color:      VdIconButtonColor = .primary,
        style:      VdIconButtonStyle = .solid,
        size:       VdIconButtonSize  = .medium,
        rounded:    Bool              = false,
        isLoading:  Bool              = false,
        isDisabled: Bool              = false,
        action:     @escaping () -> Void
    ) {
        self.icon       = iconSource
        self.color      = color
        self.style      = style
        self.size       = size
        self.rounded    = rounded
        self.isLoading  = isLoading
        self.action     = action
        // isDisabled parameter is preserved for backward compatibility;
        // it is applied via .disabled() in body below.
        self._backCompatDisabled = isDisabled
    }

    /// Backward-compat: stored so we can apply .disabled() in body.
    private let _backCompatDisabled: Bool

    // ─────────────────────────────────────────────────────────
    // MARK: Body
    // ─────────────────────────────────────────────────────────

    public var body: some View {
        Button(action: action) {
            ZStack {
                // ── Icon or spinner ───────────────────────────
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(resolvedIconColor(isPressed: false))
                        .frame(width: size.iconSize, height: size.iconSize)
                } else {
                    VdIcon(
                        source: icon,
                        size: size.iconSize
                    )
                }
            }
            .padding(size.padding)
            .overlay {
                if isFocused {
                    RoundedRectangle(cornerRadius: cornerRadius + 2)
                        .strokeBorder(Color.vdBorderPrimaryTertiary, lineWidth: VdBorderWidth.md)
                        .padding(-2)
                }
            }
        }
        .buttonStyle(
            VdIconButtonPressStyle(
                cornerRadius: cornerRadius,
                backgroundColor: backgroundColor,
                hoverBackgroundColor: hoverBackgroundColor,
                borderColor: borderColor,
                hoverBorderColor: hoverBorderColor,
                iconColor: { isPressed in resolvedIconColor(isPressed: isPressed) },
                showBorder: style == .outlined,
                visualOpacity: visualOpacity
            )
        )
        .focused($isFocused)
        .disabled(_backCompatDisabled || isLoading)
        .animation(.easeInOut(duration: 0.12), value: isEnabled)
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Corner radius
    // ─────────────────────────────────────────────────────────

    private var cornerRadius: CGFloat {
        rounded ? size.dimension / 2 : size.cornerRadius
    }

    private var visualOpacity: Double {
        isVisuallyDisabled ? 0.4 : 1.0
    }

    private var isVisuallyDisabled: Bool {
        !isEnabled || _backCompatDisabled
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Derived tokens — background
    // ─────────────────────────────────────────────────────────

    private var backgroundColor: Color {
        switch style {
        case .solid:
            switch color {
            case .primary: return .vdBackgroundPrimaryBase
            case .neutral: return .vdBackgroundNeutralBase
            }
        case .subtle:
            switch color {
            case .primary: return .vdBackgroundPrimarySecondary
            case .neutral: return .vdBackgroundNeutralSecondary
            }
        case .outlined, .transparent:
            return .clear
        }
    }

    private var hoverBackgroundColor: Color {
        switch style {
        case .solid:
            switch color {
            case .primary: return .vdBackgroundPrimaryBaseHover
            case .neutral: return .vdBackgroundNeutralBaseHover
            }
        case .subtle:
            switch color {
            case .primary: return .vdBackgroundPrimarySecondaryHover
            case .neutral: return .vdBackgroundNeutralSecondaryHover
            }
        case .outlined:
            switch color {
            case .primary: return .vdBackgroundPrimarySecondary
            case .neutral: return .vdBackgroundNeutralSecondary
            }
        case .transparent:
            switch color {
            case .primary: return .vdBackgroundPrimarySecondary
            case .neutral: return .vdBackgroundNeutralSecondary
            }
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Derived tokens — border
    // ─────────────────────────────────────────────────────────

    private var borderColor: Color {
        switch color {
        case .primary: return .vdBorderPrimaryBase
        case .neutral: return .vdBorderNeutralBase
        }
    }

    private var hoverBorderColor: Color {
        switch color {
        case .primary: return .vdBorderPrimarySecondary
        case .neutral: return .vdBorderNeutralSecondary
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Derived tokens — icon
    // ─────────────────────────────────────────────────────────

    private func resolvedIconColor(isPressed: Bool) -> Color {
        switch style {
        case .solid:
            switch color {
            case .primary: return .vdContentPrimaryOnBase
            case .neutral: return .vdContentNeutralOnBase
            }
        case .subtle, .outlined, .transparent:
            switch color {
            case .primary:
                return isPressed ? .vdContentPrimarySecondary : .vdContentPrimaryBase
            case .neutral:
                return isPressed ? .vdContentNeutralSecondary : .vdContentNeutralBase
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdIconButtonPressStyle
// Custom ButtonStyle that handles press animation and derived colors,
// replacing the private _onButtonGesture API.
// ─────────────────────────────────────────────────────────────

private struct VdIconButtonPressStyle: ButtonStyle {
    let cornerRadius: CGFloat
    let backgroundColor: Color
    let hoverBackgroundColor: Color
    let borderColor: Color
    let hoverBorderColor: Color
    let iconColor: (Bool) -> Color
    let showBorder: Bool
    let visualOpacity: Double

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(isPressed ? hoverBackgroundColor : backgroundColor)
            )
            .overlay {
                if showBorder {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(isPressed ? hoverBorderColor : borderColor, lineWidth: VdBorderWidth.sm)
                }
            }
            .foregroundStyle(iconColor(isPressed))
            .opacity(visualOpacity)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: isPressed)
    }
}
