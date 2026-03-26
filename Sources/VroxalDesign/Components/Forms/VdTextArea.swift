// Components/Forms/VdTextArea.swift — Vroxal Design

import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: — VdTextArea
// ─────────────────────────────────────────────────────────────

public struct VdTextArea: View {

    @Binding private var text:          String
    private  let label:                 String?
    private  let placeholder:           String
    private  let helperText:            String?
    private  let isOptional:            Bool
    private  let leadingIcon:           String?
    private  let trailingIcon:          String?
    private  let onTrailingAction:      (() -> Void)?
    private  let characterLimit:        Int?
    private  let state:                 VdInputState        // ← unified enum

    @FocusState private var isFocused:  Bool

    private let minHeight: CGFloat = 120
    private let maxHeight: CGFloat = 240

    public init(
        text:           Binding<String>,
        label:          String?         = nil,
        placeholder:    String          = "Enter text...",
        helperText:     String?         = nil,
        isOptional:     Bool            = false,
        leadingIcon:    String?         = nil,
        trailingIcon:   String?         = nil,
        onTrailingAction: (() -> Void)? = nil,
        characterLimit: Int?            = nil,
        state:          VdInputState    = .default          // ← unified enum
    ) {
        self._text          = text
        self.label          = label
        self.placeholder    = placeholder
        self.helperText     = helperText
        self.isOptional     = isOptional
        self.leadingIcon    = leadingIcon
        self.trailingIcon   = trailingIcon
        self.onTrailingAction = onTrailingAction
        self.characterLimit = characterLimit
        self.state          = state
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
            inputContainer

            // ── Helper / counter row ──────────────────────────
            if helperText != nil || characterLimit != nil {
                helperRow
            }
        }
        .disabled(state == .disabled)
        .vdInstallKeyboardDismissOnTap()
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Label row
    // ─────────────────────────────────────────────────────────

    private var labelRow: some View {
        HStack(spacing: VdSpacing.xs) {
            if let labelText = label {
                Text(labelText)
                    .vdFont(VdFont.labelMedium)
                    .foregroundStyle(labelColor)             // ← was missing in original
            }
            Spacer(minLength: 0)
            if isOptional {
                Text("Optional")
                    .vdFont(VdFont.bodyMediumItalic)         // ← matches TextField (.bodyMediumItalic)
                    .foregroundStyle(optionalColor)
            }
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Input container
    // ─────────────────────────────────────────────────────────

    private var inputContainer: some View {
        HStack(alignment: .top, spacing: VdSpacing.sm) {

            // Leading icon — top-aligned
            if let icon = leadingIcon {
                VdIcon(icon, size: VdIconSize.md, color: leadingIconColor)
                    .padding(.top, VdSpacing.smMd)           // align with first text line
            }

            // TextEditor with native placeholder via overlay
            ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .vdFont(VdFont.bodyMedium)
                            .foregroundStyle(Color.vdContentDefaultDisabled)
                            .allowsHitTesting(false)
                    }

                    
                    TextEditor(text: $text)
                        .vdFont(.bodyMedium)
                        .foregroundStyle(valueColor)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, -5)
                            .padding(.vertical, -8)
                        .background(.clear)
                        .focused($isFocused)
                        .disabled(state == .disabled)
                        .frame(
                            minHeight: textEditorMinHeight,
                            maxHeight: textEditorMaxHeight
                        )
                        .onChangeCompat(of: text) { newValue in
                            if let limit = characterLimit, newValue.count > limit {
                                text = String(newValue.prefix(limit))
                            }
                        }

                
                            }
            .padding(.vertical, VdSpacing.smMd)

            // Status icon — top-aligned, trailing
            statusIcon
                .padding(.top, VdSpacing.smMd)

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
                .padding(.top, VdSpacing.smMd)
                .padding(.top, -VdSpacing.xs)
                .padding(.trailing, -VdSpacing.xs)
            }
        }
        .padding(.horizontal, VdSpacing.smMd)                // ← mirrors TextField horizontal padding
        .background(containerBackground)
        .clipShape(
            RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
                .strokeBorder(containerBorderColor, lineWidth: VdBorderWidth.sm)
        }
        .overlay {
            if isFocused {
                RoundedRectangle(cornerRadius: VdRadius.md + 3, style: .continuous)
                    .strokeBorder(
                        Color.vdBorderPrimaryTertiary,
                        lineWidth: VdBorderWidth.md
                    )
                    .padding(-3)
            }
        }
        .frame(minHeight: minHeight, maxHeight: maxHeight)
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Status icon
    // ─────────────────────────────────────────────────────────

    @ViewBuilder
    private var statusIcon: some View {
        if let iconName = statusIconName {
            VdIcon(iconName, size: VdIconSize.md, color: statusIconColor)
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Helper row
    // ─────────────────────────────────────────────────────────

    private var helperRow: some View {
        HStack(alignment: .top, spacing: VdSpacing.xs) {
            if let helper = helperText {
                Text(helper)
                    .vdFont(VdFont.bodySmall)
                    .foregroundStyle(helperColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Spacer(minLength: 0)
            }

            if let limit = characterLimit {
                Text("\(text.count)/\(limit)")
                    .vdFont(VdFont.bodySmall)
                    .foregroundStyle(Color.vdContentDefaultSecondary) // ← matches TextField counter colour
                    .fixedSize()
            }
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: TextEditor height calculation
    // ─────────────────────────────────────────────────────────

    private var textEditorMinHeight: CGFloat {
        minHeight - VdSpacing.smMd * 2 - 16                 // vertical padding × 2 + TE internal padding
    }

    private var textEditorMaxHeight: CGFloat {
        maxHeight - VdSpacing.smMd * 2 - 16
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Derived tokens — container
    // ─────────────────────────────────────────────────────────

    private var containerBackground: Color {
        switch state {
        case .disabled: return .vdBackgroundDefaultDisabled
        case .error:    return .vdBackgroundErrorSecondary
        default:        return .vdBackgroundDefaultSecondary
        }
    }

    private var containerBorderColor: Color {
        if isFocused { return .vdBorderDefaultBase }         // ← matches TextField: focus wins for ALL states
        switch state {
        case .disabled: return .vdBorderDefaultDisabled
        case .error:    return .vdBorderErrorBase
        default:        return .vdBorderDefaultSecondary
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Derived tokens — content
    // ─────────────────────────────────────────────────────────

    private var labelColor: Color {
        switch state {
        case .disabled: return .vdContentDefaultDisabled
        case .error:    return .vdContentErrorBase
        default:        return .vdContentDefaultSecondary
        }
    }

    private var optionalColor: Color {
        state == .disabled ? .vdContentDefaultDisabled : .vdContentDefaultSecondary
    }

    private var valueColor: Color {
        state == .disabled ? .vdContentDefaultDisabled : .vdContentDefaultBase
    }

    private var leadingIconColor: Color {
        state == .disabled ? .vdContentDefaultDisabled : .vdContentDefaultTertiary // ← matches TextField
    }

    private var statusIconName: String? {                    // ← mirrors TextField pattern
        switch state {
        case .error:   return "exclamationmark.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        default:       return nil
        }
    }

    private var statusIconColor: Color {                     // ← mirrors TextField pattern
        switch state {
        case .error:   return .vdContentErrorBase
        case .success: return .vdContentSuccessBase
        case .warning: return .vdContentWarningBase
        default:       return .clear
        }
    }

    private var helperColor: Color {
        switch state {
        case .disabled: return .vdContentDefaultDisabled
        case .error:    return .vdContentErrorBase
        case .success:  return .vdContentSuccessBase
        case .warning:  return .vdContentWarningBase
        default:        return .vdContentDefaultSecondary
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — Preview
// ─────────────────────────────────────────────────────────────

#Preview("VdTextArea — All States") {
    ScrollView {
        VStack(alignment: .leading, spacing: VdSpacing.xl) {

            previewSection("Default — empty") {
                VdTextArea(
                    text: .constant(""),
                    label: "Label",
                    placeholder: "Placeholder",
                    helperText: "Help or instruction text goes here",
                    isOptional: true,
                    leadingIcon: "square.grid.2x2",
                    characterLimit: 10)
            }

            previewSection("Default — with value") {
                VdTextArea(
                    text: .constant("Nothing more exciting happening here in terms of content, but just filling up the space."),
                    label: "Label",
                    placeholder: "Placeholder",
                    helperText: "Help or instruction text goes here",
                    isOptional: true,
                    leadingIcon: "square.grid.2x2",
                    trailingIcon: "xmark.circle.fill",
                    onTrailingAction: {},
                    characterLimit: 250)
            }

            previewSection("Disabled") {
                VdTextArea(
                    text: .constant(""),
                    label: "Label",
                    placeholder: "Placeholder",
                    helperText: "Help or instruction text goes here",
                    isOptional: true,
                    leadingIcon: "square.grid.2x2",
                    characterLimit: 10,
                    state: .disabled)
            }

            previewSection("Error") {
                VdTextArea(
                    text: .constant(""),
                    label: "Label",
                    placeholder: "Placeholder",
                    helperText: "Something went wrong",
                    isOptional: true,
                    leadingIcon: "square.grid.2x2",
                    characterLimit: 10,
                    state: .error)
            }

            previewSection("Success") {
                VdTextArea(
                    text: .constant("Looks great!"),
                    label: "Label",
                    placeholder: "Placeholder",
                    helperText: "Looks good!",
                    isOptional: true,
                    leadingIcon: "square.grid.2x2",
                    characterLimit: 50,
                    state: .success)
            }

            previewSection("Warning") {
                VdTextArea(
                    text: .constant("Input value"),
                    label: "Label",
                    placeholder: "Placeholder",
                    helperText: "Approaching character limit",
                    isOptional: true,
                    leadingIcon: "square.grid.2x2",
                    characterLimit: 15,
                    state: .warning)
            }

            previewSection("No label, no helper") {
                VdTextArea(
                    text: .constant(""),
                    placeholder: "Enter your message...")
            }

            previewSection("Interactive — with live counter") {
                InteractiveTextAreaDemo()
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

private struct InteractiveTextAreaDemo: View {
    @State private var text = ""
    private let limit       = 200

    private var fieldState: VdInputState {
        if text.count > Int(Double(limit) * 0.9) { return .warning }
        if text.count > 0                         { return .success }
        return .default
    }

    private var helperMessage: String {
        if text.count > Int(Double(limit) * 0.9) { return "Approaching character limit" }
        return "Share your thoughts"
    }

    var body: some View {
        VdTextArea(
            text: $text,
            label: "Message",
            placeholder: "Write something...",
            helperText: helperMessage,
            characterLimit: limit,
            state: fieldState)
    }
}
