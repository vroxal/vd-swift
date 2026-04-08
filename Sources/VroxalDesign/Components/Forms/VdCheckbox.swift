// Components/Forms/VdCheckbox.swift — Vroxal Design

import SwiftUI

public struct VdCheckbox: View {

    @Binding private var isChecked:      Bool
    private  let isIndeterminate:        Bool
    private  let label:                  String?
    private  let description:            String?
    private  let isDisabled:             Bool

    @FocusState private var isFocused:   Bool
    @State    private var isPressed:     Bool = false

    public init(
        isChecked:       Binding<Bool>,
        isIndeterminate: Bool    = false,
        label:           String? = nil,
        description:     String? = nil,
        isDisabled:      Bool    = false
    ) {
        self._isChecked      = isChecked
        self.isIndeterminate = isIndeterminate
        self.label           = label
        self.description     = description
        self.isDisabled      = isDisabled
    }

    // ── Derived state ────────────────────────────────────────
    private var isFilled: Bool { isChecked || isIndeterminate }

    // ─────────────────────────────────────────────────────────
    // MARK: Body
    // ─────────────────────────────────────────────────────────

    public var body: some View {
        Button(action: toggle) {
            HStack(alignment: .top, spacing: VdSpacing.sm) {    // Spacing.200 = 8pt
                checkboxControl
                if label != nil || description != nil {
                    labelStack
                }
            }
        }
        .buttonStyle(.plain)
        .focused($isFocused)
        .disabled(isDisabled)

    }

    // ─────────────────────────────────────────────────────────
    // MARK: Checkbox control (20×20)
    // ─────────────────────────────────────────────────────────

    private var checkboxControl: some View {
        ZStack {
            // ── Base square ────────────────────────────────
            RoundedRectangle(cornerRadius: VdRadius.xs)   // radius/xs = 4pt
                .fill(boxBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: VdRadius.xs)
                        .strokeBorder(boxBorder, lineWidth: VdBorderWidth.sm)
                        .opacity(isFilled ? 0 : 1)
                }

            // ── Check mark ─────────────────────────────────
            if isChecked && !isIndeterminate {
                VdIcon("vd:check", size: 20, color: .vdContentDefaultAlwaysLight)
            }

            // ── Indeterminate dash ──────────────────────────
            if isIndeterminate {
                VdIcon("vd:minus", size: 20, color: .vdContentDefaultAlwaysLight)
            
            }

            // ── Focus ring (2pt, inset -2pt) ─────────────────
            if isFocused {
                RoundedRectangle(cornerRadius: VdRadius.xs + 2)
                    .strokeBorder(Color.vdBorderPrimaryTertiary, lineWidth: VdBorderWidth.md)
                    .padding(-2)
            }
        }
        .frame(width: 20, height: 20)           // Scale.Icon.Size.sm = 20pt
        .padding(2)                              // Scale.Spacing.50 = 2pt (icon container)
        .opacity(isDisabled ? 0.4 : 1.0)
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Label + description
    // ─────────────────────────────────────────────────────────

    private var labelStack: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let text = label {
                Text(text)
                    .vdFont(.labelMedium)
                    .foregroundStyle(labelColor)
            }
            if let desc = description {
                Text(desc)
                    .vdFont(.bodyMedium)
                    .foregroundStyle(descriptionColor)
            }
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Derived tokens
    // ─────────────────────────────────────────────────────────

    private var boxBackground: Color {
        guard !isDisabled else {
            return isFilled
                ? .vdBackgroundPrimaryBase        // checked disabled = filled, opacity applied above
                : .vdBackgroundDefaultDisabled
        }
        if isFilled {
            return isPressed
                ? .vdBackgroundPrimaryBaseHover
                : .vdBackgroundPrimaryBase
        } else {
            return isPressed
                ? .vdBackgroundPrimarySecondary
                : .vdBackgroundDefaultSecondary
        }
    }

    private var boxBorder: Color {
        guard !isDisabled else { return .vdBorderDefaultTertiary }
        if isPressed { return .vdBorderPrimaryBase }
        if isFocused { return .vdBorderDefaultBase }
        return .vdBorderDefaultSecondary
    }

    private var labelColor: Color {
        if isDisabled { return .vdContentDefaultDisabled }
        if isPressed || isFocused { return .vdContentDefaultBase }
        return .vdContentDefaultSecondary
    }

    private var descriptionColor: Color {
        if isDisabled { return .vdContentDefaultDisabled }
        if isPressed || isFocused { return .vdContentDefaultSecondary }
        return .vdContentDefaultTertiary
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Action
    // ─────────────────────────────────────────────────────────

    private func toggle() {
        guard !isDisabled && !isIndeterminate else { return }
        isChecked.toggle()
    }
}
