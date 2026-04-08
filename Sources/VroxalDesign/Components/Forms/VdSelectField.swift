// Components/Forms/VdSelectField.swift — Vroxal Design

import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: — VdSelectFieldState
// ─────────────────────────────────────────────────────────────

public enum VdSelectFieldState {
    case `default`
    /// Manually-managed focus state. SwiftUI's `Menu` does not expose
    /// open/focus events, so the caller is responsible for setting this
    /// state. It will NOT update automatically when the menu opens.
    case focus
    case disabled
    case error
    case success
    case warning
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdSelectField
// ─────────────────────────────────────────────────────────────

public struct VdSelectField<T: Hashable>: View {

    @Binding private var selection: T?
    private let options: [T]
    private let optionLabel: (T) -> String
    private let label: String?
    private let placeholder: String
    private let helperText: String?
    private let isOptional: Bool
    private let leadingIcon: String?
    private let state: VdSelectFieldState

    public init(
        selection: Binding<T?>,
        options: [T],
        optionLabel: @escaping (T) -> String = { "\($0)" },
        label: String? = nil,
        placeholder: String = "Select an option",
        helperText: String? = nil,
        isOptional: Bool = false,
        leadingIcon: String? = nil,
        state: VdSelectFieldState = .default
    ) {
        self._selection = selection
        self.options = options
        self.optionLabel = optionLabel
        self.label = label
        self.placeholder = placeholder
        self.helperText = helperText
        self.isOptional = isOptional
        self.leadingIcon = leadingIcon
        self.state = state
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Body
    // ─────────────────────────────────────────────────────────

    public var body: some View {
        VStack(alignment: .leading, spacing: VdSpacing.xs) {

            // ── Label row ─────────────────────────────────────
            if label != nil || isOptional {
                labelRow
            }

            // ── Input container ───────────────────────────────
            fieldContent

            // ── Helper text ───────────────────────────────────
            if let helper = helperText {
                helperRow(text: helper)
            }
        }
        .disabled(state == .disabled)
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Label row
    // ─────────────────────────────────────────────────────────

    private var labelRow: some View {
        HStack(spacing: VdSpacing.xs) {
            if let text = label {
                Text(text)
                    .vdFont(.labelMedium)
                    .foregroundStyle(labelColor)
            }
            if isOptional {
                Spacer(minLength: 0)
                Text("Optional")
                    .vdFont(.bodyMediumItalic)
                    .foregroundStyle(optionalColor)
            } else {
                Spacer(minLength: 0)
            }
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Field content
    // ─────────────────────────────────────────────────────────

    private var fieldContent: some View {
        // Visual shell is fully independent — never the Menu's label,
        // so iOS 26 liquid-glass transition never hides it.
        visualShell
            .overlay {
                Menu {
                    // Clear / reset option
                    Button {
                        selection = nil
                    } label: {
                        Text(placeholder)
                    }

                    Divider()

                    ForEach(options, id: \.self) { option in
                        Button {
                            selection = option
                        } label: {
                            HStack {
                                Text(optionLabel(option))
                                if selection == option {
                                    Spacer()
                                    VdIcon("checkmark", size: VdIconSize.xs)
                                }
                            }
                        }
                    }
                } label: {
                    Color.clear  // invisible trigger — container is never hidden
                }
                .menuStyle(.button)
                .buttonStyle(.plain)
                .disabled(state == .disabled || options.isEmpty)
            }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Visual shell
    // ─────────────────────────────────────────────────────────

    private var visualShell: some View {
        HStack(spacing: VdSpacing.sm) {

            // Leading icon (optional)
            if let icon = leadingIcon {
                VdIcon(icon, size: VdIconSize.md, color: leadingIconColor)
            }

            // Selected value or placeholder
            Group {
                if let selected = selection {
                    Text(optionLabel(selected))
                        .vdFont(.bodyMedium)
                        .foregroundStyle(valueColor)
                } else {
                    Text(placeholder)
                        .vdFont(.bodyMedium)
                        .foregroundStyle(placeholderColor)
                }
            }
            .frame(minHeight: 24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(1)
            .truncationMode(.tail)

            // Status icon (error / success / warning)
            statusIcon

            // Caret chevron
            VdIcon("vd:chevron-down", size: VdIconSize.md, color: caretColor)
        }
        .padding(.horizontal, VdSpacing.smMd)
        .padding(.vertical, VdSpacing.smMd)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(containerBackground)
        .clipShape(
            RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
                .strokeBorder(containerBorder, lineWidth: VdBorderWidth.sm)
        }
        .overlay {
            if state == .focus {
                RoundedRectangle(cornerRadius: VdRadius.md + 2)
                    .strokeBorder(
                        Color.vdBorderPrimaryTertiary,
                        lineWidth: VdBorderWidth.md
                    )
                    .padding(-2)
            }
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Status icon
    // ─────────────────────────────────────────────────────────

    @ViewBuilder
    private var statusIcon: some View {
        switch state {
        case .error:
            VdIcon("vd:danger-circle-filled", size: VdIconSize.md, color: .vdContentErrorBase)
        case .success:
            VdIcon("vd:check-circle-filled", size: VdIconSize.md, color: .vdContentSuccessBase)
        case .warning:
            VdIcon("vd:danger-triangle-filled", size: VdIconSize.md, color: .vdContentWarningBase)
        default:
            EmptyView()
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Helper row
    // ─────────────────────────────────────────────────────────

    private func helperRow(text: String) -> some View {
        Text(text)
            .vdFont(.bodySmall)
            .foregroundStyle(helperColor)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Derived tokens — container
    // ─────────────────────────────────────────────────────────

    private var containerBackground: Color {
        switch state {
        case .disabled: return .vdBackgroundDefaultDisabled
        case .error: return .vdBackgroundErrorSecondary
        default: return .vdBackgroundDefaultSecondary
        }
    }

    private var containerBorder: Color {
        switch state {
        case .focus: return .vdBorderDefaultBase
        case .disabled: return .vdBorderDefaultDisabled
        case .error: return .vdBorderErrorBase
        default: return .vdBorderDefaultSecondary
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Derived tokens — content
    // ─────────────────────────────────────────────────────────

    private var labelColor: Color {
        switch state {
        case .disabled: return .vdContentDefaultDisabled
        case .error: return .vdContentErrorBase
        default: return .vdContentDefaultSecondary
        }
    }

    private var optionalColor: Color {
        state == .disabled
            ? .vdContentDefaultDisabled : .vdContentDefaultSecondary
    }

    private var valueColor: Color {
        state == .disabled
            ? .vdContentDefaultDisabled : .vdContentDefaultBase
    }

    private var placeholderColor: Color {
        // Placeholder is always shown in the disabled token across all states.
        .vdContentDefaultDisabled
    }

    private var leadingIconColor: Color {
        state == .disabled
            ? .vdContentDefaultDisabled : .vdContentDefaultSecondary
    }

    private var caretColor: Color {
        state == .disabled
            ? .vdContentDefaultDisabled : .vdContentDefaultSecondary
    }

    private var helperColor: Color {
        switch state {
        case .disabled: return .vdContentDefaultDisabled
        case .error: return .vdContentErrorBase
        case .success: return .vdContentSuccessBase
        case .warning: return .vdContentWarningBase
        default: return .vdContentDefaultSecondary
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — Convenience init for String options
// ─────────────────────────────────────────────────────────────

extension VdSelectField where T == String {
    public init(
        selection: Binding<String?>,
        options: [String],
        label: String? = nil,
        placeholder: String = "Select an option",
        helperText: String? = nil,
        isOptional: Bool = false,
        leadingIcon: String? = nil,
        state: VdSelectFieldState = .default
    ) {
        self.init(
            selection: selection,
            options: options,
            optionLabel: { $0 },
            label: label,
            placeholder: placeholder,
            helperText: helperText,
            isOptional: isOptional,
            leadingIcon: leadingIcon,
            state: state
        )
    }
}
