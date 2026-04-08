// Components/Forms/VdTextField.swift — Vroxal Design


import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: — VdInputState
// ─────────────────────────────────────────────────────────────

public enum VdInputState {
    case `default`
    case disabled
    case error
    case success
    case warning
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdTextField
// ─────────────────────────────────────────────────────────────

public struct VdTextField: View {

    private let label: String
    private let placeholder: String
    private let state: VdInputState
    private let isSecure: Bool
    private let isOptional: Bool
    private let leadingIcon: String?
    private let helperText: String?
    private let characterLimit: Int?
    private let trailingIcon: String?
    private let onTrailingAction: (() -> Void)?

    @Binding private var text: String
    @FocusState private var isFocused: Bool

    public init(
        _ label: String,
        text: Binding<String>,
        placeholder: String = "Placeholder",
        state: VdInputState = .default,
        isSecure: Bool = false,
        isOptional: Bool = false,
        leadingIcon: String? = nil,
        helperText: String? = nil,
        characterLimit: Int? = nil,
        trailingIcon: String? = nil,
        onTrailingAction: (() -> Void)? = nil
    ) {
        self.label = label
        self._text = text
        self.placeholder = placeholder
        self.state = state
        self.isSecure = isSecure
        self.isOptional = isOptional
        self.leadingIcon = leadingIcon
        self.helperText = helperText
        self.characterLimit = characterLimit
        self.trailingIcon = trailingIcon
        self.onTrailingAction = onTrailingAction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: VdSpacing.xs) {
            // ── Label row ─────────────────────────────────────
            labelRow

            // ── Input container ───────────────────────────────
            inputContainer

            // ── Helper / counter row ──────────────────────────
            if helperText != nil || characterLimit != nil {
                helperRow
            }
        }
        .vdInstallKeyboardDismissOnTap()
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Label row
    // ─────────────────────────────────────────────────────────

    private var labelRow: some View {
        HStack(spacing: VdSpacing.xs) {
            Text(label)
                .vdFont(.labelMedium)
                .foregroundStyle(labelTextColor)

            Spacer()

            if isOptional {
                Text("Optional")
                    .vdFont(.bodyMediumItalic)
                    .foregroundStyle(optionalTextColor)
            }
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Input container
    // ─────────────────────────────────────────────────────────

    private var inputContainer: some View {
        HStack(spacing: VdSpacing.sm) {

            //             Leading icon
            if let icon = leadingIcon {
                VdIcon(icon, size: VdIconSize.md, color: leadingIconColor)
            }

            //
            Group {
                if isSecure {
                    SecureField(
                        "",
                        text: $text,
                        prompt: Text(placeholder)
                            .foregroundColor(Color.vdContentDefaultDisabled)
                        

                    )
                } else {
                    TextField(
                        "",
                        text: $text,
                        prompt: Text(placeholder)
                            .foregroundColor(Color.vdContentDefaultDisabled)

                    )
                }
            }                    

            .frame(minHeight: 24)
            .vdFont(.bodyMedium)
            .padding(.vertical, VdSpacing.smMd)
            .foregroundStyle(
                state == .disabled
                    ? Color.vdContentDefaultDisabled
                    : Color.vdContentDefaultBase
            )
            .focused($isFocused)
            .disabled(state == .disabled)
            .onChangeCompat(of: text) { newValue in
                if let limit = characterLimit, newValue.count > limit {
                    text = String(newValue.prefix(limit))
                }
            }

            //Status icon
            if let statusIcon = statusIconName {
                VdIcon(statusIcon, size: VdIconSize.md, color: statusIconColor)
            }

            // Trailing action
            if let icon = trailingIcon, let action = onTrailingAction {
                VdIconButton(
                    icon: icon,
                    color: .neutral,
                    style: .transparent,
                    size: .small,
                    isDisabled: state == .disabled,
                    action: action
                )
            }
        }
        .padding(.horizontal, VdSpacing.smMd)
        .background(containerBackground)
        .clipShape(
            RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
                .strokeBorder(containerBorderColor, lineWidth: VdBorderWidth.sm)
        }
        .overlay {
            if isFocused && state != .disabled {
                RoundedRectangle(
                    cornerRadius: VdRadius.md + 2,
                    style: .continuous
                )
                .strokeBorder(
                    Color.vdBorderPrimaryTertiary,
                    lineWidth: VdBorderWidth.md
                )
                .padding(-2)
            }
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Helper row
    // ─────────────────────────────────────────────────────────

    @ViewBuilder
    private var helperRow: some View {
        if helperText != nil || characterLimit != nil {
            HStack(alignment: .top, spacing: VdSpacing.xs) {
                if let helper = helperText {
                    Text(helper)
                        .vdFont(.bodySmall)
                        .foregroundStyle(helperTextColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                if let limit = characterLimit {
                    Text("\(text.count)/\(limit)")
                        .vdFont(.bodySmall)
                        .foregroundStyle(Color.vdContentDefaultSecondary)
                        .fixedSize()
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Derived tokens
    // ─────────────────────────────────────────────────────────

    private var containerBackground: Color {
        switch state {
        case .default, .success, .warning: return .vdBackgroundDefaultSecondary
        case .disabled: return .vdBackgroundDefaultDisabled
        case .error: return .vdBackgroundErrorSecondary
        }
    }

    private var containerBorderColor: Color {
        if isFocused { return .vdBorderDefaultBase }
        switch state {
        case .default, .success, .warning: return .vdBorderDefaultSecondary
        case .disabled: return .vdBorderDefaultDisabled
        case .error: return .vdBorderErrorBase
        }
    }

    private var labelTextColor: Color {
        switch state {
        case .disabled: return .vdContentDefaultDisabled
        case .error: return .vdContentErrorBase
        default: return .vdContentDefaultSecondary
        }
    }

    private var optionalTextColor: Color {
        state == .disabled
            ? .vdContentDefaultDisabled : .vdContentDefaultSecondary
    }

    private var leadingIconColor: Color {
        state == .disabled
            ? .vdContentDefaultDisabled : .vdContentDefaultTertiary
    }

    private var statusIconName: String? {
        switch state {
        case .error: return "vd:danger-circle-filled"
        case .success: return "vd:check-circle-filled"
        case .warning: return "vd:danger-triangle-filled"
        default: return nil
        }
    }

    private var statusIconColor: Color {
        switch state {
        case .error: return .vdContentErrorBase
        case .success: return .vdContentSuccessBase
        case .warning: return .vdContentWarningBase
        default: return .clear
        }
    }

    private var helperTextColor: Color {
        switch state {
        case .error: return .vdContentErrorBase
        case .success: return .vdContentSuccessBase
        case .warning: return .vdContentWarningBase
        case .disabled: return .vdContentDefaultDisabled
        default: return .vdContentDefaultSecondary
        }
    }
}
