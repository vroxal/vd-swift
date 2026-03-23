// Components/Forms/VdCodeInput.swift — Vroxal Design System
// ─────────────────────────────────────────────────────────────
// Figma source: node 318-36753
//
// A row of individual digit cells for OTP / verification codes.
// Supports SMS autofill via .textContentType(.oneTimeCode).
//
// HOW IT WORKS
//   A single hidden UITextField sits behind all the cells.
//   It captures all keyboard input and SMS autofill.
//   The visible cells are pure display — they render characters
//   from the string, highlight the active position, and show
//   a blinking cursor in the focused cell.
//
// CELL STATES → TOKEN MAPPING
//   Default/Empty   bg=BackgroundDefaultSecondary  border=BorderDefaultSecondary  1pt
//   Default/Filled  bg=BackgroundDefaultSecondary  border=BorderDefaultSecondary  1pt
//   Focus (active)  bg=BackgroundDefaultSecondary  border=BorderPrimaryBase       2pt  + cursor
//   Error/Empty     bg=BackgroundErrorSecondary    border=BorderErrorBase         1pt
//   Error/Filled    bg=BackgroundErrorSecondary    border=BorderErrorBase         1pt
//   Disabled/Empty  bg=BackgroundDefaultDisabled   border=BorderDefaultDisabled   1pt
//   Disabled/Filled bg=BackgroundDefaultDisabled   border=BorderDefaultDisabled   1pt
//
// PROPS
//   code           — Binding<String>: the current value (trimmed to length)
//   length         — Int: number of cells, default 6 (4 and 6 shown in Figma)
//   state          — VdCodeInputState: default · error · disabled
//   onComplete     — closure fired when all cells are filled
//
// USAGE
//   @State private var otp = ""
//
//   VdCodeInput(code: $otp, length: 6) {
//       verifyCode(otp)
//   }
//
//   VdCodeInput(code: $otp, length: 4, state: .error)
// ─────────────────────────────────────────────────────────────

import SwiftUI


// ─────────────────────────────────────────────────────────────
// MARK: — VdCodeInputState
// ─────────────────────────────────────────────────────────────

public enum VdCodeInputState {
    case `default`
    case error
    case disabled
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdCodeInput
// ─────────────────────────────────────────────────────────────

public struct VdCodeInput: View {

    @Binding private var code: String
    private let length: Int
    private let state: VdCodeInputState
    private let onComplete: (() -> Void)?

    @FocusState private var isFocused: Bool

    public init(
        code: Binding<String>,
        length: Int = 6,
        state: VdCodeInputState = .default,
        onComplete: (() -> Void)? = nil
    ) {
        self._code = code
        self.length = max(1, length)
        self.state = state
        self.onComplete = onComplete
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Body
    // ─────────────────────────────────────────────────────────

    public var body: some View {
        ZStack {
            // ── Hidden text field — captures all input ────────
            hiddenTextField

            // ── Visible cells ─────────────────────────────────
            HStack(spacing: VdSpacing.xxs) {  // gap: 8pt
                ForEach(0..<length, id: \.self) { index in
                    CodeCell(
                        character: character(at: index),
                        cellState: cellState(at: index),
                        isActive: isFocused && activeIndex == index
                    )
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { isFocused = true }
        }
        .disabled(state == .disabled)
        .onChangeCompat(of: code) { newValue in
            // Sanitise — digits only, trimmed to length
            let filtered = String(newValue.filter(\.isNumber).prefix(length))
            if filtered != newValue { code = filtered }
            // Fire completion
            if filtered.count == length { onComplete?() }
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Hidden text field (UIViewRepresentable)
    // ─────────────────────────────────────────────────────────

    private var hiddenTextField: some View {
        OTPTextField(text: $code, isFocused: focusBinding, length: length)
            .frame(width: 1, height: 1)  // invisible but present
            .opacity(0.001)  // fully transparent
            .allowsHitTesting(false)
            .focused($isFocused)
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Helpers
    // ─────────────────────────────────────────────────────────

    private var activeIndex: Int {
        min(code.count, length - 1)
    }

    private var focusBinding: Binding<Bool> {
        Binding(
            get: { isFocused },
            set: { isFocused = $0 }
        )
    }

    private func character(at index: Int) -> String? {
        guard index < code.count else { return nil }
        let i = code.index(code.startIndex, offsetBy: index)
        return String(code[i])
    }

    private func cellState(at index: Int) -> CodeCellState {
        switch state {
        case .disabled: return .disabled
        case .error: return .error
        case .default: return .normal
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — CodeCellState
// ─────────────────────────────────────────────────────────────

private enum CodeCellState {
    case normal
    case error
    case disabled
}

// ─────────────────────────────────────────────────────────────
// MARK: — CodeCell
// ─────────────────────────────────────────────────────────────

private struct CodeCell: View {

    let character: String?
    let cellState: CodeCellState
    let isActive: Bool

    @State private var cursorVisible = true

    var body: some View {
        ZStack {
            // ── Background + border ───────────────────────────
            RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
                .fill(background)
                .overlay {
                    RoundedRectangle(
                        cornerRadius: VdRadius.md,
                        style: .continuous
                    )
                    .strokeBorder(
                        border,
                        lineWidth: VdBorderWidth.sm
                    )
                }

            // ── Focus ring — 2pt border, 2pt outset, BorderPrimaryTertiary ──
            if isActive {
                RoundedRectangle(
                    cornerRadius: VdRadius.md + 2,
                    style: .continuous
                )
                .strokeBorder(
                    Color.vdBorderPrimaryTertiary,
                    lineWidth: VdBorderWidth.md
                )
                .padding(-3)
            }

            // ── Character or cursor ───────────────────────────
            if let char = character {
                Text(char)
                    .vdFont(.bodyMedium)
                    .foregroundStyle(textColor)
            } else if isActive {
                // Blinking cursor bar
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.vdContentPrimaryBase)
                    .frame(width: 2, height: 20)
                    .opacity(cursorVisible ? 1 : 0)
                    .animation(
                        .easeInOut(duration: 0.5).repeatForever(),
                        value: cursorVisible
                    )
                    .onAppear { cursorVisible = false }
            }
        }
        .frame(width: 48, height: 48)
        .padding(2)    }

    // ─────────────────────────────────────────────────────────
    // MARK: Derived tokens
    // ─────────────────────────────────────────────────────────

    private var background: Color {
        switch cellState {
        case .normal: return .vdBackgroundDefaultSecondary
        case .error: return .vdBackgroundErrorSecondary
        case .disabled: return .vdBackgroundDefaultDisabled
        }
    }

    private var border: Color {
        if isActive { return .vdBorderDefaultBase }
        switch cellState {
        case .normal: return .vdBorderDefaultSecondary
        case .error: return .vdBorderErrorBase
        case .disabled: return .vdBorderDefaultDisabled
        }
    }

    private var textColor: Color {
        switch cellState {
        case .normal: return .vdContentDefaultBase
        case .error: return .vdContentErrorOnSecondary
        case .disabled: return .vdContentDefaultDisabled
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — OTPTextField (UIViewRepresentable)
// Hidden UITextField that handles:
//   • SMS OTP autofill via .textContentType(.oneTimeCode)
//   • Numeric keyboard
//   • Backspace on empty field
//   • Length enforcement
// ─────────────────────────────────────────────────────────────

private struct OTPTextField: UIViewRepresentable {

    @Binding var text: String
    @Binding var isFocused: Bool
    let length: Int

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.keyboardType = .numberPad
        field.textContentType = .oneTimeCode
        field.delegate = context.coordinator
        field.autocorrectionType = .no
        field.textColor = .clear  // characters rendered by SwiftUI
        field.tintColor = .clear  // cursor rendered by SwiftUI
        return field
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        // Keep UITextField in sync with binding
        if uiView.text != text {
            uiView.text = text
        }
        // Manage first responder
        DispatchQueue.main.async {
            if isFocused && !uiView.isFirstResponder {
                uiView.becomeFirstResponder()
            } else if !isFocused && uiView.isFirstResponder {
                uiView.resignFirstResponder()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: OTPTextField

        init(parent: OTPTextField) {
            self.parent = parent
        }

        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            let current = textField.text ?? ""
            let maxLen = parent.length

            if string.isEmpty {
                // Backspace
                if current.isEmpty { return false }
                parent.text = String(current.dropLast())
                return false
            }

            // Accept only digits
            let digits = string.filter(\.isNumber)
            guard !digits.isEmpty else { return false }

            // Handle paste / SMS autofill (may arrive as full code at once)
            let merged = String(
                (current + digits).filter(\.isNumber).prefix(maxLen)
            )
            parent.text = merged
            return false
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.isFocused = true
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.isFocused = false
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — Preview
// ─────────────────────────────────────────────────────────────

#Preview("VdCodeInput — All Variants") {
    ScrollView {
        VStack(alignment: .leading, spacing: VdSpacing.xl) {

            previewSection("6-digit (default)") {
                VdCodeInput(code: .constant(""))
            }

            previewSection("6-digit (partially filled)") {
                VdCodeInput(code: .constant("123"))
            }

            previewSection("6-digit (fully filled)") {
                VdCodeInput(code: .constant("123456"))
            }

            previewSection("4-digit") {
                VdCodeInput(code: .constant(""), length: 4)
            }

            previewSection("Error state") {
                VdCodeInput(code: .constant("12"), length: 6, state: .error)
            }

            previewSection("Disabled state") {
                VdCodeInput(code: .constant("48"), length: 6, state: .disabled)
            }

            previewSection("Interactive") {
                InteractiveCodeInputDemo()
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

private struct InteractiveCodeInputDemo: View {
    @State private var code = ""
    @State private var isError = false

    private let correctCode = "123456"

    var body: some View {
        VStack(alignment: .leading, spacing: VdSpacing.md) {
            VdCodeInput(
                code: $code,
                length: 6,
                state: isError ? .error : .default,
                onComplete: { verify() }
            )

            if isError {
                Text("Incorrect code. Please try again.")
                    .vdFont(VdFont.bodySmall)
                    .foregroundStyle(Color.vdContentErrorBase)
            }

            HStack(spacing: VdSpacing.sm) {
                VdButton("Verify", action: verify)
                VdButton("Reset", style: .outlined, action: reset)
            }
        }
        .padding(VdSpacing.md)
        .background(Color.vdBackgroundDefaultSecondary)
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
    }

    private func verify() {
        isError = code != correctCode
    }

    private func reset() {
        code = ""
        isError = false
    }
}
