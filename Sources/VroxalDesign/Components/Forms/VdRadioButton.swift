// Components/Forms/VdRadioButton.swift — Vroxal Design

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

            // ── Focus ring (2pt, inset -2pt) ──────────────
            if isFocused {
                Circle()
                    .strokeBorder(Color.vdBorderPrimaryTertiary, lineWidth: VdBorderWidth.md)
                    .padding(-2)
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
