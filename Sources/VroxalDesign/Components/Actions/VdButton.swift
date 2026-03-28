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
    case small  // height 32pt  · py 4   · px 12 · icon container 16
    case medium  // height 48pt  · py 12  · px 24 · icon container 24
    case large  // height 56pt  · py 16  · px 24 · icon container 32
}

// ─────────────────────────────────────────────────────────────
// MARK: — Token resolution
// ─────────────────────────────────────────────────────────────

private struct VdButtonTokens {
    let background: Color
    let border: Color?  // nil = no border
    let label: Color
    let hoverBg: Color  // used on press (iOS "hover" equivalent)
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
                    border: nil,
                    label: .vdContentPrimaryOnBase,
                    hoverBg: .vdBackgroundPrimaryBaseHover
                )
            case .neutral:
                return VdButtonTokens(
                    background: .vdBackgroundNeutralBase,
                    border: nil,
                    label: .vdContentNeutralOnBase,
                    hoverBg: .vdBackgroundNeutralBaseHover
                )
            case .error:
                return VdButtonTokens(
                    background: .vdBackgroundErrorBase,
                    border: nil,
                    label: .vdContentErrorOnBase,
                    hoverBg: .vdBackgroundErrorBaseHover
                )
            case .success:
                return VdButtonTokens(
                    background: .vdBackgroundSuccessBase,
                    border: nil,
                    label: .vdContentSuccessOnBase,
                    hoverBg: .vdBackgroundSuccessBaseHover
                )
            case .warning:
                return VdButtonTokens(
                    background: .vdBackgroundWarningBase,
                    border: nil,
                    label: .vdContentWarningOnBase,
                    hoverBg: .vdBackgroundWarningBaseHover
                )
            case .info:
                return VdButtonTokens(
                    background: .vdBackgroundInfoBase,
                    border: nil,
                    label: .vdContentInfoOnBase,
                    hoverBg: .vdBackgroundInfoBaseHover
                )
            }

        case .subtle:
            switch self {
            case .primary:
                return VdButtonTokens(
                    background: .vdBackgroundPrimarySecondary,
                    border: nil,
                    label: .vdContentPrimaryOnSecondary,
                    hoverBg: .vdBackgroundPrimarySecondaryHover
                )
            case .neutral:
                return VdButtonTokens(
                    background: .vdBackgroundNeutralSecondary,
                    border: nil,
                    label: .vdContentNeutralOnSecondary,
                    hoverBg: .vdBackgroundNeutralSecondaryHover
                )
            case .error:
                return VdButtonTokens(
                    background: .vdBackgroundErrorSecondary,
                    border: nil,
                    label: .vdContentErrorOnSecondary,
                    hoverBg: .vdBackgroundErrorSecondaryHover
                )
            case .success:
                return VdButtonTokens(
                    background: .vdBackgroundSuccessSecondary,
                    border: nil,
                    label: .vdContentSuccessOnSecondary,
                    hoverBg: .vdBackgroundSuccessSecondaryHover
                )
            case .warning:
                return VdButtonTokens(
                    background: .vdBackgroundWarningSecondary,
                    border: nil,
                    label: .vdContentWarningOnSecondary,
                    hoverBg: .vdBackgroundWarningSecondaryHover
                )
            case .info:
                return VdButtonTokens(
                    background: .vdBackgroundInfoSecondary,
                    border: nil,
                    label: .vdContentInfoOnSecondary,
                    hoverBg: .vdBackgroundInfoSecondaryHover
                )
            }

        case .outlined:
            switch self {
            case .primary:
                return VdButtonTokens(
                    background: .clear,
                    border: .vdBorderPrimaryBase,
                    label: .vdContentPrimaryBase,
                    hoverBg: .vdBackgroundPrimarySecondary
                )
            case .neutral:
                return VdButtonTokens(
                    background: .clear,
                    border: .vdBorderNeutralBase,
                    label: .vdContentNeutralBase,
                    hoverBg: .vdBackgroundNeutralSecondary
                )
            case .error:
                return VdButtonTokens(
                    background: .clear,
                    border: .vdBorderErrorBase,
                    label: .vdContentErrorBase,
                    hoverBg: .vdBackgroundErrorSecondary
                )
            case .success:
                return VdButtonTokens(
                    background: .clear,
                    border: .vdBorderSuccessBase,
                    label: .vdContentSuccessBase,
                    hoverBg: .vdBackgroundSuccessSecondary
                )
            case .warning:
                return VdButtonTokens(
                    background: .clear,
                    border: .vdBorderWarningBase,
                    label: .vdContentWarningBase,
                    hoverBg: .vdBackgroundWarningSecondary
                )
            case .info:
                return VdButtonTokens(
                    background: .clear,
                    border: .vdBorderInfoBase,
                    label: .vdContentInfoBase,
                    hoverBg: .vdBackgroundInfoSecondary
                )
            }

        case .transparent:
            switch self {
            case .primary:
                return VdButtonTokens(
                    background: .clear,
                    border: nil,
                    label: .vdContentPrimaryBase,
                    hoverBg: .vdBackgroundPrimarySecondary
                )
            case .neutral:
                return VdButtonTokens(
                    background: .clear,
                    border: nil,
                    label: .vdContentNeutralBase,
                    hoverBg: .vdBackgroundNeutralSecondary
                )
            case .error:
                return VdButtonTokens(
                    background: .clear,
                    border: nil,
                    label: .vdContentErrorBase,
                    hoverBg: .vdBackgroundErrorSecondary
                )
            case .success:
                return VdButtonTokens(
                    background: .clear,
                    border: nil,
                    label: .vdContentSuccessBase,
                    hoverBg: .vdBackgroundSuccessSecondary
                )
            case .warning:
                return VdButtonTokens(
                    background: .clear,
                    border: nil,
                    label: .vdContentWarningBase,
                    hoverBg: .vdBackgroundWarningSecondary
                )
            case .info:
                return VdButtonTokens(
                    background: .clear,
                    border: nil,
                    label: .vdContentInfoBase,
                    hoverBg: .vdBackgroundInfoSecondary
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
        case .small: return VdSpacing.sm  // 8pt
        case .medium: return VdSpacing.smMd  // 12pt
        case .large: return VdSpacing.smMd  // 12pt
        }
    }

    fileprivate var horizontalPadding: CGFloat {
        switch self {
        case .small: return VdSpacing.md  // 16pt
        case .medium: return VdSpacing.lg  // 24pt
        case .large: return VdSpacing.xl  // 32pt
        }
    }

    fileprivate var iconSize: CGFloat {
        switch self {
        case .small: return VdIconSize.xs  // 16pt
        case .medium: return VdIconSize.md  // 24pt
        case .large: return VdIconSize.lg  // 32pt
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
        case .large: return VdSpacing.xs  // 4pt
        }
    }

    fileprivate var defaultRadius: CGFloat {
        switch self {
        case .small, .medium: return VdRadius.md  // 8pt
        case .large: return VdRadius.lg  // 16pt
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
        .buttonStyle(VdButtonPressStyle(tokens: color.tokens(for: style)))
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
                    VdIcon(icon, size: size.iconSize, color: tokens.label)
                }

                Text(label)
                    .vdFont(size.labelStyle)
                    .foregroundStyle(tokens.label)
                    .lineLimit(1)
                    .padding(.vertical, size.labelVerticalPadding)

                if let icon = rightIcon {
                    VdIcon(icon, size: size.iconSize, color: tokens.label)

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
        .background(tokens.background)
        .clipShape(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        )
        .overlay {
            if let borderColor = tokens.border {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: VdBorderWidth.sm)
            }
        }
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

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
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
