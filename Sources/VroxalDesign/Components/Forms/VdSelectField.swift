// Components/Forms/VdSelectField.swift — Vroxal Design

import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: — VdSelectFieldState
// ─────────────────────────────────────────────────────────────

public enum VdSelectFieldState {
    case `default`
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
                    .vdFont(VdFont.labelMedium)
                    .foregroundStyle(labelColor)
            }
            if isOptional {
                Spacer(minLength: 0)
                Text("Optional")
                    .vdFont(VdFont.bodyMediumItalic)
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
                RoundedRectangle(cornerRadius: VdRadius.md + 3)
                    .strokeBorder(
                        Color.vdBorderPrimaryTertiary,
                        lineWidth: VdBorderWidth.md
                    )
                    .padding(-3)
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
            VdIcon("exclamationmark.circle.fill", size: VdIconSize.md, color: .vdContentErrorBase)
        case .success:
            VdIcon("checkmark.circle.fill", size: VdIconSize.md, color: .vdContentSuccessBase)
        case .warning:
            VdIcon("exclamationmark.triangle.fill", size: VdIconSize.md, color: .vdContentWarningBase)
        default:
            EmptyView()
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Helper row
    // ─────────────────────────────────────────────────────────

    private func helperRow(text: String) -> some View {
        Text(text)
            .vdFont(VdFont.bodySmall)
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
        state == .disabled
            ? .vdContentDefaultDisabled : .vdContentDefaultDisabled
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

// ─────────────────────────────────────────────────────────────
// MARK: — Preview
// ─────────────────────────────────────────────────────────────

#Preview("VdSelectField — All States") {
    ScrollView {
        VStack(alignment: .leading, spacing: VdSpacing.xl) {

            previewSection("Default — empty") {
                VdSelectField(
                    selection: .constant(nil),
                    options: ["Option 1", "Option 2", "Option 3"],
                    label: "Label",
                    placeholder: "Placeholder",
                    helperText: "Help or instruction text goes here",
                    isOptional: true,
                    leadingIcon: "square.grid.2x2"
                )
            }

            previewSection("Default — with value") {
                VdSelectField(
                    selection: .constant("Option 1"),
                    options: ["Option 1", "Option 2", "Option 3"],
                    label: "Label",
                    placeholder: "Placeholder",
                    helperText: "Help or instruction text goes here",
                    isOptional: true,
                    leadingIcon: "square.grid.2x2"
                )
            }

            previewSection("Focus") {
                VdSelectField(
                    selection: .constant(nil),
                    options: ["Option 1", "Option 2", "Option 3"],
                    label: "Label",
                    placeholder: "Placeholder",
                    helperText: "Help or instruction text goes here",
                    isOptional: true,
                    leadingIcon: "square.grid.2x2",
                    state: .focus
                )
            }

            previewSection("Disabled") {
                VdSelectField(
                    selection: .constant(nil),
                    options: ["Option 1", "Option 2", "Option 3"],
                    label: "Label",
                    placeholder: "Placeholder",
                    helperText: "Help or instruction text goes here",
                    isOptional: true,
                    leadingIcon: "square.grid.2x2",
                    state: .disabled
                )
            }

            previewSection("Error") {
                VdSelectField(
                    selection: .constant(nil),
                    options: ["Option 1", "Option 2", "Option 3"],
                    label: "Label",
                    placeholder: "Placeholder",
                    helperText: "Please select a valid option",
                    isOptional: true,
                    leadingIcon: "square.grid.2x2",
                    state: .error
                )
            }

            previewSection("Success") {
                VdSelectField(
                    selection: .constant("Option 2"),
                    options: ["Option 1", "Option 2", "Option 3"],
                    label: "Label",
                    placeholder: "Placeholder",
                    helperText: "Great choice!",
                    isOptional: true,
                    leadingIcon: "square.grid.2x2",
                    state: .success
                )
            }

            previewSection("Warning") {
                VdSelectField(
                    selection: .constant("Option 1"),
                    options: ["Option 1", "Option 2", "Option 3"],
                    label: "Label",
                    placeholder: "Placeholder",
                    helperText: "This option may have limited availability",
                    isOptional: true,
                    leadingIcon: "square.grid.2x2",
                    state: .warning
                )
            }

            previewSection("No label, no helper") {
                VdSelectField(
                    selection: .constant(nil),
                    options: ["Option 1", "Option 2", "Option 3"],
                    placeholder: "Select an option"
                )
            }

            previewSection("Interactive") {
                InteractiveSelectDemo()
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

// ── Enum example ──────────────────────────────────────────────

private enum Country: String, CaseIterable, Hashable {
    case nepal = "Nepal"
    case india = "India"
    case usa = "United States"
    case uk = "United Kingdom"
    case australia = "Australia"
    case germany = "Germany"
}

private struct InteractiveSelectDemo: View {
    @State private var country: Country? = nil
    @State private var currency: String? = nil

    private let currencies = [
        "USD ($)", "EUR (€)", "GBP (£)", "NPR (₨)", "INR (₹)",
    ]

    var body: some View {
        VStack(spacing: VdSpacing.md) {
            VdSelectField(
                selection: $country,
                options: Country.allCases,
                optionLabel: { $0.rawValue },
                label: "Country",
                placeholder: "Select your country",
                helperText: country == nil ? "Required field" : nil,
                leadingIcon: "globe",
                state: country == nil ? .default : .success
            )

            VdSelectField(
                selection: $currency,
                options: currencies,
                label: "Currency",
                placeholder: "Select currency",
                helperText: "Used for billing and invoices",
                leadingIcon: "banknote"
            )
        }
        .padding(VdSpacing.md)
        .background(Color.vdBackgroundDefaultSecondary)
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
    }
}
