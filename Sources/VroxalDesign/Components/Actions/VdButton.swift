//
//  VdButton.swift
//  VroxalDesign
//
//  Created by Pramod Paudel on 16/03/2026.
//
// Components/Buttons/VdButton.swift — Vroxal Design

import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: — Enums
// ─────────────────────────────────────────────────────────────

public enum VdButtonColor {
    case primary
    case neutral
    case error
    case success
    case warning
    case info
}

public enum VdButtonStyle {
    case solid
    case subtle
    case outlined
    case transparent
}

public enum VdButtonSize {
    case small
    case medium
    case large
}

// ─────────────────────────────────────────────────────────────
// MARK: — Token resolution
// ─────────────────────────────────────────────────────────────

private struct VdButtonTokens {
    let background: Color
    let hoverBackground: Color
    let border: Color?          // nil = no border
    let label: Color
    let hoverLabel: Color       // label color on press
}

extension VdButtonColor {

    // swiftlint:disable function_body_length
    fileprivate func tokens(for style: VdButtonStyle) -> VdButtonTokens {
        switch style {

        case .solid:
            switch self {
            case .primary:
                return VdButtonTokens(
                    background: .vdBackgroundPrimaryBase,
                    hoverBackground: .vdBackgroundPrimaryBaseHover,
                    border: nil,
                    label: .vdContentPrimaryOnBase,
                    hoverLabel: .vdContentPrimaryOnBase
                )
            case .neutral:
                return VdButtonTokens(
                    background: .vdBackgroundNeutralBase,
                    hoverBackground: .vdBackgroundNeutralBaseHover,
                    border: nil,
                    label: .vdContentNeutralOnBase,
                    hoverLabel: .vdContentNeutralOnBase
                )
            case .error:
                return VdButtonTokens(
                    background: .vdBackgroundErrorBase,
                    hoverBackground: .vdBackgroundErrorBaseHover,
                    border: nil,
                    label: .vdContentErrorOnBase,
                    hoverLabel: .vdContentErrorOnBase
                )
            case .success:
                return VdButtonTokens(
                    background: .vdBackgroundSuccessBase,
                    hoverBackground: .vdBackgroundSuccessBaseHover,
                    border: nil,
                    label: .vdContentSuccessOnBase,
                    hoverLabel: .vdContentSuccessOnBase
                )
            case .warning:
                return VdButtonTokens(
                    background: .vdBackgroundWarningBase,
                    hoverBackground: .vdBackgroundWarningBaseHover,
                    border: nil,
                    label: .vdContentWarningOnBase,
                    hoverLabel: .vdContentWarningOnBase
                )
            case .info:
                return VdButtonTokens(
                    background: .vdBackgroundInfoBase,
                    hoverBackground: .vdBackgroundInfoBaseHover,
                    border: nil,
                    label: .vdContentInfoOnBase,
                    hoverLabel: .vdContentInfoOnBase
                )
            }

        case .subtle:
            switch self {
            case .primary:
                return VdButtonTokens(
                    background: .vdBackgroundPrimarySecondary,
                    hoverBackground: .vdBackgroundPrimarySecondaryHover,
                    border: nil,
                    label: .vdContentPrimaryOnSecondary,
                    hoverLabel: .vdContentPrimaryOnSecondary
                )
            case .neutral:
                return VdButtonTokens(
                    background: .vdBackgroundNeutralSecondary,
                    hoverBackground: .vdBackgroundNeutralSecondaryHover,
                    border: nil,
                    label: .vdContentNeutralOnSecondary,
                    hoverLabel: .vdContentNeutralOnSecondary
                )
            case .error:
                return VdButtonTokens(
                    background: .vdBackgroundErrorSecondary,
                    hoverBackground: .vdBackgroundErrorSecondaryHover,
                    border: nil,
                    label: .vdContentErrorOnSecondary,
                    hoverLabel: .vdContentErrorOnSecondary
                )
            case .success:
                return VdButtonTokens(
                    background: .vdBackgroundSuccessSecondary,
                    hoverBackground: .vdBackgroundSuccessSecondaryHover,
                    border: nil,
                    label: .vdContentSuccessOnSecondary,
                    hoverLabel: .vdContentSuccessOnSecondary
                )
            case .warning:
                return VdButtonTokens(
                    background: .vdBackgroundWarningSecondary,
                    hoverBackground: .vdBackgroundWarningSecondaryHover,
                    border: nil,
                    label: .vdContentWarningOnSecondary,
                    hoverLabel: .vdContentWarningOnSecondary
                )
            case .info:
                return VdButtonTokens(
                    background: .vdBackgroundInfoSecondary,
                    hoverBackground: .vdBackgroundInfoSecondaryHover,
                    border: nil,
                    label: .vdContentInfoOnSecondary,
                    hoverLabel: .vdContentInfoOnSecondary
                )
            }

        case .outlined:
            switch self {
            case .primary:
                return VdButtonTokens(
                    background: .clear,
                    hoverBackground: .vdBackgroundPrimarySecondary,
                    border: .vdBorderPrimaryBase,
                    label: .vdContentPrimaryBase,
                    hoverLabel: .vdContentPrimaryOnSecondary
                )
            case .neutral:
                return VdButtonTokens(
                    background: .clear,
                    hoverBackground: .vdBackgroundNeutralSecondary,
                    border: .vdBorderNeutralBase,
                    label: .vdContentNeutralBase,
                    hoverLabel: .vdContentNeutralOnSecondary
                )
            case .error:
                return VdButtonTokens(
                    background: .clear,
                    hoverBackground: .vdBackgroundErrorSecondary,
                    border: .vdBorderErrorBase,
                    label: .vdContentErrorBase,
                    hoverLabel: .vdContentErrorOnSecondary
                )
            case .success:
                return VdButtonTokens(
                    background: .clear,
                    hoverBackground: .vdBackgroundSuccessSecondary,
                    border: .vdBorderSuccessBase,
                    label: .vdContentSuccessBase,
                    hoverLabel: .vdContentSuccessOnSecondary
                )
            case .warning:
                return VdButtonTokens(
                    background: .clear,
                    hoverBackground: .vdBackgroundWarningSecondary,
                    border: .vdBorderWarningBase,
                    label: .vdContentWarningBase,
                    hoverLabel: .vdContentWarningOnSecondary
                )
            case .info:
                return VdButtonTokens(
                    background: .clear,
                    hoverBackground: .vdBackgroundInfoSecondary,
                    border: .vdBorderInfoBase,
                    label: .vdContentInfoBase,
                    hoverLabel: .vdContentInfoOnSecondary
                )
            }

        case .transparent:
            switch self {
            case .primary:
                return VdButtonTokens(
                    background: .clear,
                    hoverBackground: .vdBackgroundPrimarySecondary,
                    border: nil,
                    label: .vdContentPrimaryBase,
                    hoverLabel: .vdContentPrimaryOnSecondary
                )
            case .neutral:
                return VdButtonTokens(
                    background: .clear,
                    hoverBackground: .vdBackgroundNeutralSecondary,
                    border: nil,
                    label: .vdContentNeutralBase,
                    hoverLabel: .vdContentNeutralOnSecondary
                )
            case .error:
                return VdButtonTokens(
                    background: .clear,
                    hoverBackground: .vdBackgroundErrorSecondary,
                    border: nil,
                    label: .vdContentErrorBase,
                    hoverLabel: .vdContentErrorOnSecondary
                )
            case .success:
                return VdButtonTokens(
                    background: .clear,
                    hoverBackground: .vdBackgroundSuccessSecondary,
                    border: nil,
                    label: .vdContentSuccessBase,
                    hoverLabel: .vdContentSuccessOnSecondary
                )
            case .warning:
                return VdButtonTokens(
                    background: .clear,
                    hoverBackground: .vdBackgroundWarningSecondary,
                    border: nil,
                    label: .vdContentWarningBase,
                    hoverLabel: .vdContentWarningOnSecondary
                )
            case .info:
                return VdButtonTokens(
                    background: .clear,
                    hoverBackground: .vdBackgroundInfoSecondary,
                    border: nil,
                    label: .vdContentInfoBase,
                    hoverLabel: .vdContentInfoOnSecondary
                )
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — Size constants
// ─────────────────────────────────────────────────────────────

extension VdButtonSize {

    fileprivate var verticalPadding: CGFloat {
        switch self {
        case .small: return VdSpacing.sm
        case .medium: return VdSpacing.smMd
        case .large: return VdSpacing.smMd
        }
    }

    fileprivate var horizontalPadding: CGFloat {
        switch self {
        case .small: return VdSpacing.md
        case .medium: return VdSpacing.lg
        case .large: return VdSpacing.xl
        }
    }

    fileprivate var iconSize: CGFloat {
        switch self {
        case .small: return VdIconSize.xs
        case .medium: return VdIconSize.md
        case .large: return VdIconSize.lg
        }
    }

    fileprivate var labelStyle: VdTextStyle {
        switch self {
        case .small: return VdFont.labelSmall
        case .medium: return VdFont.labelMedium
        case .large: return .labelLarge
        }
    }

    fileprivate var labelVerticalPadding: CGFloat {
        switch self {
        case .small, .medium: return 0
        case .large: return VdSpacing.xs
        }
    }

    fileprivate var defaultRadius: CGFloat {
        switch self {
        case .small, .medium: return VdRadius.md
        case .large: return VdRadius.lg
        }
    }

    fileprivate var spinnerScale: CGFloat {
        switch self {
        case .small: return 0.9
        case .medium: return 1
        case .large: return 1.1
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdButton
// ─────────────────────────────────────────────────────────────

public struct VdButton: View {

    private let label: String
    private let color: VdButtonColor
    private let style: VdButtonStyle
    private let size: VdButtonSize
    private let rounded: Bool
    private let fullWidth: Bool
    private let isLoading: Bool
    private let leftIcon: String?
    private let rightIcon: String?
    private let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isFocused: Bool

    public init(
        _ label: String,
        color: VdButtonColor = .primary,
        style: VdButtonStyle = .solid,
        size: VdButtonSize = .medium,
        rounded: Bool = false,
        fullWidth: Bool = false,
        isLoading: Bool = false,
        leftIcon: String? = nil,
        rightIcon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.color = color
        self.style = style
        self.size = size
        self.rounded = rounded
        self.fullWidth = fullWidth
        self.isLoading = isLoading
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.action = action
    }

    // ─────────────────────────────────────────────────────────

    public var body: some View {
        Button(action: { if !isLoading { action() } }) {
            buttonContent
        }
        .buttonStyle(VdButtonPressStyle(tokens: color.tokens(for: style), cornerRadius: cornerRadius))
        .focused($isFocused)
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1.0 : 0.4)
        .overlay {
            if isFocused {
                RoundedRectangle(cornerRadius: cornerRadius + 2)
                    .strokeBorder(
                        Color.vdBorderPrimaryTertiary,
                        lineWidth: VdBorderWidth.md
                    )
                    .padding(-2)
            }
        }

    }

    // ── Inner content ─────────────────────────────────────────

    private var buttonContent: some View {
        let tokens = color.tokens(for: style)

        return ZStack {
            HStack(spacing: VdSpacing.sm) {
                if let icon = leftIcon {
                    VdIcon(icon, size: size.iconSize)
                }

                Text(label)
                    .vdFont(size.labelStyle)
                    .lineLimit(1)
                    .padding(.vertical, size.labelVerticalPadding)

                if let icon = rightIcon {
                    VdIcon(icon, size: size.iconSize)
                }
            }
            .opacity(isLoading ? 0 : 1)

            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(size.spinnerScale)
                .tint(tokens.label)
                .opacity(isLoading ? 1 : 0)
        }
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .frame(maxWidth: fullWidth ? .infinity : nil)
    }

    private var cornerRadius: CGFloat {
        rounded ? VdRadius.full : size.defaultRadius
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdButtonPressStyle
// ─────────────────────────────────────────────────────────────

private struct VdButtonPressStyle: ButtonStyle {
    let tokens: VdButtonTokens
    let cornerRadius: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        configuration.label
            .foregroundStyle(pressed ? tokens.hoverLabel : tokens.label)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(pressed ? tokens.hoverBackground : tokens.background)
            )
            .overlay {
                if let borderColor = tokens.border {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(borderColor, lineWidth: VdBorderWidth.sm)
                }
            }
            .scaleEffect(pressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: pressed)
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — Preview
// ─────────────────────────────────────────────────────────────

#Preview("VdButton — All Variants") {
    ScrollView {
        VStack(alignment: .leading, spacing: VdSpacing.xl) {
 
            previewSection("Icons") {
                VStack(alignment:.leading, spacing: VdSpacing.sm) {
                    VdButton(
                        "Upload",
                        size: .small,
                        leftIcon: "vd:arrow-up",
                        action: {}
                    ).disabled(true)

                    VdButton(
                        "Next",
                        size: .medium,
                        rightIcon: "vd:arrow-right",
                        action: {}
                    )
                    VdButton(
                        "Share",
                        color: .neutral,
                        style: .outlined,
                        size: .large,
                        action: {}
                    )
                }
            }

            previewSection("Style · Primary") {

                HStack(spacing: VdSpacing.sm) {
                    VdButton("Solid", style: .solid, action: {})
                    VdButton("Subtle", style: .subtle, action: {})
                    VdButton("Outlined", style: .outlined, action: {})
                    VdButton("Transparent", style: .transparent, action: {})
                }
            }

            previewSection("Color · Solid") {
                VStack(alignment: .leading, spacing: VdSpacing.sm) {
                    HStack(spacing: VdSpacing.sm) {
                        VdButton("Primary", color: .primary, action: {})
                        VdButton("Neutral", color: .neutral, action: {})
                        VdButton("Error", color: .error, action: {})
                    }
                    HStack(spacing: VdSpacing.sm) {
                        VdButton("Success", color: .success, action: {})
                        VdButton("Warning", color: .warning, action: {})
                        VdButton("Info", color: .info, action: {})
                    }
                }
            }

            previewSection("Color · Subtle") {
                VStack(alignment: .leading, spacing: VdSpacing.sm) {
                    HStack(spacing: VdSpacing.sm) {
                        VdButton(
                            "Primary",
                            color: .primary,
                            style: .subtle,
                            action: {}
                        )
                        VdButton(
                            "Neutral",
                            color: .neutral,
                            style: .subtle,
                            action: {}
                        )
                        VdButton(
                            "Error",
                            color: .error,
                            style: .subtle,
                            action: {}
                        )
                    }
                    HStack(spacing: VdSpacing.sm) {
                        VdButton(
                            "Success",
                            color: .success,
                            style: .subtle,
                            action: {}
                        )
                        VdButton(
                            "Warning",
                            color: .warning,
                            style: .subtle,
                            action: {}
                        )
                        VdButton(
                            "Info",
                            color: .info,
                            style: .subtle,
                            action: {}
                        )
                    }
                }
            }

            previewSection("Color · Outlined") {
                VStack(alignment: .leading, spacing: VdSpacing.sm) {
                    HStack(spacing: VdSpacing.sm) {
                        VdButton(
                            "Primary",
                            color: .primary,
                            style: .outlined,
                            action: {}
                        )
                        VdButton(
                            "Neutral",
                            color: .neutral,
                            style: .outlined,
                            action: {}
                        )
                        VdButton(
                            "Error",
                            color: .error,
                            style: .outlined,
                            action: {}
                        )
                    }
                    HStack(spacing: VdSpacing.sm) {
                        VdButton(
                            "Success",
                            color: .success,
                            style: .outlined,
                            action: {}
                        )
                        VdButton(
                            "Warning",
                            color: .warning,
                            style: .outlined,
                            action: {}
                        )
                        VdButton(
                            "Info",
                            color: .info,
                            style: .outlined,
                            action: {}
                        )
                    }
                }
            }

            previewSection("Color · Transparent") {
                VStack(alignment: .leading, spacing: VdSpacing.sm) {
                    HStack(spacing: VdSpacing.sm) {
                        VdButton(
                            "Primary",
                            color: .primary,
                            style: .transparent,
                            action: {}
                        )
                        VdButton(
                            "Neutral",
                            color: .neutral,
                            style: .transparent,
                            action: {}
                        )
                        VdButton(
                            "Error",
                            color: .error,
                            style: .transparent,
                            action: {}
                        )
                    }
                    HStack(spacing: VdSpacing.sm) {
                        VdButton(
                            "Success",
                            color: .success,
                            style: .transparent,
                            action: {}
                        )
                        VdButton(
                            "Warning",
                            color: .warning,
                            style: .transparent,
                            action: {}
                        )
                        VdButton(
                            "Info",
                            color: .info,
                            style: .transparent,
                            action: {}
                        )
                    }
                }
            }

            previewSection("Size") {
                HStack(alignment: .center, spacing: VdSpacing.sm) {
                    VdButton("Small", size: .small, action: {})
                    VdButton("Medium", size: .medium, action: {})
                    VdButton("Large", size: .large, action: {})
                }
            }

            previewSection("Rounded") {
                HStack(spacing: VdSpacing.sm) {
                    VdButton("Square", rounded: false, action: {})
                    VdButton("Pill", rounded: true, action: {})
                    VdButton(
                        "Outlined",
                        style: .outlined,
                        rounded: true,
                        action: {}
                    )
                }
            }

            previewSection("States") {
                HStack(spacing: VdSpacing.sm) {
                    VdButton("Enabled", action: {})
                    VdButton("Disabled", action: {}).disabled(true)
                    VdButton("Loading", isLoading: true, action: {})
                    VdButton(
                        "Loading",
                        color: .success,
                        isLoading: true,
                        action: {}
                    )
                }
            }

            previewSection("Full width") {
                VStack(spacing: VdSpacing.sm) {
                    VdButton(
                        "Continue",
                        size: .large,
                        fullWidth: true,
                        action: {}
                    )
                    VdButton(
                        "Go back",
                        style: .outlined,
                        size: .large,
                        fullWidth: true,
                        action: {}
                    )
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(VdSpacing.lg)
    }
    .background(Color.vdBackgroundDefaultBase)
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
