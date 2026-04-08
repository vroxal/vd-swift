// Components/Forms/VdBadge.swift — Vroxal Design

import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: — Variant enums
// ─────────────────────────────────────────────────────────────

public enum VdBadgeColor {
    case primary
    case success
    case error
    case warning
    case info
    case neutral
}

public enum VdBadgeStyle {
    case solid
    case subtle
}

public enum VdBadgeSize {
    case medium   // vertical padding: VdSpacing.xs (4pt)
    case small    // vertical padding: VdSpacing.xxs (2pt)
}

// ─────────────────────────────────────────────────────────────
// MARK: — Color tokens per variant
// ─────────────────────────────────────────────────────────────

private struct VdBadgeTokens {
    let background: Color
    let border:     Color?
    let text:       Color
}

private extension VdBadgeColor {
    func tokens(for style: VdBadgeStyle) -> VdBadgeTokens {
        switch style {

        // ── Solid ─────────────────────────────────────────────
        // bg   = Background/*/Base
        // border = none
        // text = Content/*/OnBase

        case .solid:
            switch self {
            case .primary: return VdBadgeTokens(
                background: .vdBackgroundPrimaryBase,
                border:     .vdBorderPrimaryBase,
                text:       .vdContentPrimaryOnBase
            )
            case .success: return VdBadgeTokens(
                background: .vdBackgroundSuccessBase,
                border:     .vdBorderSuccessBase,
                text:       .vdContentSuccessOnBase
            )
            case .error: return VdBadgeTokens(
                background: .vdBackgroundErrorBase,
                border:     .vdBorderErrorBase,
                text:       .vdContentErrorOnBase
            )
            case .warning: return VdBadgeTokens(
                background: .vdBackgroundWarningBase,
                border:     .vdBorderWarningBase,
                text:       .vdContentWarningOnBase
            )
            case .info: return VdBadgeTokens(
                background: .vdBackgroundInfoBase,
                border:     .vdBorderInfoBase,
                text:       .vdContentInfoOnBase
            )
            case .neutral: return VdBadgeTokens(
                background: .vdBackgroundNeutralBase,
                border:     .vdBorderNeutralBase,
                text:       .vdContentNeutralOnBase
            )
            }

        // ── Subtle ────────────────────────────────────────────
        // bg   = Background/*/Secondary
        // border = Border/*/Secondary
        // text = Content/*/OnSecondary

        case .subtle:
            switch self {
            case .primary: return VdBadgeTokens(
                background: .vdBackgroundPrimarySecondary,
                border:     .vdBorderPrimarySecondary,
                text:       .vdContentPrimaryOnSecondary
            )
            case .success: return VdBadgeTokens(
                background: .vdBackgroundSuccessSecondary,
                border:     .vdBorderSuccessSecondary,
                text:       .vdContentSuccessOnSecondary
            )
            case .error: return VdBadgeTokens(
                background: .vdBackgroundErrorSecondary,
                border:     .vdBorderErrorSecondary,
                text:       .vdContentErrorOnSecondary
            )
            case .warning: return VdBadgeTokens(
                background: .vdBackgroundWarningSecondary,
                border:     .vdBorderWarningSecondary,
                text:       .vdContentWarningOnSecondary
            )
            case .info: return VdBadgeTokens(
                background: .vdBackgroundInfoSecondary,
                border:     .vdBorderInfoSecondary,
                text:       .vdContentInfoOnSecondary
            )
            case .neutral: return VdBadgeTokens(
                background: .vdBackgroundNeutralSecondary,
                border:     .vdBorderNeutralSecondary,
                text:       .vdContentNeutralOnSecondary
            )
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdBadge
// ─────────────────────────────────────────────────────────────

public struct VdBadge: View {

    private let label:   String
    private let color:   VdBadgeColor
    private let style:   VdBadgeStyle
    private let size:    VdBadgeSize
    private let rounded: Bool

    public init(
        _ label:   String,
        color:     VdBadgeColor = .primary,
        style:     VdBadgeStyle = .subtle,
        size:      VdBadgeSize  = .medium,
        rounded:   Bool         = false
    ) {
        self.label   = label
        self.color   = color
        self.style   = style
        self.size    = size
        self.rounded = rounded
    }

    // ── Layout constants from Figma ───────────────────────────

    // Scale.Spacing.300 = 12pt — same for all variants
    private let horizontalPadding: CGFloat = VdSpacing.smMd

    // Scale.Spacing.100 = 4pt (medium) / Scale.Spacing.50 = 2pt (small)
    private var verticalPadding: CGFloat {
        size == .medium ? VdSpacing.xs : VdSpacing.xxs
    }

    // Scale.Border.Radius.sm = 8pt (square) / .full = 120pt (pill)
    private var cornerRadius: CGFloat {
        rounded ? VdRadius.full : VdRadius.sm
    }

    // ─────────────────────────────────────────────────────────

    public var body: some View {
        let tokens = color.tokens(for: style)

        Text(label)
            .vdFont(.labelSmall)
            .foregroundStyle(tokens.text)
            .lineLimit(1)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(tokens.background)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                if let borderColor = tokens.border {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(borderColor, lineWidth: VdBorderWidth.sm)
                }
            }
    }
}
