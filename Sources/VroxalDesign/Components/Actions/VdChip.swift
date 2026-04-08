// Components/Actions/VdChip.swift — Vroxal Design System

import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: — VdChip
// ─────────────────────────────────────────────────────────────

public struct VdChip: View {

    private let label: String
    private let icon: String?           // optional leading icon
    private let isSelected: Bool
    private let closable: Bool
    private let onTap: (() -> Void)?
    private let onClose: (() -> Void)?

    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isFocused: Bool
    private let _backCompatDisabled: Bool

    public init(
        _ label: String,
        icon: String? = nil,
        isSelected: Bool = false,
        closable: Bool = false,
        isDisabled: Bool = false,
        onTap: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil
    ) {
        self.label = label
        self.icon = icon
        self.isSelected = isSelected
        self.closable = closable
        self._backCompatDisabled = isDisabled
        self.onTap = onTap
        self.onClose = onClose
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Body
    // ─────────────────────────────────────────────────────────

    public var body: some View {
        Button { onTap?() } label: {
            HStack(spacing: 0) {
                if let icon {
                    // Color is applied via foregroundStyle in the ButtonStyle
                    VdIcon(icon, size: VdIconSize.md)
                }
                Text(label)
                    .vdFont(.labelMedium)
                    .padding(.horizontal, VdSpacing.xs)
                    .lineLimit(1)
                if closable {
                    // Reserve trailing space for the overlaid close button
                    Color.clear
                        .frame(width: VdIconSize.md + VdSpacing.xs * 2)
                }
            }
            .padding(.vertical, VdSpacing.xs)
            .padding(.leading, VdSpacing.sm)
            .padding(.trailing, closable ? 0 : VdSpacing.sm)
            // Close button overlaid at trailing edge, inside label so it
            // intercepts taps before the outer chip button receives them.
            .overlay(alignment: .trailing) {
                if closable {
                    Button { onClose?() } label: {
                        VdIcon("vd:xmark", size: VdIconSize.md)
                            .padding(VdSpacing.xs)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .buttonStyle(
            VdChipButtonStyle(
                backgroundColor: backgroundColor,
                hoverBackgroundColor: hoverBackgroundColor,
                borderColor: borderColor,
                contentColor: { isPressed in contentColor(isPressed: isPressed) },
                visualOpacity: visualOpacity
            )
        )
        .overlay {
            if isFocused {
                RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
                    .strokeBorder(Color.vdBorderPrimaryTertiary, lineWidth: VdBorderWidth.md)
                    .padding(-3)
            }
        }
        .focused($isFocused)
        .disabled(_backCompatDisabled)
        .animation(.easeInOut(duration: 0.12), value: isEnabled)
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Derived tokens
    // ─────────────────────────────────────────────────────────

    private var isVisuallyDisabled: Bool {
        !isEnabled || _backCompatDisabled
    }

    /// Only selected + disabled dims the whole chip (unselected disabled uses different bg/border).
    private var visualOpacity: Double {
        isSelected && isVisuallyDisabled ? 0.4 : 1.0
    }

    private func contentColor(isPressed: Bool) -> Color {
        if isSelected {
            return .vdContentPrimaryOnSecondary
        } else if isVisuallyDisabled {
            return .vdContentDefaultDisabled
        } else {
            return isPressed ? .vdContentNeutralOnSecondary : .vdContentDefaultSecondary
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return .vdBackgroundPrimarySecondary
        } else if isVisuallyDisabled {
            return .vdBackgroundDefaultDisabled
        } else {
            return .vdBackgroundNeutralSecondary
        }
    }

    private var hoverBackgroundColor: Color {
        if isSelected {
            return .vdBackgroundPrimarySecondaryHover
        } else if isVisuallyDisabled {
            return .vdBackgroundDefaultDisabled
        } else {
            return .vdBackgroundNeutralSecondaryHover
        }
    }

    private var borderColor: Color {
        if isSelected {
            return .vdBorderPrimarySecondary
        } else if isVisuallyDisabled {
            return .vdBorderDefaultTertiary
        } else {
            return .vdBorderDefaultSecondary
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdChipButtonStyle
// ─────────────────────────────────────────────────────────────

private struct VdChipButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let hoverBackgroundColor: Color
    let borderColor: Color
    let contentColor: (Bool) -> Color
    let visualOpacity: Double

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        configuration.label
            .foregroundStyle(contentColor(isPressed))
            .background(
                RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
                    .fill(isPressed ? hoverBackgroundColor : backgroundColor)
            )
            .overlay {
                RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: VdBorderWidth.sm)
            }
            .opacity(visualOpacity)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: isPressed)
    }
}
