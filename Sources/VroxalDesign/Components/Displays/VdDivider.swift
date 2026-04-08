// Components/Display/VdDivider.swift — Vroxal Design

import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: — Enums
// ─────────────────────────────────────────────────────────────

public enum VdDividerOrientation {
    case horizontal
    case vertical
}

public enum VdDividerColor {
    case `default`
    case primary
    case neutral
    case success
    case error
    case warning
    case info
}

// ─────────────────────────────────────────────────────────────
// MARK: — Token resolution
// ─────────────────────────────────────────────────────────────

private extension VdDividerColor {
    var lineColor: Color {
        switch self {
        case .default: return .vdBorderDefaultTertiary
        case .primary: return .vdBorderPrimaryTertiary
        case .neutral: return .vdBorderNeutralTertiary
        case .success: return .vdBorderSuccessTertiary
        case .error:   return .vdBorderErrorTertiary
        case .warning: return .vdBorderWarningTertiary
        case .info:    return .vdBorderInfoTertiary
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdDivider
// ─────────────────────────────────────────────────────────────

public struct VdDivider: View {

    private let orientation:     VdDividerOrientation
    private let color:           VdDividerColor
    private let label:           String?
    private let labelAlignment:  HorizontalAlignment

    public init(
        orientation:    VdDividerOrientation = .horizontal,
        color:          VdDividerColor       = .default,
        label:          String?              = nil,
        labelAlignment: HorizontalAlignment  = .center
    ) {
        self.orientation    = orientation
        self.color          = color
        self.label          = label
        self.labelAlignment = labelAlignment
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Body
    // ─────────────────────────────────────────────────────────

    public var body: some View {
        switch orientation {
        case .horizontal:
            horizontalDivider
        case .vertical:
            verticalDivider
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Horizontal
    // ─────────────────────────────────────────────────────────

    private var horizontalDivider: some View {
        Group {
            if let text = label {
                switch labelAlignment {
                case .leading:
                    labelLeading(text: text)
                case .trailing:
                    labelTrailing(text: text)
                default:
                    labelCentered(text: text)
                }
            } else {
                rule
            }
        }
    }

    // ── No label — single full-width rule ─────────────────────
    private var rule: some View {
        Rectangle()
            .fill(color.lineColor)
            .frame(height: VdBorderWidth.sm)
            .frame(maxWidth: .infinity)
    }

    // ── Label centred ─────────────────────────────────────────
    // ───────  Label  ───────
    private func labelCentered(text: String) -> some View {
        HStack(spacing: VdSpacing.sm) {
            rule
            labelText(text)
            rule
        }
    }

    // ── Label leading ─────────────────────────────────────────
    // Label  ─────────────────
    private func labelLeading(text: String) -> some View {
        HStack(spacing: VdSpacing.sm) {
            labelText(text)
            rule
        }
    }

    // ── Label trailing ────────────────────────────────────────
    // ─────────────────  Label
    private func labelTrailing(text: String) -> some View {
        HStack(spacing: VdSpacing.sm) {
            rule
            labelText(text)
        }
    }

    // ── Label text ────────────────────────────────────────────
    private func labelText(_ text: String) -> some View {
        Text(text)
            .vdFont(.bodySmall)
            .foregroundStyle(Color.vdContentDefaultTertiary)
            .fixedSize()
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Vertical
    // ─────────────────────────────────────────────────────────

    private var verticalDivider: some View {
        Rectangle()
            .fill(color.lineColor)
            .frame(width: VdBorderWidth.sm)
            .frame(maxHeight: .infinity)
    }
}
