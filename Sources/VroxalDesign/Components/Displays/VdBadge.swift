//
//  VdBadge.swift
//  VroxalDesign
//
//  Created by Pramod Paudel on 16/03/2026.
//


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

// ─────────────────────────────────────────────────────────────
// MARK: — Preview
// ─────────────────────────────────────────────────────────────

#Preview("VdBadge — All Variants") {
    ScrollView {
        VStack(alignment: .leading, spacing: VdSpacing.lg) {

            // ── Subtle / Medium / Square ──────────────────────
            badgeSection("Subtle · Medium · Square") {
                VdBadge("Primary", color: .primary, style: .subtle)
                VdBadge("Success", color: .success, style: .subtle)
                VdBadge("Error",   color: .error,   style: .subtle)
                VdBadge("Warning", color: .warning, style: .subtle)
                VdBadge("Info",    color: .info,    style: .subtle)
                VdBadge("Neutral", color: .neutral, style: .subtle)
            }

            // ── Solid / Medium / Square ───────────────────────
            badgeSection("Solid · Medium · Square") {
                VdBadge("Primary", color: .primary, style: .solid)
                VdBadge("Success", color: .success, style: .solid)
                VdBadge("Error",   color: .error,   style: .solid)
                VdBadge("Warning", color: .warning, style: .solid)
                VdBadge("Info",    color: .info,    style: .solid)
                VdBadge("Neutral", color: .neutral, style: .solid)
            }

            // ── Subtle / Small / Square ───────────────────────
            badgeSection("Subtle · Small · Square") {
                VdBadge("Primary", color: .primary, style: .subtle, size: .small)
                VdBadge("Success", color: .success, style: .subtle, size: .small)
                VdBadge("Error",   color: .error,   style: .subtle, size: .small)
                VdBadge("Warning", color: .warning, style: .subtle, size: .small)
                VdBadge("Info",    color: .info,    style: .subtle, size: .small)
                VdBadge("Neutral", color: .neutral, style: .subtle, size: .small)
            }

            // ── Solid / Small / Square ────────────────────────
            badgeSection("Solid · Small · Square") {
                VdBadge("Primary", color: .primary, style: .solid, size: .small)
                VdBadge("Success", color: .success, style: .solid, size: .small)
                VdBadge("Error",   color: .error,   style: .solid, size: .small)
                VdBadge("Warning", color: .warning, style: .solid, size: .small)
                VdBadge("Info",    color: .info,    style: .solid, size: .small)
                VdBadge("Neutral", color: .neutral, style: .solid, size: .small)
            }

            // ── Subtle / Medium / Rounded ─────────────────────
            badgeSection("Subtle · Medium · Rounded") {
                VdBadge("Primary", color: .primary, style: .subtle, rounded: true)
                VdBadge("Success", color: .success, style: .subtle, rounded: true)
                VdBadge("Error",   color: .error,   style: .subtle, rounded: true)
                VdBadge("Warning", color: .warning, style: .subtle, rounded: true)
                VdBadge("Info",    color: .info,    style: .subtle, rounded: true)
                VdBadge("Neutral", color: .neutral, style: .subtle, rounded: true)
            }

            // ── Solid / Medium / Rounded ──────────────────────
            badgeSection("Solid · Medium · Rounded") {
                VdBadge("Primary", color: .primary, style: .solid, rounded: true)
                VdBadge("Success", color: .success, style: .solid, rounded: true)
                VdBadge("Error",   color: .error,   style: .solid, rounded: true)
                VdBadge("Warning", color: .warning, style: .solid, rounded: true)
                VdBadge("Info",    color: .info,    style: .solid, rounded: true)
                VdBadge("Neutral", color: .neutral, style: .solid, rounded: true)
            }

            // ── Subtle / Small / Rounded ──────────────────────
            badgeSection("Subtle · Small · Rounded") {
                VdBadge("Primary", color: .primary, style: .subtle, size: .small, rounded: true)
                VdBadge("Success", color: .success, style: .subtle, size: .small, rounded: true)
                VdBadge("Error",   color: .error,   style: .subtle, size: .small, rounded: true)
                VdBadge("Warning", color: .warning, style: .subtle, size: .small, rounded: true)
                VdBadge("Info",    color: .info,    style: .subtle, size: .small, rounded: true)
                VdBadge("Neutral", color: .neutral, style: .subtle, size: .small, rounded: true)
            }

            // ── Solid / Small / Rounded ───────────────────────
            badgeSection("Solid · Small · Rounded") {
                VdBadge("Primary", color: .primary, style: .solid, size: .small, rounded: true)
                VdBadge("Success", color: .success, style: .solid, size: .small, rounded: true)
                VdBadge("Error",   color: .error,   style: .solid, size: .small, rounded: true)
                VdBadge("Warning", color: .warning, style: .solid, size: .small, rounded: true)
                VdBadge("Info",    color: .info,    style: .solid, size: .small, rounded: true)
                VdBadge("Neutral", color: .neutral, style: .solid, size: .small, rounded: true)
            }
        }
        .padding(VdSpacing.lg)
    }
    .background(Color.vdBackgroundDefaultBase)
}

// Preview helper
private func badgeSection<Content: View>(
    _ title: String,
    @ViewBuilder content: () -> Content
) -> some View {
    VStack(alignment: .leading, spacing: VdSpacing.sm) {
        Text(title)
            .vdFont(.labelSmall)
            .foregroundStyle(Color.vdContentDefaultTertiary)
        FlowLayout(spacing: VdSpacing.xs) {
            content()
        }
    }
}

// Simple flow/wrap layout for the preview
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0 }.reduce(0) { $0 + $1 + spacing } - spacing
        return CGSize(width: proposal.width ?? 0, height: max(height, 0))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: ProposedViewSize(width: bounds.width, height: nil), subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        var rows: [[LayoutSubview]] = [[]]
        var x: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity
        for subview in subviews {
            let width = subview.sizeThatFits(.unspecified).width
            if x + width > maxWidth && !rows[rows.count - 1].isEmpty {
                rows.append([])
                x = 0
            }
            rows[rows.count - 1].append(subview)
            x += width + spacing
        }
        return rows
    }
}
