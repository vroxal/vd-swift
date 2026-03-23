// Components/Forms/VdSelectionCard.swift — Vroxal Design
// ─────────────────────────────────────────────────────────────

import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: — VdSelectionStyle
// ─────────────────────────────────────────────────────────────

public enum VdSelectionStyle {
    case checkbox
    case radio
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdSelectionCard
// ─────────────────────────────────────────────────────────────

public struct VdSelectionCard: View {

    private let selectionStyle: VdSelectionStyle
    @Binding private var isSelected: Bool
    private let icon:           String?     // SF Symbol name
    private let title:          String
    private let description:    String?
    private let isDisabled:     Bool

    @FocusState private var isFocused: Bool
    @State    private var isPressed:   Bool = false

    public init(
        selectionStyle: VdSelectionStyle = .checkbox,
        isSelected:     Binding<Bool>,
        icon:           String?  = nil,
        title:          String,
        description:    String?  = nil,
        isDisabled:     Bool     = false
    ) {
        self.selectionStyle = selectionStyle
        self._isSelected    = isSelected
        self.icon           = icon
        self.title          = title
        self.description    = description
        self.isDisabled     = isDisabled
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Body
    // ─────────────────────────────────────────────────────────

    public var body: some View {
        Button(action: toggle) {
            HStack(alignment: .top, spacing: VdSpacing.sm) {    // gap: 8pt

                // ── Icon (24pt) ───────────────────────────────
                if let symbol = icon {
                    Image(systemName: symbol)
                        .resizable()
                        .scaledToFit()
                        .padding(2)
                        .foregroundStyle(iconColor)
                        .frame(width: VdIconSize.md, height: VdIconSize.md)
                }

                // ── Title + description ───────────────────────
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .vdFont(VdFont.labelMedium)
                        .foregroundStyle(titleColor)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let desc = description {
                        Text(desc)
                            .vdFont(VdFont.bodySmall)
                            .foregroundStyle(descriptionColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity)

                // ── Control (right, top-aligned) ──────────────
                controlView
            }
            .padding(VdSpacing.md)                              // 16pt all sides
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: VdRadius.md,style : .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: VdRadius.md ,style : .continuous)
                    .strokeBorder(cardBorder, lineWidth: VdBorderWidth.sm)  // always 1pt
            }
            .overlay {
                if isFocused {
                    RoundedRectangle(cornerRadius: VdRadius.sm + 3)
                        .strokeBorder(Color.vdBorderPrimaryTertiary, lineWidth: VdBorderWidth.md)
                        .padding(-3)
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
        .animation(.easeInOut(duration: 0.15), value: isSelected)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Control subview (right side, no label/description)
    // ─────────────────────────────────────────────────────────

    @ViewBuilder
    private var controlView: some View {
        switch selectionStyle {
        case .checkbox:
            ZStack {
                RoundedRectangle(cornerRadius: VdRadius.xs)
                    .fill(checkboxBoxBg)
                    .overlay {
                        RoundedRectangle(cornerRadius: VdRadius.xs)
                            .strokeBorder(checkboxBoxBorder, lineWidth: VdBorderWidth.sm)
                            .opacity(isSelected ? 0 : 1)
                    }
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.vdContentDefaultAlwaysLight)
                }
            }
            .frame(width: 20, height: 20)

        case .radio:
            ZStack {
                Circle()
                    .fill(Color.vdBackgroundDefaultSecondary)
                    .overlay {
                        Circle()
                            .strokeBorder(radioRingBorder, lineWidth: VdBorderWidth.sm)
                    }
                if isSelected {
                    Circle()
                        .fill(Color.vdBackgroundPrimaryBase)
                        .frame(width: 12, height: 12)
                }
            }
            .frame(width: 20, height: 20)
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Derived tokens — card container
    // ─────────────────────────────────────────────────────────

    private var cardBackground: Color {
        if isDisabled  { return .vdBackgroundDefaultDisabled }
        if isSelected  { return .vdBackgroundPrimarySecondary }
        return .vdBackgroundDefaultSecondary
    }

    private var cardBorder: Color {
        if isDisabled  { return .vdBorderDefaultDisabled }
        if isSelected  { return .vdBorderPrimarySecondary }
        if isPressed   { return .vdBorderPrimaryBase }
        return .vdBorderDefaultTertiary
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Derived tokens — content
    // ─────────────────────────────────────────────────────────

    private var titleColor: Color {
        if isDisabled { return .vdContentDefaultDisabled }
        if isSelected { return .vdContentDefaultBase }
        return .vdContentDefaultSecondary
    }

    private var descriptionColor: Color {
        if isDisabled { return .vdContentDefaultDisabled }
        if isSelected { return .vdContentDefaultSecondary }
        return .vdContentDefaultTertiary
    }

    private var iconColor: Color {
        if isDisabled { return .vdContentDefaultDisabled }
        if isSelected { return .vdContentDefaultBase }
        return .vdContentDefaultSecondary
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Derived tokens — checkbox control
    // ─────────────────────────────────────────────────────────

    private var checkboxBoxBg: Color {
        if isDisabled { return .vdBackgroundDefaultDisabled }
        if isSelected { return isPressed ? .vdBackgroundPrimaryBaseHover : .vdBackgroundPrimaryBase }
        return isPressed ? .vdBackgroundPrimarySecondary : .vdBackgroundDefaultSecondary
    }

    private var checkboxBoxBorder: Color {
        if isDisabled { return .vdBorderDefaultTertiary }
        return isPressed ? .vdBorderPrimaryBase : .vdBorderDefaultSecondary
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Derived tokens — radio control
    // ─────────────────────────────────────────────────────────

    private var radioRingBorder: Color {
        if isDisabled { return .vdBorderDefaultTertiary }
        if isSelected { return isPressed ? .vdBorderPrimarySecondary : .vdBorderPrimaryBase }
        return isPressed ? .vdBorderPrimaryBase : .vdBorderDefaultSecondary
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Action
    // ─────────────────────────────────────────────────────────

    private func toggle() {
        guard !isDisabled else { return }
        if selectionStyle == .checkbox {
            isSelected.toggle()
        } else {
            isSelected = true   // radio: only select, never deselect directly
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdSelectionCardGroup  (radio mutual exclusion)
// ─────────────────────────────────────────────────────────────

public struct VdSelectionCardGroup<Value: Hashable, Content: View>: View {

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
        .environment(\.selectionCardGroupValue,  AnyHashable(selection))
        .environment(\.selectionCardGroupAction, { if let v = $0 as? Value { self.selection = v } })
    }
}

// ── Environment keys ──────────────────────────────────────────

private struct SelectionCardGroupValueKey: EnvironmentKey {
    static let defaultValue: AnyHashable? = nil
}

private struct SelectionCardGroupActionKey: EnvironmentKey {
    static let defaultValue: ((AnyHashable) -> Void)? = nil
}

extension EnvironmentValues {
    fileprivate var selectionCardGroupValue: AnyHashable? {
        get { self[SelectionCardGroupValueKey.self] }
        set { self[SelectionCardGroupValueKey.self] = newValue }
    }
    fileprivate var selectionCardGroupAction: ((AnyHashable) -> Void)? {
        get { self[SelectionCardGroupActionKey.self] }
        set { self[SelectionCardGroupActionKey.self] = newValue }
    }
}

// ── VdSelectionCardOption ─────────────────────────────────────

public struct VdSelectionCardOption<Value: Hashable>: View {

    private let value:       Value
    private let icon:        String?
    private let title:       String
    private let description: String?
    private let isDisabled:  Bool

    @Environment(\.selectionCardGroupValue)  private var groupValue
    @Environment(\.selectionCardGroupAction) private var groupAction

    public init(
        value:       Value,
        icon:        String?  = nil,
        title:       String,
        description: String?  = nil,
        isDisabled:  Bool     = false
    ) {
        self.value       = value
        self.icon        = icon
        self.title       = title
        self.description = description
        self.isDisabled  = isDisabled
    }

    public var body: some View {
        VdSelectionCard(
            selectionStyle: .radio,
            isSelected: Binding(
                get: { groupValue == AnyHashable(value) },
                set: { if $0 { groupAction?(AnyHashable(value)) } }
            ),
            icon:        icon,
            title:       title,
            description: description,
            isDisabled:  isDisabled
        )
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — Preview
// ─────────────────────────────────────────────────────────────

#Preview("VdSelectionCard — All Variants") {
    ScrollView {
        VStack(alignment: .leading, spacing: VdSpacing.xl) {

            // ── Checkbox cards ────────────────────────────────
            previewSection("Checkbox — with description") {
                VdSelectionCard(selectionStyle: .checkbox,
                    isSelected: .constant(false),
                    icon: "bell", title: "Checkbox Label",
                    description: "Description for the checkbox goes here")

                VdSelectionCard(selectionStyle: .checkbox,
                    isSelected: .constant(true),
                    icon: "bell", title: "Checkbox Label",
                    description: "Description for the checkbox goes here")

                VdSelectionCard(selectionStyle: .checkbox,
                    isSelected: .constant(false),
                    icon: "bell", title: "Checkbox Label",
                    description: "Description for the checkbox goes here",
                    isDisabled: true)
            }

            previewSection("Checkbox — no description") {
                VdSelectionCard(selectionStyle: .checkbox,
                    isSelected: .constant(false),
                    icon: "bell", title: "Checkbox Label")

                VdSelectionCard(selectionStyle: .checkbox,
                    isSelected: .constant(true),
                    icon: "bell", title: "Checkbox Label")

                VdSelectionCard(selectionStyle: .checkbox,
                    isSelected: .constant(false),
                    icon: "bell", title: "Checkbox Label",
                    isDisabled: true)
            }

            // ── Radio cards ───────────────────────────────────
            previewSection("Radio — with description") {
                VdSelectionCard(selectionStyle: .radio,
                    isSelected: .constant(false),
                    icon: "star", title: "Radio Label",
                    description: "Description for the radio button")

                VdSelectionCard(selectionStyle: .radio,
                    isSelected: .constant(true),
                    icon: "star", title: "Radio Label",
                    description: "Description for the radio button")

                VdSelectionCard(selectionStyle: .radio,
                    isSelected: .constant(false),
                    icon: "star", title: "Radio Label",
                    description: "Description for the radio button",
                    isDisabled: true)
            }

            // ── No icon ───────────────────────────────────────
            previewSection("No icon") {
                VdSelectionCard(selectionStyle: .checkbox,
                    isSelected: .constant(false),
                    title: "No icon, unselected",
                    description: "Description goes here")

                VdSelectionCard(selectionStyle: .checkbox,
                    isSelected: .constant(true),
                    title: "No icon, selected",
                    description: "Description goes here")
            }

            // ── Interactive checkbox ──────────────────────────
            previewSection("Interactive — Checkbox") {
                InteractiveCheckboxCardDemo()
            }

            // ── Interactive radio group ───────────────────────
            previewSection("Interactive — Radio Group") {
                InteractiveRadioCardDemo()
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

private struct InteractiveCheckboxCardDemo: View {
    @State private var notifications = false
    @State private var darkMode      = true
    @State private var analytics     = false

    var body: some View {
        VStack(spacing: VdSpacing.sm) {
            VdSelectionCard(selectionStyle: .checkbox,
                isSelected: $notifications,
                icon: "bell",
                title: "Push Notifications",
                description: "Receive alerts for new activity")

            VdSelectionCard(selectionStyle: .checkbox,
                isSelected: $darkMode,
                icon: "moon",
                title: "Dark Mode",
                description: "Switch to dark colour scheme")

            VdSelectionCard(selectionStyle: .checkbox,
                isSelected: $analytics,
                icon: "chart.bar",
                title: "Analytics",
                description: "Help us improve with usage data",
                isDisabled: true)
        }
    }
}

private struct InteractiveRadioCardDemo: View {
    @State private var plan = "pro"

    var body: some View {
        VdSelectionCardGroup(selection: $plan) {
            VdSelectionCardOption(value: "free",
                icon: "star",
                title: "Free",
                description: "Up to 3 projects")

            VdSelectionCardOption(value: "pro",
                icon: "bolt",
                title: "Pro",
                description: "$12/month · Unlimited projects")

            VdSelectionCardOption(value: "team",
                icon: "person.3",
                title: "Team",
                description: "$8/seat/month · Shared workspace")

            VdSelectionCardOption(value: "legacy",
                icon: "xmark.circle",
                title: "Legacy",
                description: "No longer available",
                isDisabled: true)
        }
    }
}
