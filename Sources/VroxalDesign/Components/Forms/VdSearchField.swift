import Dispatch
import SwiftUI

public struct VdSearchField: View {

    @Binding private var text: String

    private let placeholder: String
    private let state: VdInputState
    private let showsClearAction: Bool
    private let onClear: (() -> Void)?
    private let previewForceFocused: Bool

    @FocusState private var isFocused: Bool

    public init(
        text: Binding<String>,
        placeholder: String = "Placeholder",
        state: VdInputState = .default,
        showsClearAction: Bool = true,
        onClear: (() -> Void)? = nil
    ) {
        self.init(
            text: text,
            placeholder: placeholder,
            state: state,
            showsClearAction: showsClearAction,
            onClear: onClear,
            previewForceFocused: false
        )
    }

    init(
        text: Binding<String>,
        placeholder: String,
        state: VdInputState,
        showsClearAction: Bool,
        onClear: (() -> Void)?,
        previewForceFocused: Bool
    ) {
        self._text = text
        self.placeholder = placeholder
        self.state = state
        self.showsClearAction = showsClearAction
        self.onClear = onClear
        self.previewForceFocused = previewForceFocused
    }

    fileprivate init(
        text: Binding<String>,
        placeholder: String = "Placeholder",
        state: VdInputState = .default,
        previewForceFocused: Bool
    ) {
        self.init(
            text: text,
            placeholder: placeholder,
            state: state,
            showsClearAction: true,
            onClear: nil,
            previewForceFocused: previewForceFocused
        )
    }

    public var body: some View {
        HStack(spacing: VdSpacing.sm) {
            leadingIcon
            inputField
            statusIcon
            clearAction
        }
        .padding(.horizontal, VdSpacing.smMd)
        .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
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
        .onAppear {
            guard previewForceFocused, state != .disabled else { return }
            DispatchQueue.main.async {
                isFocused = true
            }
        }
    }

    private var leadingIcon: some View {
        VdIcon("vd:magnifier", size: VdIconSize.md, color: leadingIconColor)
    }

    private var inputField: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(placeholder)
                .foregroundColor(Color.vdContentDefaultDisabled)
        )
        .vdFont(.bodyMedium)
        .frame(maxWidth: .infinity, minHeight: 24, alignment: .leading)
        .lineLimit(1)
        .truncationMode(.tail)
        .foregroundStyle(valueTextColor)
        .focused($isFocused)
        .disabled(state == .disabled)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
    }

    @ViewBuilder
    private var statusIcon: some View {
        if let iconName = statusIconName {
            VdIcon(iconName, size: VdIconSize.md, color: statusIconColor)
        }
    }

    @ViewBuilder
    private var clearAction: some View {
        if showsClearAction && !text.isEmpty {
            VdIconButton(
                icon: "vd:xmark",
                color: .neutral,
                style: .transparent,
                size: .small,
                isDisabled: state == .disabled,
                action: clear
            )
        }
    }

    private func clear() {
        if let onClear {
            onClear()
        } else {
            text = ""
        }
    }


    private var containerBackground: Color {
        switch state {
        case .disabled:
            return .vdBackgroundDefaultDisabled
        case .error:
            return .vdBackgroundErrorSecondary
        case .default, .success, .warning:
            return .vdBackgroundDefaultSecondary
        }
    }

    private var containerBorderColor: Color {
        if isFocused && state != .disabled {
            return .vdBorderDefaultBase
        }
        switch state {
        case .disabled:
            return .vdBorderDefaultDisabled
        case .error:
            return .vdBorderErrorBase
        case .default, .success, .warning:
            return .vdBorderDefaultSecondary
        }
    }

    private var valueTextColor: Color {
        state == .disabled ? .vdContentDefaultDisabled : .vdContentDefaultBase
    }

    private var leadingIconColor: Color {
        state == .disabled ? .vdContentDefaultDisabled : .vdContentNeutralBase
    }

    private var clearIconColor: Color {
        state == .disabled ? .vdContentDefaultDisabled : .vdContentNeutralBase
    }

    private var statusIconName: String? {
        switch state {
        case .error:
            return "vd:danger-circle-filled"
        case .success:
            return "vd:check-circle-filled"
        case .warning:
            return "vd:danger-triangle-filled"
        case .default, .disabled:
            return nil
        }
    }

    private var statusIconColor: Color {
        switch state {
        case .error:
            return .vdContentErrorBase
        case .success:
            return .vdContentSuccessBase
        case .warning:
            return .vdContentWarningBase
        case .default, .disabled:
            return .clear
        }
    }
}

#Preview("VdSearchField — All States") {
    ScrollView {
        VStack(alignment: .leading, spacing: VdSpacing.xl) {
            previewSection("Default") {
                     VdSearchField(
                        text: .constant(""),
                        placeholder: "Placeholder"
                    )
                    VdSearchField(
                        text: .constant("Input Value"),
                        placeholder: "Placeholder"
                    )
                
            }

            previewSection("Focus") {
                     VdSearchField(
                        text: .constant(""),
                        placeholder: "Placeholder",
                        previewForceFocused: true
                    )
                     VdSearchField(
                        text: .constant("Input Value"),
                        placeholder: "Placeholder",
                        previewForceFocused: true
                    )
                
            }

            previewSection("Disabled") {
                     VdSearchField(
                        text: .constant(""),
                        placeholder: "Placeholder",
                        state: .disabled
                    )
                     VdSearchField(
                        text: .constant("Input Value"),
                        placeholder: "Placeholder",
                        state: .disabled
                
                )
            }

            previewSection("Error") {
                     VdSearchField(
                        text: .constant(""),
                        placeholder: "Placeholder",
                        state: .error
                    )
                     VdSearchField(
                        text: .constant("Input Value"),
                        placeholder: "Placeholder",
                        state: .error
                    )
                
            }

            previewSection("Success") {
                     VdSearchField(
                        text: .constant(""),
                        placeholder: "Placeholder",
                        state: .success
                    )
                     VdSearchField(
                        text: .constant("Input Value"),
                        placeholder: "Placeholder",
                        state: .success
                    )
                
            }

            previewSection("Warning") {
                     VdSearchField(
                        text: .constant(""),
                        placeholder: "Placeholder",
                        state: .warning
                    )
                VdSearchField(
                        text: .constant("Input Value"),
                        placeholder: "Placeholder",
                        state: .warning
                    
                )
            }

            previewSection("Interactive") {
                InteractiveSearchFieldDemo()
            }
        }
        .padding(VdSpacing.lg)
    }
    .background(Color.vdBackgroundDefaultBase)
}

@ViewBuilder
private func previewSection<Content: View>(
    _ title: String,
    @ViewBuilder content: () -> Content
) -> some View {
    VStack(alignment: .leading, spacing: VdSpacing.sm) {
        Text(title)
            .vdFont(.labelSmall)
            .foregroundStyle(Color.vdContentDefaultTertiary)
        content()
    }
}


private struct InteractiveSearchFieldDemo: View {
    @State private var query = ""

    var body: some View {
        VdSearchField(
            text: $query,
            placeholder: "Search"
        )
        .frame(width: .infinity)
    }
}
