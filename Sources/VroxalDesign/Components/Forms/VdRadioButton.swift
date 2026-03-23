// Components/Forms/VdRadioButton.swift — Vroxal Design
// ─────────────────────────────────────────────────────────────
// Figma source: node 279-6336
//
// USAGE — individual
//   VdRadioButton(isSelected: $selected, label: "Option A")
//
// USAGE — group (bind all to the same @State value)
//   @State private var pick = "a"
//   VdRadioButton(isSelected: Binding(get: { pick=="a" }, set: { if $0 { pick="a" } }),
//       label: "Option A")
//   VdRadioButton(isSelected: Binding(get: { pick=="b" }, set: { if $0 { pick="b" } }),
//       label: "Option B")
//
// STATES → TOKEN MAPPING
//   Unselected/Default  ring=BorderDefaultSecondary  bg=BackgroundDefaultSecondary
//   Unselected/Pressed  ring=BorderPrimaryBase       bg=BackgroundPrimarySecondary
//   Unselected/Focus    ring=BorderDefaultSecondary  bg=BackgroundDefaultSecondary  +focus ring
//   Unselected/Disabled ring=BorderDefaultTertiary   bg=BackgroundDefaultDisabled   opacity 0.4
//   Selected/Default    ring=BorderPrimaryBase       bg=BackgroundDefaultSecondary  dot=BackgroundPrimaryBase
//   Selected/Pressed    ring=BorderPrimarySecondary  bg=BackgroundDefaultSecondary  dot=BackgroundPrimaryBaseHover
//   Selected/Focus      ring=BorderPrimaryBase       bg=BackgroundDefaultSecondary  dot=BackgroundPrimaryBase  +focus ring
//   Selected/Disabled   ring=BorderPrimaryBase       bg=BackgroundDefaultSecondary  dot=BackgroundPrimaryBase  opacity 0.4
//   Focus ring          BorderPrimaryTertiary · 2pt · full radius
//
// LABEL COLOURS (same as VdCheckbox)
//   Default   → ContentDefaultSecondary
//   Pressed / Focus → ContentDefaultBase
//   Disabled  → ContentDefaultDisabled
// ─────────────────────────────────────────────────────────────

import SwiftUI

public struct VdRadioButton: View {

    @Binding private var isSelected:  Bool
    private  let label:               String?
    private  let description:         String?
    private  let isDisabled:          Bool

    @FocusState private var isFocused: Bool
    @State    private var isPressed:   Bool = false

    public init(
        isSelected:  Binding<Bool>,
        label:       String? = nil,
        description: String? = nil,
        isDisabled:  Bool    = false
    ) {
        self._isSelected = isSelected
        self.label       = label
        self.description = description
        self.isDisabled  = isDisabled
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Body
    // ─────────────────────────────────────────────────────────

    public var body: some View {
        Button(action: select) {
            HStack(alignment: .top, spacing: VdSpacing.sm) {    // Spacing.200 = 8pt
                radioControl
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
    // MARK: Radio control (20×20, full radius)
    // ─────────────────────────────────────────────────────────

    private var radioControl: some View {
        ZStack {
            // ── Outer ring ─────────────────────────────────
            Circle()
                .fill(ringBackground)
                .overlay {
                    Circle()
                        .strokeBorder(ringBorder, lineWidth: VdBorderWidth.sm)
                }

            // ── Inner dot (12×12 when selected) ────────────
            if isSelected {
                Circle()
                    .fill(dotColor)
                    .frame(width: 12, height: 12)
            }

            // ── Focus ring (2pt, inset -3pt) ──────────────
            if isFocused {
                Circle()
                    .strokeBorder(Color.vdBorderPrimaryTertiary, lineWidth: VdBorderWidth.md)
                    .padding(-3)
            }
        }
        .frame(width: 20, height: 20)       // Scale.Icon.Size.sm = 20pt
        .padding(2)                          // Scale.Spacing.50 = 2pt (icon container)
        .opacity(isDisabled ? 0.4 : 1.0)
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Label + description
    // ─────────────────────────────────────────────────────────

    private var labelStack: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let text = label {
                Text(text)
                    .vdFont(VdFont.labelMedium)
                    .foregroundStyle(labelColor)
            }
            if let desc = description {
                Text(desc)
                    .vdFont(VdFont.bodySmall)
                    .foregroundStyle(descriptionColor)
            }
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Derived tokens
    // ─────────────────────────────────────────────────────────

    private var ringBackground: Color {
        guard !isDisabled else {
            return isSelected ? .vdBackgroundDefaultSecondary : .vdBackgroundDefaultDisabled
        }
        if !isSelected && isPressed { return .vdBackgroundPrimarySecondary }
        return .vdBackgroundDefaultSecondary
    }

    private var ringBorder: Color {
        guard !isDisabled else {
            return isSelected ? .vdBorderPrimaryBase : .vdBorderDefaultTertiary
        }
        if isSelected {
            return isPressed ? .vdBorderPrimarySecondary : .vdBorderPrimaryBase
        } else {
            return isPressed ? .vdBorderPrimaryBase : .vdBorderDefaultSecondary
        }
    }

    private var dotColor: Color {
        isPressed ? .vdBackgroundPrimaryBaseHover : .vdBackgroundPrimaryBase
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

    private func select() {
        guard !isDisabled else { return }
        isSelected = true
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdRadioGroup  (convenience wrapper)
// ─────────────────────────────────────────────────────────────
// Manages mutual exclusion automatically.
//
// USAGE
//   @State private var pick = "a"
//   VdRadioGroup(selection: $pick) {
//       VdRadioOption(value: "a", label: "Option A", description: "…")
//       VdRadioOption(value: "b", label: "Option B")
//       VdRadioOption(value: "c", label: "Option C (disabled)", isDisabled: true)
//   }

public struct VdRadioGroup<Value: Hashable, Content: View>: View {

    @Binding private var selection: Value
    private  let content:           Content

    public init(selection: Binding<Value>, @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.content    = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: VdSpacing.sm) {
            content
        }
        .environment(\.radioGroupSelection, AnyHashable(selection))
        .environment(\.radioGroupAction, { if let v = $0 as? Value { self.selection = v } })
    }
}

// ── Environment keys ──────────────────────────────────────────

private struct RadioGroupSelectionKey: EnvironmentKey {
    static let defaultValue: AnyHashable? = nil
}

private struct RadioGroupActionKey: EnvironmentKey {
    static let defaultValue: ((AnyHashable) -> Void)? = nil
}

private extension EnvironmentValues {
    var radioGroupSelection: AnyHashable? {
        get { self[RadioGroupSelectionKey.self] }
        set { self[RadioGroupSelectionKey.self] = newValue }
    }
    var radioGroupAction: ((AnyHashable) -> Void)? {
        get { self[RadioGroupActionKey.self] }
        set { self[RadioGroupActionKey.self] = newValue }
    }
}

// ── VdRadioOption ─────────────────────────────────────────────

public struct VdRadioOption<Value: Hashable>: View {

    private let value:      Value
    private let label:      String?
    private let description: String?
    private let isDisabled: Bool

    @Environment(\.radioGroupSelection) private var selection
    @Environment(\.radioGroupAction)    private var action

    public init(
        value:       Value,
        label:       String? = nil,
        description: String? = nil,
        isDisabled:  Bool    = false
    ) {
        self.value       = value
        self.label       = label
        self.description = description
        self.isDisabled  = isDisabled
    }

    public var body: some View {
        VdRadioButton(
            isSelected: Binding(
                get: { selection == AnyHashable(value) },
                set: { if $0 { action?(AnyHashable(value)) } }
            ),
            label:       label,
            description: description,
            isDisabled:  isDisabled
        )
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — Preview
// ─────────────────────────────────────────────────────────────

#Preview("VdRadioButton — All Variants") {
    ScrollView {
        VStack(alignment: .leading, spacing: VdSpacing.xl) {

            previewSection("Default") {
                VdRadioButton(isSelected: .constant(false),
                    label: "Radio Button Label",
                    description: "Description for the radio button")
                VdRadioButton(isSelected: .constant(true),
                    label: "Radio Button Label",
                    description: "Description for the radio button")
            }

            previewSection("Disabled") {
                VdRadioButton(isSelected: .constant(false),
                    label: "Radio Button Label",
                    description: "Description for the radio button",
                    isDisabled: true)
                VdRadioButton(isSelected: .constant(true),
                    label: "Radio Button Label",
                    description: "Description for the radio button",
                    isDisabled: true)
            }

            previewSection("No label") {
                HStack(spacing: VdSpacing.md) {
                    VdRadioButton(isSelected: .constant(false))
                    VdRadioButton(isSelected: .constant(true))
                }
            }

            previewSection("Radio Group") {
                InteractiveRadioGroupDemo()
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

private struct InteractiveRadioGroupDemo: View {
    @State private var plan = "pro"

    var body: some View {
        VStack(alignment: .leading, spacing: VdSpacing.sm) {
            VdRadioGroup(selection: $plan) {
                VdRadioOption(value: "free",       label: "Free",       description: "Up to 3 projects")
                VdRadioOption(value: "pro",        label: "Pro",        description: "$12/month · Unlimited projects")
                VdRadioOption(value: "enterprise", label: "Enterprise", description: "Custom pricing")
                VdRadioOption(value: "legacy",     label: "Legacy",     description: "No longer available", isDisabled: true)
            }
        }
        .padding(VdSpacing.md)
    }
}
