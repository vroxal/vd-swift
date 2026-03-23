// Components/Display/VdDivider.swift — Vroxal Design
// ─────────────────────────────────────────────────────────────
// Figma source: node Display/Divider
//
// A horizontal or vertical rule for separating content regions.
// Supports an optional centred label for section breaks.
//
// VARIANTS
//   VdDividerOrientation — horizontal · vertical
//   VdDividerColor       — default · primary · neutral
//                          success · error · warning · info
//
// TOKEN PATTERN
//   default  → Border/Default/Tertiary    (lightest rule — most common)
//   primary  → Border/Primary/Tertiary
//   neutral  → Border/Neutral/Tertiary
//   success  → Border/Success/Tertiary
//   error    → Border/Error/Tertiary
//   warning  → Border/Warning/Tertiary
//   info     → Border/Info/Tertiary
//
// LABEL (horizontal only)
//   Text uses Body/Small · ContentDefaultTertiary
//   Lines use Border/Default/Tertiary regardless of divider color
//   Gaps between line and label: VdSpacing.sm (8pt)
//
// THICKNESS
//   Always VdBorderWidth.sm (1pt) — matches Figma
//
// LAYOUT — horizontal
//   ────────────────────────────────  (no label)
//   ───────────  Label  ─────────────  (with label, centred)
//   Label  ─────────────────────────  (with label, leading)
//   ─────────────────────────  Label  (with label, trailing)
//
// LAYOUT — vertical
//   A thin 1pt vertical rule. Height is driven by the parent container.
//   (Labels are not supported on vertical dividers.)
//
// USAGE
//   // Simple horizontal rule
//   VdDivider()
//
//   // With centred label
//   VdDivider(label: "or continue with")
//
//   // Leading label
//   VdDivider(label: "Section title", labelAlignment: .leading)
//
//   // Colored rule
//   VdDivider(color: .primary)
//
//   // Vertical
//   VdDivider(orientation: .vertical)
//       .frame(height: 24)
// ─────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────
// MARK: — Preview
// ─────────────────────────────────────────────────────────────

#Preview("VdDivider — All Variants") {
    ScrollView {
        VStack(alignment: .leading, spacing: VdSpacing.xl) {

            // ── Horizontal — no label ─────────────────────────
            previewSection("Horizontal — Default") {
                VdDivider()
            }

            // ── Colors ────────────────────────────────────────
            previewSection("Colors") {
                VStack(spacing: VdSpacing.md) {
                    VdDivider(color: .default)
                    VdDivider(color: .primary)
                    VdDivider(color: .neutral)
                    VdDivider(color: .success)
                    VdDivider(color: .error)
                    VdDivider(color: .warning)
                    VdDivider(color: .info)
                }
            }

            // ── Label — centred ───────────────────────────────
            previewSection("Label · Center (default)") {
                VdDivider(label: "or continue with")
            }

            // ── Label — leading ───────────────────────────────
            previewSection("Label · Leading") {
                VdDivider(label: "Section title", labelAlignment: .leading)
            }

            // ── Label — trailing ──────────────────────────────
            previewSection("Label · Trailing") {
                VdDivider(label: "End of list", labelAlignment: .trailing)
            }

            // ── Colored with label ────────────────────────────
            previewSection("Colored with label") {
                VStack(spacing: VdSpacing.md) {
                    VdDivider(color: .primary, label: "Primary")
                    VdDivider(color: .success, label: "Success")
                    VdDivider(color: .error,   label: "Error")
                    VdDivider(color: .warning, label: "Warning")
                    VdDivider(color: .info,    label: "Info")
                }
            }

            // ── Vertical ──────────────────────────────────────
            previewSection("Vertical") {
                HStack(spacing: VdSpacing.lg) {
                    Text("Left")
                        .vdFont(.bodyMedium)
                        .foregroundStyle(Color.vdContentDefaultBase)

                    VdDivider(orientation: .vertical)
                        .frame(height: 20)

                    Text("Middle")
                        .vdFont(.bodyMedium)
                        .foregroundStyle(Color.vdContentDefaultBase)

                    VdDivider(orientation: .vertical)
                        .frame(height: 20)

                    Text("Right")
                        .vdFont(.bodyMedium)
                        .foregroundStyle(Color.vdContentDefaultBase)
                }
            }

            // ── Vertical colors ───────────────────────────────
            previewSection("Vertical · Colors") {
                HStack(spacing: VdSpacing.lg) {
                    ForEach(
                        [VdDividerColor.default, .primary, .success, .error, .warning, .info],
                        id: \.tokenName
                    ) { c in
                        VdDivider(orientation: .vertical, color: c)
                            .frame(height: 24)
                    }
                }
            }

            // ── In context — list separation ──────────────────
            previewSection("In context — list rows") {
                VStack(spacing: VdSpacing.none) {
                    ForEach(["Notifications", "Appearance", "Privacy", "Help"], id: \.self) { item in
                        HStack {
                            Text(item)
                                .vdFont(.bodyMedium)
                                .foregroundStyle(Color.vdContentDefaultBase)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.vdContentDefaultTertiary)
                        }
                        .padding(.vertical, VdSpacing.smMd)
                        .padding(.horizontal, VdSpacing.md)

                        if item != "Help" {
                            VdDivider()
                                .padding(.leading, VdSpacing.md)
                        }
                    }
                }
                .background(Color.vdBackgroundDefaultSecondary)
                .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
            }

            // ── In context — sign in separator ────────────────
            previewSection("In context — auth separator") {
                VStack(spacing: VdSpacing.lg) {
                    VdButton("Continue with email", action: {})
                        .frame(maxWidth: .infinity)
                    VdDivider(label: "or")
                    VdButton("Continue with Apple",
                             color: .neutral,
                             style: .outlined,
                             leftIcon: "apple.logo",
                             action: {})
                        .frame(maxWidth: .infinity)
                }
                .padding(VdSpacing.md)
                .background(Color.vdBackgroundDefaultSecondary)
                .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
            }
        }
        .padding(VdSpacing.lg)
    }
    .background(Color.vdBackgroundDefaultBase)
}

// ── Preview helpers ───────────────────────────────────────────

private func previewSection<Content: View>(
    _ title: String,
    @ViewBuilder content: () -> Content
) -> some View {
    VStack(alignment: .leading, spacing: VdSpacing.sm) {
        Text(title)
            .vdFont(.labelSmall)
            .foregroundStyle(Color.vdContentDefaultTertiary)
        content()
    }
}

// Needed for ForEach in the vertical colors preview
private extension VdDividerColor {
    var tokenName: String {
        switch self {
        case .default: return "default"
        case .primary: return "primary"
        case .neutral: return "neutral"
        case .success: return "success"
        case .error:   return "error"
        case .warning: return "warning"
        case .info:    return "info"
        }
    }
}
