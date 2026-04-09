// Components/Forms/VdDateTimeField.swift — Vroxal Design

import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: — VdDateTimeFieldMode
// ─────────────────────────────────────────────────────────────

public enum VdDateTimeFieldMode {
    case date
    case time
    case dateTime

    var displayedComponents: DatePickerComponents {
        switch self {
        case .date:     return [.date]
        case .time:     return [.hourAndMinute]
        case .dateTime: return [.date, .hourAndMinute]
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdDateTimeField
// ─────────────────────────────────────────────────────────────

public struct VdDateTimeField: View {

    private let label:            String
    private let placeholder:      String
    private let state:            VdInputState
    private let isOptional:       Bool
    private let leadingIcon:      String?
    private let helperText:       String?
    private let trailingIcon:     String?
    private let onTrailingAction: (() -> Void)?
    private let mode:             VdDateTimeFieldMode
    private let minimumDate:      Date?
    private let maximumDate:      Date?
    private let onChange:         ((Date?) -> Void)?

    @Binding private var selection: Date?

    @State private var isPickerPresented: Bool = false
    // Temp value edited inside the sheet — committed only on Done
    @State private var tempDate: Date = Date()

    public init(
        _ label:          String,
        selection:        Binding<Date?>,
        placeholder:      String              = "Placeholder",
        state:            VdInputState        = .default,
        isOptional:       Bool                = false,
        leadingIcon:      String?             = nil,
        helperText:       String?             = nil,
        trailingIcon:     String?             = nil,
        onTrailingAction: (() -> Void)?       = nil,
        mode:             VdDateTimeFieldMode = .dateTime,
        minimumDate:      Date?               = nil,
        maximumDate:      Date?               = nil,
        onChange:         ((Date?) -> Void)?  = nil
    ) {
        self.label            = label
        self._selection       = selection
        self.placeholder      = placeholder
        self.state            = state
        self.isOptional       = isOptional
        self.leadingIcon      = leadingIcon
        self.helperText       = helperText
        self.trailingIcon     = trailingIcon
        self.onTrailingAction = onTrailingAction
        self.mode             = mode
        self.minimumDate      = minimumDate
        self.maximumDate      = maximumDate
        self.onChange         = onChange
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Body
    // ─────────────────────────────────────────────────────────

    public var body: some View {
        VStack(alignment: .leading, spacing: VdSpacing.xs) {
            labelRow
            inputContainer
            if helperText != nil { helperRow }
        }
        .disabled(state == .disabled)
        .sheet(isPresented: $isPickerPresented) {
            DateTimePickerSheet(
                tempDate:    $tempDate,
                mode:        mode,
                pickerRange: pickerRange,
                onConfirm: { confirmed in
                    selection = confirmed
                    onChange?(confirmed)
                },
                onCancel: {}
            )
        }
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
    // Structure is intentionally identical to VdTextField so both
    // fields render at exactly the same height. Avoid wrapping in
    // Button — SwiftUI's internal _ButtonLabel wrapper can measure
    // the label slightly shorter than a bare HStack. Use
    // .contentShape + .onTapGesture instead.
    // ─────────────────────────────────────────────────────────

    private var inputContainer: some View {
        HStack(spacing: VdSpacing.sm) {

            // Leading icon
            if let icon = leadingIcon {
                VdIcon(icon, size: VdIconSize.md, color: leadingIconColor)
            }

            // Value text — mirrors VdTextField's Group { TextField } block exactly
            Group {
                if let date = selection {
                    Text(formattedDate(date))
                        .foregroundStyle(valueColor)
                } else {
                    Text(placeholder)
                        .foregroundStyle(Color.vdContentDefaultDisabled)
                }
            }
            .vdFont(.bodyMedium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 27)
            .padding(.vertical, VdSpacing.smMd)

            // Status icon (error / success / warning)
            if let statusIcon = statusIconName {
                VdIcon(statusIcon, size: VdIconSize.md, color: statusIconColor)
            }

            // Trailing action button — mirrors VdTextField's trailingIcon slot
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
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
                .strokeBorder(containerBorderColor, lineWidth: VdBorderWidth.sm)
        }
        .overlay {
            if isPickerPresented && state != .disabled {
                RoundedRectangle(
                    cornerRadius: VdRadius.md + 2,
                    style: .continuous
                )
                .strokeBorder(Color.vdBorderPrimaryTertiary, lineWidth: VdBorderWidth.md)
                .padding(-2)
            }
        }
        // Full-surface tap target — same behaviour as tapping a text field
        .contentShape(Rectangle())
        .onTapGesture {
            tempDate = selection ?? Date()
            isPickerPresented = true
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Helper row
    // ─────────────────────────────────────────────────────────

    @ViewBuilder
    private var helperRow: some View {
        if let helper = helperText {
            Text(helper)
                .vdFont(.bodySmall)
                .foregroundStyle(helperTextColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Date formatting
    // ─────────────────────────────────────────────────────────

    private func formattedDate(_ date: Date) -> String {
        switch mode {
        case .date:     return date.formatted(date: .abbreviated, time: .omitted)
        case .time:     return date.formatted(date: .omitted,     time: .shortened)
        case .dateTime: return date.formatted(date: .abbreviated, time: .shortened)
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Picker range
    // ─────────────────────────────────────────────────────────

    private var pickerRange: ClosedRange<Date> {
        let lower = minimumDate ?? Date.distantPast
        let upper = maximumDate ?? Date.distantFuture
        return lower <= upper ? lower...upper : upper...lower
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Derived tokens — container
    // ─────────────────────────────────────────────────────────

    private var containerBackground: Color {
        switch state {
        case .default, .success, .warning: return .vdBackgroundDefaultSecondary
        case .disabled:                    return .vdBackgroundDefaultDisabled
        case .error:                       return .vdBackgroundErrorSecondary
        }
    }

    private var containerBorderColor: Color {
        if isPickerPresented { return .vdBorderDefaultBase }
        switch state {
        case .default, .success, .warning: return .vdBorderDefaultSecondary
        case .disabled:                    return .vdBorderDefaultDisabled
        case .error:                       return .vdBorderErrorBase
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Derived tokens — content
    // ─────────────────────────────────────────────────────────

    private var labelTextColor: Color {
        switch state {
        case .disabled: return .vdContentDefaultDisabled
        case .error:    return .vdContentErrorBase
        default:        return .vdContentDefaultSecondary
        }
    }

    private var optionalTextColor: Color {
        state == .disabled ? .vdContentDefaultDisabled : .vdContentDefaultSecondary
    }

    private var leadingIconColor: Color {
        state == .disabled ? .vdContentDefaultDisabled : .vdContentDefaultTertiary
    }

    private var valueColor: Color {
        state == .disabled ? .vdContentDefaultDisabled : .vdContentDefaultBase
    }

    private var statusIconName: String? {
        switch state {
        case .error:   return "vd:danger-circle-filled"
        case .success: return "vd:check-circle-filled"
        case .warning: return "vd:danger-triangle-filled"
        default:       return nil
        }
    }

    private var statusIconColor: Color {
        switch state {
        case .error:   return .vdContentErrorBase
        case .success: return .vdContentSuccessBase
        case .warning: return .vdContentWarningBase
        default:       return .clear
        }
    }

    private var helperTextColor: Color {
        switch state {
        case .error:    return .vdContentErrorBase
        case .success:  return .vdContentSuccessBase
        case .warning:  return .vdContentWarningBase
        case .disabled: return .vdContentDefaultDisabled
        default:        return .vdContentDefaultSecondary
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — DateTimePickerSheet
// ─────────────────────────────────────────────────────────────

private struct DateTimePickerSheet: View {

    @Binding var tempDate: Date
    let mode:        VdDateTimeFieldMode
    let pickerRange: ClosedRange<Date>
    let onConfirm:   (Date) -> Void
    let onCancel:    () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var initialDate: Date?

    private var hasChanged: Bool {
        guard let initialDate else { return false }
        return !Calendar.current.isDate(tempDate, equalTo: initialDate, toGranularity: .second)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment:.leading, spacing: 0) {
                // ── Native picker ─────────────────────────────────
                if mode == .time {
                    DatePicker(
                        "",
                        selection: $tempDate,
                        in: pickerRange,
                        displayedComponents: mode.displayedComponents
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .tint(Color.vdContentPrimaryBase)
//                    .padding(.horizontal, VdSpacing.lg)
                } else {
                    DatePicker(
                        "",
                        selection: $tempDate,
                        in: pickerRange,
                        displayedComponents: mode.displayedComponents
                    )

                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .tint(Color.vdContentPrimaryBase)
//                    .padding(.horizontal, VdSpacing.lg)
                }
                Spacer(minLength: 0)

                // ── Full-width Done button ────────────────────────
                VdButton("Done", size: .medium, rounded: true, fullWidth: true) {
                    onConfirm(tempDate)
                    dismiss()
                }
                .padding(.horizontal, VdSpacing.s600)
                .padding(.top, VdSpacing.s600)
            }
            .navigationTitle(sheetTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
//                    Text("Hello")
                    Button {
                        onCancel()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.vdContentDefaultSecondary)
//                            .frame(width: 40, height: 40)
//
                            .contentShape(Circle())
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    }
                ToolbarItem(placement: .confirmationAction) {
                    if hasChanged{
                        Button("Reset") {
                            if let initialDate {
                                tempDate = initialDate
                            }
                        }
                        //                    .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.vdContentDefaultSecondary)
                        .disabled(!hasChanged)
                        .animation(.easeInOut(duration: 0.2), value: hasChanged)
                    }
                }
            }
        }
        .background(Color.vdBackgroundDefaultSecondary)

        .onAppear {
            initialDate = tempDate
        }
        .presentationDetents(sheetDetents)
        .presentationDragIndicator(.hidden)
        }

    private var sheetTitle: String {
        switch mode {
        case .date:     return "Select Date"
        case .time:     return "Select Time"
        case .dateTime: return "Select Date & Time"
        }
    }

    private var sheetDetents: Set<PresentationDetent> {
        switch mode {
        case .time:     return [.height(360)]
        case .date:     return [.height(520)]
        case .dateTime: return [.height(560)]
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — Preview
// ─────────────────────────────────────────────────────────────

#Preview("VdDateTimeField — All States") {
    ScrollView {
        VStack(alignment: .leading, spacing: VdSpacing.xl) {

            previewSection("Default — empty") {
                VdDateTimeField(
                    "Label",
                    selection: .constant(nil),
                    placeholder: "Placeholder",
                    isOptional: true,
                    leadingIcon: "square.grid.2x2",
                    helperText: "Tap to open the date & time picker"
                )
            }

            previewSection("Default — with value") {
                VdDateTimeField(
                    "Label",
                    selection: .constant(Date()),
                    placeholder: "Placeholder",
                    isOptional: true,
                    leadingIcon: "square.grid.2x2",
                    helperText: "Help or instruction text goes here"
                )
            }

            previewSection("Date only") {
                VdDateTimeField(
                    "Label",
                    selection: .constant(Date()),
                    placeholder: "Select date",
                    isOptional: true,
                    leadingIcon: "calendar",
                    helperText: "Help or instruction text goes here",
                    mode: .date
                )
            }

            previewSection("Time only") {
                VdDateTimeField(
                    "Label",
                    selection: .constant(Date()),
                    placeholder: "Select time",
                    isOptional: true,
                    leadingIcon: "clock",
                    helperText: "Help or instruction text goes here",
                    mode: .time
                )
            }

            previewSection("Disabled") {
                VdDateTimeField(
                    "Label",
                    selection: .constant(Date()),
                    placeholder: "Placeholder",
                    state: .disabled,
                    isOptional: true,
                    leadingIcon: "square.grid.2x2",
                    helperText: "Not available right now"
                )
            }

            previewSection("Error") {
                VdDateTimeField(
                    "Label",
                    selection: .constant(Date()),
                    placeholder: "Placeholder",
                    state: .error,
                    isOptional: true,
                    leadingIcon: "square.grid.2x2",
                    helperText: "Please select a valid date"
                )
            }

            previewSection("Success") {
                VdDateTimeField(
                    "Label",
                    selection: .constant(Date()),
                    placeholder: "Placeholder",
                    state: .success,
                    isOptional: true,
                    leadingIcon: "square.grid.2x2",
                    helperText: "Date confirmed"
                )
            }

            previewSection("Warning") {
                VdDateTimeField(
                    "Label",
                    selection: .constant(Date()),
                    placeholder: "Placeholder",
                    state: .warning,
                    isOptional: true,
                    leadingIcon: "square.grid.2x2",
                    helperText: "Selected date is in the past"
                )
            }

            previewSection("Interactive") {
                DateTimeFieldInteractiveDemo()
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
            .vdFont(.labelSmall)
            .foregroundStyle(Color.vdContentDefaultTertiary)
        content()
    }
}

private struct DateTimeFieldInteractiveDemo: View {
    @State private var date:     Date? = nil
    @State private var dateOnly: Date? = nil
    @State private var timeOnly: Date? = nil

    var body: some View {
        VStack(spacing: VdSpacing.md) {
            VdDateTimeField(
                "Date & Time",
                selection: $date,
                placeholder: "Select date & time",
                leadingIcon: "calendar.badge.clock",
                helperText: "Tap to pick",
                mode: .dateTime
            )

            VdDateTimeField(
                "Date",
                selection: $dateOnly,
                placeholder: "Select date",
                leadingIcon: "calendar",
                mode: .date
            )

            VdDateTimeField(
                "Time",
                selection: $timeOnly,
                placeholder: "Select time",
                leadingIcon: "clock",
                mode: .time
            )

            if date != nil || dateOnly != nil || timeOnly != nil {
                VStack(alignment: .leading, spacing: VdSpacing.xs) {
                    if let d = date {
                        Text("Date & Time: \(d.formatted(date: .abbreviated, time: .shortened))")
                    }
                    if let d = dateOnly {
                        Text("Date: \(d.formatted(date: .abbreviated, time: .omitted))")
                    }
                    if let t = timeOnly {
                        Text("Time: \(t.formatted(date: .omitted, time: .shortened))")
                    }
                }
                .vdFont(.bodySmall)
                .foregroundStyle(Color.vdContentDefaultSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(VdSpacing.md)
        .background(Color.vdBackgroundDefaultSecondary)
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
    }
}
// MARK: - iOS 16.4 availability wrapper

private struct PresentationCornerRadiusModifier: ViewModifier {
    let radius: CGFloat

    func body(content: Content) -> some View {
        if #available(iOS 16.4, *) {
            content.presentationCornerRadius(radius)
        } else {
            content
        }
    }
}

