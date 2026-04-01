// Components/Forms/VdCheckbox.swift — Vroxal Design
// ─────────────────────────────────────────────────────────────

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
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in if !isPressed { isPressed = true } }
                .onEnded { _ in isPressed = false }
        )
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

// ─────────────────────────────────────────────────────────────
// MARK: — Preview
// ─────────────────────────────────────────────────────────────

#Preview("VdCheckbox — All Variants") {
    ScrollView {
        VStack(alignment: .leading, spacing: VdSpacing.xl) {

            previewSection("Default") {
                VdCheckbox(isChecked: .constant(false),
                    label: "Checkbox Label",
                    description: "Description for the checkbox goes here")
                VdCheckbox(isChecked: .constant(true),
                    label: "Checkbox Label",
                    description: "Description for the checkbox goes here")
                VdCheckbox(isChecked: .constant(false),
                    isIndeterminate: true,
                    label: "Checkbox Label",
                    description: "Description for the checkbox goes here")
            }

            previewSection("Disabled") {
                VdCheckbox(isChecked: .constant(false),
                    label: "Checkbox Label",
                    description: "Description for the checkbox goes here",
                    isDisabled: true)
                VdCheckbox(isChecked: .constant(true),
                    label: "Checkbox Label",
                    description: "Description for the checkbox goes here",
                    isDisabled: true)
                VdCheckbox(isChecked: .constant(false),
                    isIndeterminate: true,
                    label: "Checkbox Label",
                    description: "Description for the checkbox goes here",
                    isDisabled: true)
            }

            previewSection("No description") {
                VdCheckbox(isChecked: .constant(false), label: "Unchecked")
                VdCheckbox(isChecked: .constant(true),  label: "Checked")
                VdCheckbox(isChecked: .constant(false), isIndeterminate: true, label: "Indeterminate")
            }

            previewSection("No label or description") {
                HStack(spacing: VdSpacing.md) {
                    VdCheckbox(isChecked: .constant(false))
                    VdCheckbox(isChecked: .constant(true))
                    VdCheckbox(isChecked: .constant(false), isIndeterminate: true)
                }
            }

            previewSection("Interactive") {
                InteractiveCheckboxDemo()
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
            .vdFont(.labelSmall)
            .foregroundStyle(Color.vdContentDefaultTertiary)
        content()
    }
}

private struct InteractiveCheckboxDemo: View {
    @State private var option1 = false
    @State private var option2 = true
    @State private var option3 = false

    private var allChecked:    Bool { option1 && option2 && option3 }
    private var someChecked:   Bool { option1 || option2 || option3 }
    private var isIndeterminate: Bool { someChecked && !allChecked }

    var body: some View {
        VStack(alignment: .leading, spacing: VdSpacing.sm) {
            VdCheckbox(
                isChecked: Binding(get: { allChecked }, set: { val in
                    option1 = val; option2 = val; option3 = val
                }),
                isIndeterminate: isIndeterminate,
                label: "Select all"
            )
            Divider().padding(.vertical, VdSpacing.xs)
            VdCheckbox(isChecked: $option1, label: "Option one",   description: "First option")
            VdCheckbox(isChecked: $option2, label: "Option two",   description: "Second option")
            VdCheckbox(isChecked: $option3, label: "Option three", description: "Third option")
        }
        .padding(VdSpacing.md)
        .background(Color.vdBackgroundDefaultSecondary)
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
    }
}
