//
//  VdTextField.swift
//  VroxalDesign
//
//  Created by Pramod Paudel on 16/03/2026.
//

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
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Label row
    // ─────────────────────────────────────────────────────────

    private var labelRow: some View {
        HStack(spacing: VdSpacing.xs) {
            Text(label)
                .vdFont(VdFont.labelMedium)
                .foregroundStyle(Color.vdContentDefaultSecondary)

            Spacer()

            if isOptional {
                Text("Optional")
                    .vdFont(VdFont.bodyMediumItalic)
                    .foregroundStyle(Color.vdContentDefaultSecondary)
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
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .padding(2)
                    .foregroundStyle(leadingIconColor)
                    .frame(width: VdIconSize.md, height: VdIconSize.md)
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

            .frame(minHeight: 22)
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
                Image(systemName: statusIcon)
                    .resizable()
                    .scaledToFit()
                    .padding(2)
                    .font(.system(size: VdIconSize.sm))
                    .foregroundStyle(statusIconColor)
                    .frame(width: VdIconSize.md, height: VdIconSize.md)
            }

            // Trailing action
            if let icon = trailingIcon, let action = onTrailingAction {
                VdIconButton(
                    icon: icon,
                    color: .neutral,
                    style: .transparent,
                    size: .small,
                    isDisabled: state == .disabled,
                    iconColorOverride: .vdContentDefaultTertiary,
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
                    cornerRadius: VdRadius.md + 3,
                    style: .continuous
                )
                .strokeBorder(
                    Color.vdBorderPrimaryTertiary,
                    lineWidth: VdBorderWidth.md
                )
                .padding(-3)
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
                        .vdFont(VdFont.bodySmall)
                        .foregroundStyle(helperTextColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                if let limit = characterLimit {
                    Text("\(text.count)/\(limit)")
                        .vdFont(VdFont.bodySmall)
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
        case .error: return "exclamationmark.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
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

// ─────────────────────────────────────────────────────────────
// MARK: — Preview
// ─────────────────────────────────────────────────────────────

#Preview("VdTextField") {
    ScrollView {
        VStack(alignment: .leading, spacing: VdSpacing.lg) {

            Group {
                previewLabel("Default")
                VdTextField(
                    "Label",
                    text: .constant(""),
                    placeholder: "Placeholder",
                    isOptional: true,
                    leadingIcon: "envelope",
                    helperText: "Help or instruction text",
                    characterLimit: 10,
                    trailingIcon: "xmark.circle.fill",
                    onTrailingAction: {}
                )

                previewLabel("Error")
                VdTextField(
                    "Label",
                    text: .constant("wrong@"),
                    state: .error,
                    leadingIcon: "envelope",
                    helperText: "Enter a valid email address",
                    trailingIcon: "xmark.circle.fill",
                    onTrailingAction: {}
                )

                previewLabel("Success")
                VdTextField(
                    "Label",
                    text: .constant("hello@vroxal.com"),
                    state: .success,
                    leadingIcon: "envelope",
                    helperText: "Looks good!"
                )

                previewLabel("Warning")
                VdTextField(
                    "Label",
                    text: .constant("taken_user"),
                    state: .warning,
                    leadingIcon: "person",
                    helperText: "This username may already be taken"
                )

                previewLabel("Disabled")
                VdTextField(
                    "Label",
                    text: .constant(""),
                    state: .disabled,
                    isOptional: true,
                    leadingIcon: "envelope",
                    helperText: "Not available right now",
                    trailingIcon: "xmark.circle.fill",
                    onTrailingAction: {}
                )
            }

            previewLabel("Password toggle")
            PasswordDemo()

            previewLabel("Search with clear")
            SearchDemo()

            previewLabel("With copy action")
            CopyDemo()

            previewLabel("Interactive")
            LiveDemo()
        }
        .padding(VdSpacing.lg)
    }
    .background(Color.vdBackgroundDefaultBase)
}

private func previewLabel(_ text: String) -> some View {
    Text(text)
        .vdFont(VdFont.labelSmall)
        .foregroundStyle(Color.vdContentDefaultTertiary)
}

private struct PasswordDemo: View {
    @State private var password = "mySecret123"
    @State private var isSecure = true
    var body: some View {
        VdTextField(
            "Password",
            text: $password,
            placeholder: "Enter your password",
            isSecure: isSecure,
            leadingIcon: "lock",
            trailingIcon: isSecure ? "eye" : "eye.slash",
            onTrailingAction: { isSecure.toggle() }
        )
    }
}

private struct SearchDemo: View {
    @State private var query = "design tokens"
    var body: some View {
        VdTextField(
            "Search",
            text: $query,
            placeholder: "Search...",
            leadingIcon: "magnifyingglass",
            trailingIcon: query.isEmpty ? nil : "xmark.circle.fill",
            onTrailingAction: { query = "" }
        )
    }
}

private struct CopyDemo: View {
    @State private var value = "vd-swift-1.0.0"
    var body: some View {
        VdTextField(
            "Package",
            text: $value,
            leadingIcon: "shippingbox",
            trailingIcon: "doc.on.doc",
            onTrailingAction: { UIPasteboard.general.string = value }
        )
    }
}

private struct LiveDemo: View {
    @State private var username = ""
    @State private var email = ""

    private var emailState: VdInputState {
        guard !email.isEmpty else { return .default }
        return email.contains("@") ? .success : .error
    }

    var body: some View {
        VStack(spacing: VdSpacing.md) {
            VdTextField(
                "Username",
                text: $username,
                placeholder: "e.g. johndoe",
                leadingIcon: "person",
                helperText: username.isEmpty ? "3–20 characters" : nil,
                characterLimit: 20,
                trailingIcon: username.isEmpty ? nil : "xmark.circle.fill",
                onTrailingAction: { username = "" }
            )

            VdTextField(
                "Email",
                text: $email,
                placeholder: "you@example.com",
                state: emailState,
                leadingIcon: "envelope",
                helperText: email.isEmpty
                    ? nil
                    : email.contains("@")
                        ? "Looks good!"
                        : "Enter a valid email address",
                trailingIcon: email.isEmpty ? nil : "xmark.circle.fill",
                onTrailingAction: { email = "" }
            )
        }
        .padding(VdSpacing.md)
        .background(Color.vdBackgroundDefaultSecondary)
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
    }
}
