// Components/Forms/VdDateTimeField.swift — Vroxal Design
// ─────────────────────────────────────────────────────────────
// A styled date/time input matching VdTextField visuals.
// Uses the native compact DatePicker (.datePickerStyle(.compact))
// which renders as a tappable chip that opens the system
// calendar / clock popover inline — no sheet required.
//
// STATES → TOKEN MAPPING
//   Default   bg=BackgroundDefaultSecondary  border=BorderDefaultSecondary  1pt
//   Focus     bg=BackgroundDefaultSecondary  border=BorderDefaultBase       1pt
//             + focus ring BorderPrimaryTertiary 2pt outset 3pt
//   Disabled  bg=BackgroundDefaultDisabled   border=BorderDefaultDisabled   1pt
//             label=ContentDefaultDisabled   helper=ContentDefaultDisabled
//   Error     bg=BackgroundErrorSecondary    border=BorderErrorBase         1pt
//             label=ContentErrorBase         helper=ContentErrorBase
//             + exclamationmark.circle.fill trailing
//   Success   bg=BackgroundDefaultSecondary  border=BorderDefaultSecondary  1pt
//             helper=ContentSuccessBase
//             + checkmark.circle.fill trailing
//   Warning   bg=BackgroundDefaultSecondary  border=BorderDefaultSecondary  1pt
//             helper=ContentWarningBase
//             + exclamationmark.triangle.fill trailing
//
// HOW THE COMPACT PICKER WORKS
//   DatePicker with .datePickerStyle(.compact) renders a native
//   tappable label. Tapping it opens a calendar popover (date) or
//   a drum-roll popover (time) inline — iOS handles focus/dismiss.
//   We stretch the picker to fill the entire HStack row via
//   .frame(maxWidth: .infinity) + .clipped() and tint the label
//   text to match design tokens.
//
// LAYOUT
//   [Label ──────────────────── Optional]
//   [LeadingIcon  <DatePicker chip>  StatusIcon]  ← 48pt tall field
//   [Helper text]
//
// PROPS
//   label          — field label above the input
//   selection      — Binding<Date?> (nil = no value selected yet)
//   placeholder    — text shown in the chip when selection is nil
//   state          — VdInputState: default · disabled · error · success · warning
//   isOptional     — Bool: shows "Optional" tag right of label
//   leadingIcon    — icon token for leading slot (sf:/vd:)
//   helperText     — optional helper/instruction text below field
//   mode           — VdDateTimeFieldMode: .date · .time · .dateTime
//   minimumDate    — optional lower bound for the picker
//   maximumDate    — optional upper bound for the picker
//   onChange       — closure fired whenever selection changes
//
// USAGE
//   @State private var dob: Date? = nil
//
//   VdDateTimeField("Date of birth", selection: $dob,
//       placeholder: "Select date",
//       mode: .date,
//       helperText: "Must be 18+")
//
//   VdDateTimeField("Meeting time", selection: $meetingDate,
//       state: .error,
//       mode: .dateTime,
//       helperText: "Please choose a future time",
//       minimumDate: Date())
// ─────────────────────────────────────────────────────────────

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

    private let label:       String
    private let placeholder: String
    private let state:       VdInputState
    private let isOptional:  Bool
    private let leadingIcon: String?
    private let helperText:  String?
    private let mode:        VdDateTimeFieldMode
    private let minimumDate: Date?
    private let maximumDate: Date?
    private let onChange:    ((Date?) -> Void)?

    @Binding private var selection: Date?

    // Internal non-optional proxy required by DatePicker.
    // Defaults to "now" so the picker always opens at a sensible date.
    @State private var internalDate: Date = Date()

    public init(
        _ label:     String,
        selection:   Binding<Date?>,
        placeholder: String              = "Placeholder",
        state:       VdInputState        = .default,
        isOptional:  Bool                = false,
        leadingIcon: String?             = nil,
        helperText:  String?             = nil,
        mode:        VdDateTimeFieldMode = .dateTime,
        minimumDate: Date?               = nil,
        maximumDate: Date?               = nil,
        onChange:    ((Date?) -> Void)?  = nil
    ) {
        self.label       = label
        self._selection  = selection
        self.placeholder = placeholder
        self.state       = state
        self.isOptional  = isOptional
        self.leadingIcon = leadingIcon
        self.helperText  = helperText
        self.mode        = mode
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.onChange    = onChange
        // Seed internalDate from the existing selection if present
        self._internalDate = State(initialValue: selection.wrappedValue ?? Date())
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Body
    // ─────────────────────────────────────────────────────────

    public var body: some View {
        VStack(alignment: .leading, spacing: VdSpacing.xs) {
            labelRow
            inputContainer
            if let helper = helperText { helperRow(text: helper) }
        }
        // Keep internalDate in sync whenever selection is set externally
        .onChange(of: selection) { newValue in
            if let d = newValue { internalDate = d }
        }
        // Propagate picker changes back to the optional binding
        .onChange(of: internalDate) { newValue in
            selection = newValue
            onChange?(newValue)
        }
        .disabled(state == .disabled)
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Label row
    // ─────────────────────────────────────────────────────────

    private var labelRow: some View {
        HStack(spacing: VdSpacing.xs) {
            Text(label)
                .vdFont(.labelMedium)
                .foregroundStyle(labelTextColor)

            Spacer(minLength: 0)

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

            // Leading icon
            if let icon = leadingIcon {
                VdIcon(icon, size: VdIconSize.md, color: leadingIconColor)
            }

            // ── Compact DatePicker ─────────────────────────────
            // The compact style renders a single tappable date/time
            // label. When tapped, iOS presents a calendar or time
            // popover inline above/below the field.
            // We overlay a transparent placeholder Text when no date
            // is selected yet so the field shows placeholder copy.
            ZStack(alignment: .leading) {
                // Placeholder — visible only when selection is nil
                if selection == nil {
                    Text(placeholder)
                        .vdFont(.bodyMedium)
                        .foregroundStyle(Color.vdContentDefaultDisabled)
                        .allowsHitTesting(false)   // let taps fall through to DatePicker
                }

                DatePicker(
                    "",
                    selection: $internalDate,
                    in: pickerRange,
                    displayedComponents: mode.displayedComponents
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(valueColor)
                .opacity(selection == nil ? 0 : 1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    if selection == nil {
                        selection = internalDate
                    }
                }
            }
            .frame(maxWidth: .infinity)

            // Status icon (error / success / warning)
            if let statusIcon = statusIconName {
                VdIcon(statusIcon, size: VdIconSize.md, color: statusIconColor)
            }
        }
        .padding(.horizontal, VdSpacing.smMd)
        .padding(.vertical, VdSpacing.smMd)
        .frame(minHeight: 48)
        .background(containerBackground)
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.sm))
        .overlay {
            RoundedRectangle(cornerRadius: VdRadius.sm)
                .strokeBorder(containerBorderColor, lineWidth: VdBorderWidth.sm)
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Helper row
    // ─────────────────────────────────────────────────────────

    private func helperRow(text: String) -> some View {
        Text(text)
            .vdFont(.bodySmall)
            .foregroundStyle(helperTextColor)
            .frame(maxWidth: .infinity, alignment: .leading)
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
                    helperText: "Help or instruction text goes here"
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
                    helperText: "Help or instruction text goes here"
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
                    helperText: "Help or instruction text goes here"
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
                    helperText: "Help or instruction text goes here"
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
                    helperText: "Help or instruction text goes here"
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
    @State private var selectedDate: Date? = nil

    var body: some View {
        VStack(spacing: VdSpacing.md) {
            VdDateTimeField(
                "Schedule",
                selection: $selectedDate,
                placeholder: "Pick date & time",
                leadingIcon: "calendar",
                helperText: "Tap the date chip to open the picker"
            )

            if let selectedDate {
                Text("Selected: \(selectedDate.formatted(date: .abbreviated, time: .shortened))")
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
