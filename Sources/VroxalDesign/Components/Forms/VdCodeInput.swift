// Components/Forms/VdCodeInput.swift — Vroxal Design

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
            HStack(spacing: VdSpacing.sm) {
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
        .vdInstallKeyboardDismissOnTap()
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
                .padding(-2)
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
