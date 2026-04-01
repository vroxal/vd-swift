import Dispatch
import SwiftUI

public struct VdSearchField: View {

    @Binding private var text: String

    private let placeholder: String
    private let isDisabled: Bool
    private let showsClearAction: Bool
    private let onClear: (() -> Void)?
    private let previewForceFocused: Bool

    @FocusState private var isFocused: Bool

    public init(
        text: Binding<String>,
        placeholder: String = "Placeholder",
        isDisabled: Bool = false,
        showsClearAction: Bool = true,
        onClear: (() -> Void)? = nil
    ) {
        self.init(
            text: text,
            placeholder: placeholder,
            isDisabled: isDisabled,
            showsClearAction: showsClearAction,
            onClear: onClear,
            previewForceFocused: false
        )
    }

    init(
        text: Binding<String>,
        placeholder: String,
        isDisabled: Bool,
        showsClearAction: Bool,
        onClear: (() -> Void)?,
        previewForceFocused: Bool
    ) {
        self._text = text
        self.placeholder = placeholder
        self.isDisabled = isDisabled
        self.showsClearAction = showsClearAction
        self.onClear = onClear
        self.previewForceFocused = previewForceFocused
    }

    fileprivate init(
        text: Binding<String>,
        placeholder: String = "Placeholder",
        isDisabled: Bool = false,
        previewForceFocused: Bool
    ) {
        self.init(
            text: text,
            placeholder: placeholder,
            isDisabled: isDisabled,
            showsClearAction: true,
            onClear: nil,
            previewForceFocused: previewForceFocused
        )
    }

    public var body: some View {
        HStack(spacing: VdSpacing.sm) {
            leadingIcon
            inputField
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
            if isFocused && !isDisabled {
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
        .vdInstallKeyboardDismissOnTap()
        .onAppear {
            guard previewForceFocused, !isDisabled else { return }
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
        .foregroundStyle(isDisabled ? Color.vdContentDefaultDisabled : Color.vdContentDefaultBase)
        .focused($isFocused)
        .disabled(isDisabled)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
    }

    @ViewBuilder
    private var clearAction: some View {
        if showsClearAction && !text.isEmpty {
            VdIconButton(
                icon: "vd:xmark",
                color: .neutral,
                style: .transparent,
                size: .small,
                isDisabled: isDisabled,
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
        isDisabled ? .vdBackgroundDefaultDisabled : .vdBackgroundDefaultSecondary
    }

    private var containerBorderColor: Color {
        if isDisabled { return .vdBorderDefaultDisabled }
        if isFocused  { return .vdBorderDefaultBase }
        return .vdBorderDefaultSecondary
    }

    private var leadingIconColor: Color {
        isDisabled ? .vdContentDefaultDisabled : .vdContentNeutralBase
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
                    isDisabled: true
                )
                VdSearchField(
                    text: .constant("Input Value"),
                    placeholder: "Placeholder",
                    isDisabled: true
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
    }
}
