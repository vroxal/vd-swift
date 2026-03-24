// Components/Actions/VdIconButton.swift — Vroxal Design
// ─────────────────────────────────────────────────────────────
// Figma source: node 90-5131
//
// An icon-only square button. Shares the same token logic as
// VdButton — same styles, same press/focus/disabled states.
//
// VARIANTS
//   VdIconButtonColor  — primary · neutral
//   VdIconButtonStyle  — solid · subtle · outlined · transparent
//   VdIconButtonSize   — small (32pt) · medium (40pt) · large (56pt)
//   rounded            — Bool: radius/sm (8pt) vs radius/full (circle)
//
// SIZES
//   Small   32×32pt  padding 4pt   icon container 16pt
//   Medium  40×40pt  padding 8pt   icon container 24pt
//   Large   56×56pt  padding 16pt  icon container 32pt
//
// TOKEN PATTERNS  (mirrors VdButton exactly)
//   Solid        bg=BackgroundBase        icon=ContentOnBase
//   Subtle       bg=BackgroundSecondary   icon=ContentBase
//   Outlined     border=BorderBase        icon=ContentBase
//   Transparent  no bg/border             icon=ContentBase
//
//   Press → BaseHover / SecondaryHover equivalents
//   Focus → focus ring BorderPrimaryTertiary 2pt outset 3pt
//   Disabled → BackgroundDefaultDisabled + ContentDefaultDisabled
//   Loading → spinner replaces icon, same background
//
// USAGE
//   VdIconButton(icon: "plus", action: { addItem() })
//
//   VdIconButton(icon: "trash",
//       color: .neutral,
//       style: .outlined,
//       size: .large,
//       rounded: true,
//       action: { delete() })
//
//   VdIconButton(icon: "arrow.up",
//       isLoading: true,
//       action: {})
// ─────────────────────────────────────────────────────────────

import SwiftUI

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
    case small    // 32×32pt
    case medium   // 40×40pt
    case large    // 56×56pt

    var dimension: CGFloat {
        switch self {
        case .small:  return 32
        case .medium: return 40
        case .large:  return 56
        }
    }

    var padding: CGFloat {
        switch self {
        case .small:  return VdSpacing.xs    // 4pt
        case .medium: return VdSpacing.sm    // 8pt
        case .large:  return VdSpacing.md    // 16pt
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .small:  return VdIconSize.md   // 16pt
        case .medium: return VdIconSize.md   // 24pt
        case .large:  return VdIconSize.lg   // 32pt
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdIconButton
// ─────────────────────────────────────────────────────────────

public struct VdIconButton: View {

    private let icon:       String              // SF Symbol name
    private let color:      VdIconButtonColor
    private let style:      VdIconButtonStyle
    private let size:       VdIconButtonSize
    private let rounded:    Bool
    private let isLoading:  Bool
    private let iconColorOverride: Color?
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
        iconColorOverride: Color?     = nil,
        action:     @escaping () -> Void
    ) {
        self.icon       = icon
        self.color      = color
        self.style      = style
        self.size       = size
        self.rounded    = rounded
        self.isLoading  = isLoading
        self.iconColorOverride = iconColorOverride
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
                // ── Background shell ──────────────────────────
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.clear)  // placeholder — style fills it

                // ── Focus ring ────────────────────────────────
                if isFocused {
                    RoundedRectangle(cornerRadius: cornerRadius + 3)
                        .strokeBorder(Color.vdBorderPrimaryTertiary, lineWidth: VdBorderWidth.md)
                        .padding(-3)
                }

                // ── Icon or spinner ───────────────────────────
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(resolvedIconColor(isPressed: false))
                        .scaleEffect(size == .small ? 0.7 : 1.0)
                } else {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .padding(2)
                        .frame(width: size.iconSize, height: size.iconSize)
                }
            }
            .frame(width: size.dimension, height: size.dimension)
        }
        .buttonStyle(
            VdIconButtonPressStyle(
                cornerRadius: cornerRadius,
                backgroundColor: backgroundColor,
                hoverBackgroundColor: hoverBackgroundColor,
                borderColor: borderColor,
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
        rounded ? size.dimension / 2 : VdRadius.sm     // full circle vs 8pt
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
        if !isEnabled {
            return style == .transparent ? .clear : .vdBackgroundDefaultDisabled
        }
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
        if !isEnabled {
            return style == .transparent ? .clear : .vdBackgroundDefaultDisabled
        }
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
        if !isEnabled { return .vdBorderDefaultDisabled }
        switch color {
        case .primary: return .vdBorderPrimaryBase
        case .neutral: return .vdBorderNeutralBase
        }
    }

    private var hoverBorderColor: Color {
        if !isEnabled { return .vdBorderDefaultDisabled }
        switch color {
        case .primary: return .vdBorderPrimarySecondary
        case .neutral: return .vdBorderNeutralSecondary
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Derived tokens — icon
    // ─────────────────────────────────────────────────────────

    private func resolvedIconColor(isPressed: Bool) -> Color {
        if !isEnabled { return .vdContentDefaultDisabled }
        if let override = iconColorOverride { return override }
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
    let iconColor: (Bool) -> Color
    let showBorder: Bool
    let visualOpacity: Double

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(isPressed ? hoverBackgroundColor : backgroundColor)
                    .opacity(visualOpacity)
            )
            .overlay {
                if showBorder {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(borderColor, lineWidth: VdBorderWidth.sm)
                        .opacity(visualOpacity)
                }
            }
            .foregroundStyle(iconColor(isPressed))
            .opacity(visualOpacity)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: isPressed)
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — Preview
// ─────────────────────────────────────────────────────────────

#Preview("VdIconButton — All Variants") {
    ScrollView {
        VStack(alignment: .leading, spacing: VdSpacing.xl) {

            // ── Styles × Colors ───────────────────────────────
            previewSection("Solid") {
                styleRow(style: .solid)
            }
            previewSection("Subtle") {
                styleRow(style: .subtle)
            }
            previewSection("Outlined") {
                styleRow(style: .outlined)
            }
            previewSection("Transparent") {
                styleRow(style: .transparent)
            }

            // ── Sizes ─────────────────────────────────────────
            previewSection("Sizes — Small / Medium / Large") {
                HStack(spacing: VdSpacing.md) {
                    VdIconButton(icon: "plus", size: .small,  action: {})
                    VdIconButton(icon: "plus", size: .medium, action: {})
                    VdIconButton(icon: "plus", size: .large,  action: {})
                }
            }

            // ── Rounded ───────────────────────────────────────
            previewSection("Rounded") {
                HStack(spacing: VdSpacing.sm) {
                    VdIconButton(icon: "plus",    style: .solid,       rounded: true, action: {})
                    VdIconButton(icon: "trash",   style: .subtle,      rounded: true, action: {})
                    VdIconButton(icon: "pencil",  style: .outlined,    rounded: true, action: {})
                    VdIconButton(icon: "ellipsis.horizontal", color: .neutral, style: .transparent, rounded: true, action: {})
                }
            }

            // ── Loading ───────────────────────────────────────
            previewSection("Loading") {
                HStack(spacing: VdSpacing.sm) {
                    VdIconButton(icon: "plus", style: .solid,       isLoading: true, action: {})
                    VdIconButton(icon: "plus", style: .subtle,      isLoading: true, action: {})
                    VdIconButton(icon: "plus", style: .outlined,    isLoading: true, action: {})
                    VdIconButton(icon: "plus", style: .transparent, isLoading: true, action: {})
                }
            }

            // ── Disabled ──────────────────────────────────────
            previewSection("Disabled") {
                HStack(spacing: VdSpacing.sm) {
                    VdIconButton(icon: "plus", style: .solid,       isDisabled: true, action: {})
                    VdIconButton(icon: "plus", style: .subtle,      isDisabled: true, action: {})
                    VdIconButton(icon: "plus", style: .outlined,    isDisabled: true, action: {})
                    VdIconButton(icon: "plus", style: .transparent, isDisabled: true, action: {})
                }
            }

            // ── Interactive ───────────────────────────────────
            previewSection("Interactive") {
                InteractiveIconButtonDemo()
            }
        }
        .padding(VdSpacing.lg)
    }
    .background(Color.vdBackgroundDefaultBase)
}

@ViewBuilder
private func styleRow(style: VdIconButtonStyle) -> some View {
    HStack(spacing: VdSpacing.sm) {
        // Primary
        VdIconButton(icon: "square.grid.2x2", color: .primary, style: style, action: {})
        VdIconButton(icon: "square.grid.2x2", color: .primary, style: style, rounded: true, action: {})
        Spacer().frame(width: VdSpacing.sm)
        // Neutral
        VdIconButton(icon: "square.grid.2x2", color: .neutral, style: style, action: {})
        VdIconButton(icon: "square.grid.2x2", color: .neutral, style: style, rounded: true, action: {})
    }
}

private func previewSection<Content: View>(
    _ title: String,
    @ViewBuilder content: () -> Content
) -> some View {
    VStack(alignment: .leading, spacing: VdSpacing.sm) {
        Text(title)
            .vdFont(VdFont.labelSmall)
            .foregroundStyle(Color.vdContentDefaultTertiary)
        content()
    }
}

private struct InteractiveIconButtonDemo: View {
    @State private var count    = 0
    @State private var isLoading = false

    var body: some View {
        HStack(spacing: VdSpacing.md) {
            VdIconButton(icon: "minus",
                color: .neutral,
                style: .outlined,
                action: { count -= 1 })

            Text("\(count)")
                .vdFont(VdFont.labelMedium)
                .foregroundStyle(Color.vdContentDefaultBase)
                .frame(minWidth: 32, alignment: .center)

            VdIconButton(icon: "plus",
                action: { count += 1 })

            Spacer()

            VdIconButton(icon: "arrow.clockwise",
                style: .subtle,
                isLoading: isLoading,
                action: {
                    isLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isLoading = false
                        count = 0
                    }
                })
        }
        .padding(VdSpacing.md)
        .background(Color.vdBackgroundDefaultSecondary)
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
    }
}
