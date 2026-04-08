// Components/Forms/VdSelectionCard.swift — Vroxal Design

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
    private let icon:           String?     // icon token (sf:/vd:)
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
                    VdIcon(symbol, size: VdIconSize.md, color: iconColor)
                }

                // ── Title + description ───────────────────────
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .vdFont(.labelMedium)
                        .foregroundStyle(titleColor)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let desc = description {
                        Text(desc)
                            .vdFont(.bodyMedium)
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
                    RoundedRectangle(cornerRadius: VdRadius.md + 2)
                        .strokeBorder(Color.vdBorderPrimaryTertiary, lineWidth: VdBorderWidth.md)
                        .padding(-2)
                }
            }
        }
        .buttonStyle(.plain)
        .focused($isFocused)
        .disabled(isDisabled)
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
                    VdIcon("vd:check", size: 20, color: .vdContentDefaultAlwaysLight)
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
