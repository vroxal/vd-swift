// Components/Actions/VdChip.swift — Vroxal Design System
// ─────────────────────────────────────────────────────────────
// Figma source: node 2216-19327
//
// A selectable chip / filter-tag component.
//
// VARIANTS
//   isSelected  — Bool: primary colors when selected, neutral when not
//   closable    — Bool: shows an xmark button on the trailing edge
//   icon        — optional leading icon (String? = nil)
//
// STATES
//   Default / Hover (press) / Focus / Disabled
//
// TOKEN MAP
//   Not selected  bg=NeutralSecondary   border=DefaultSecondary  text=DefaultSecondary
//   Selected      bg=PrimarySecondary   border=PrimarySecondary  text=PrimaryOnSecondary
//   Hover (NS)    bg=NeutralSecondaryHover
//   Hover (S)     bg=PrimarySecondaryHover
//   Disabled (NS) bg=DefaultDisabled    border=DefaultTertiary   text=DefaultDisabled
//   Disabled (S)  same selected colors + opacity 0.4 whole chip
//
// LAYOUT
//   Vertical padding  : VdSpacing.xs  (4pt)
//   Horizontal padding: VdSpacing.sm  (8pt) — leading always
//                       VdSpacing.sm  (8pt) — trailing when not closable
//                       VdSpacing.xl  (32pt) — trailing when closable (reserves close btn)
//   Corner radius     : VdRadius.md  (12pt)
//   Close button      : 24pt icon + 4pt padding on each side = 32pt
// ─────────────────────────────────────────────────────────────

import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: — VdChip
// ─────────────────────────────────────────────────────────────

public struct VdChip: View {

    private let label: String
    private let icon: String?           // optional leading icon
    private let isSelected: Bool
    private let closable: Bool
    private let onTap: (() -> Void)?
    private let onClose: (() -> Void)?

    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isFocused: Bool
    private let _backCompatDisabled: Bool

    public init(
        _ label: String,
        icon: String? = nil,
        isSelected: Bool = false,
        closable: Bool = false,
        isDisabled: Bool = false,
        onTap: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil
    ) {
        self.label = label
        self.icon = icon
        self.isSelected = isSelected
        self.closable = closable
        self._backCompatDisabled = isDisabled
        self.onTap = onTap
        self.onClose = onClose
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Body
    // ─────────────────────────────────────────────────────────

    public var body: some View {
        Button { onTap?() } label: {
            HStack(spacing: 0) {
                if let icon {
                    // Color is applied via foregroundStyle in the ButtonStyle
                    VdIcon(icon, size: VdIconSize.md)
                }
                Text(label)
                    .vdFont(.labelMedium)
                    .padding(.horizontal, VdSpacing.xs)
                    .lineLimit(1)
                if closable {
                    // Reserve trailing space for the overlaid close button
                    Color.clear
                        .frame(width: VdIconSize.md + VdSpacing.xs * 2)
                }
            }
            .padding(.vertical, VdSpacing.xs)
            .padding(.leading, VdSpacing.sm)
            .padding(.trailing, closable ? 0 : VdSpacing.sm)
            // Close button overlaid at trailing edge, inside label so it
            // intercepts taps before the outer chip button receives them.
            .overlay(alignment: .trailing) {
                if closable {
                    Button { onClose?() } label: {
                        VdIcon("vd:xmark", size: VdIconSize.md)
                            .padding(VdSpacing.xs)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .buttonStyle(
            VdChipButtonStyle(
                backgroundColor: backgroundColor,
                hoverBackgroundColor: hoverBackgroundColor,
                borderColor: borderColor,
                contentColor: { isPressed in contentColor(isPressed: isPressed) },
                visualOpacity: visualOpacity
            )
        )
        .overlay {
            if isFocused {
                RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
                    .strokeBorder(Color.vdBorderPrimaryTertiary, lineWidth: VdBorderWidth.md)
                    .padding(-3)
            }
        }
        .focused($isFocused)
        .disabled(_backCompatDisabled)
        .animation(.easeInOut(duration: 0.12), value: isEnabled)
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Derived tokens
    // ─────────────────────────────────────────────────────────

    private var isVisuallyDisabled: Bool {
        !isEnabled || _backCompatDisabled
    }

    /// Only selected + disabled dims the whole chip (unselected disabled uses different bg/border).
    private var visualOpacity: Double {
        isSelected && isVisuallyDisabled ? 0.4 : 1.0
    }

    private func contentColor(isPressed: Bool) -> Color {
        if isSelected {
            return .vdContentPrimaryOnSecondary
        } else if isVisuallyDisabled {
            return .vdContentDefaultDisabled
        } else {
            return isPressed ? .vdContentNeutralOnSecondary : .vdContentDefaultSecondary
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return .vdBackgroundPrimarySecondary
        } else if isVisuallyDisabled {
            return .vdBackgroundDefaultDisabled
        } else {
            return .vdBackgroundNeutralSecondary
        }
    }

    private var hoverBackgroundColor: Color {
        if isSelected {
            return .vdBackgroundPrimarySecondaryHover
        } else if isVisuallyDisabled {
            return .vdBackgroundDefaultDisabled
        } else {
            return .vdBackgroundNeutralSecondaryHover
        }
    }

    private var borderColor: Color {
        if isSelected {
            return .vdBorderPrimarySecondary
        } else if isVisuallyDisabled {
            return .vdBorderDefaultTertiary
        } else {
            return .vdBorderDefaultSecondary
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdChipButtonStyle
// ─────────────────────────────────────────────────────────────

private struct VdChipButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let hoverBackgroundColor: Color
    let borderColor: Color
    let contentColor: (Bool) -> Color
    let visualOpacity: Double

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        configuration.label
            .foregroundStyle(contentColor(isPressed))
            .background(
                RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
                    .fill(isPressed ? hoverBackgroundColor : backgroundColor)
            )
            .overlay {
                RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: VdBorderWidth.sm)
            }
            .opacity(visualOpacity)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: isPressed)
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — Preview
// ─────────────────────────────────────────────────────────────

#Preview("VdChip — All Variants") {
    ScrollView {
        VStack(alignment: .leading, spacing: VdSpacing.xl) {

            // ── Default (not selected, closable) ─────────────
            chipSection("Default · With Icon · Closable") {
                HStack(spacing: VdSpacing.sm) {
                    VdChip("Design", icon: "vd:palette", closable: true, onClose: {})
                    VdChip("Development", icon: "vd:code", closable: true, onClose: {})
                    VdChip("Marketing", closable: true, onClose: {})
                }
            }

            // ── Selected ──────────────────────────────────────
            chipSection("Selected · With Icon · Closable") {
                HStack(spacing: VdSpacing.sm) {
                    VdChip("Design", icon: "vd:palette", isSelected: true, closable: true, onClose: {})
                    VdChip("Development", icon: "vd:code", isSelected: true, closable: true, onClose: {})
                    VdChip("Marketing", isSelected: true, closable: true, onClose: {})
                }
            }

            // ── No close button ───────────────────────────────
            chipSection("No Close Button") {
                HStack(spacing: VdSpacing.sm) {
                    VdChip("Swift", icon: "vd:code")
                    VdChip("SwiftUI")
                    VdChip("Xcode", isSelected: true)
                    VdChip("iOS", icon: "vd:smartphone", isSelected: true)
                }
            }

            // ── Disabled states ───────────────────────────────
            chipSection("Disabled") {
                HStack(spacing: VdSpacing.sm) {
                    VdChip("Default", icon: "vd:palette", closable: true, isDisabled: true)
                    VdChip("Selected", icon: "vd:palette", isSelected: true, closable: true, isDisabled: true)
                }
            }

            // ── Interactive demo ──────────────────────────────
            chipSection("Interactive — Filter") {
                InteractiveChipDemo()
            }
        }
        .padding(VdSpacing.lg)
    }
    .background(Color.vdBackgroundDefaultBase)
}

private func chipSection<Content: View>(
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

private struct InteractiveChipDemo: View {
    @State private var selected: Set<String> = ["SwiftUI"]
    @State private var closableTags: [String] = ["Design", "Backend", "DevOps"]
    private let tags = ["Swift", "SwiftUI", "UIKit", "Combine", "Async/Await"]

    var body: some View {
        VStack(alignment: .leading, spacing: VdSpacing.md) {
            // ── Selectable filters ───────────────────────────
            VStack(alignment: .leading, spacing: VdSpacing.sm) {
                Text("Select technologies")
                    .vdFont(.labelSmall)
                    .foregroundStyle(Color.vdContentDefaultSecondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: VdSpacing.xs) {
                        ForEach(tags, id: \.self) { tag in
                            VdChip(
                                tag,
                                isSelected: selected.contains(tag),
                                onTap: {
                                    withAnimation {
                                        if selected.contains(tag) {
                                            selected.remove(tag)
                                        } else {
                                            selected.insert(tag)
                                        }
                                    }
                                }
                            )
                        }
                    }
                }
                if selected.isEmpty {
                    Text("No filters selected")
                        .vdFont(.labelSmall)
                        .foregroundStyle(Color.vdContentDefaultTertiary)
                } else {
                    Text("Selected: \(selected.sorted().joined(separator: ", "))")
                        .vdFont(.labelSmall)
                        .foregroundStyle(Color.vdContentPrimaryOnSecondary)
                }
            }

            // ── Closable / removable chips ───────────────────
            VStack(alignment: .leading, spacing: VdSpacing.sm) {
                Text("Removable tags")
                    .vdFont(.labelSmall)
                    .foregroundStyle(Color.vdContentDefaultSecondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: VdSpacing.xs) {
                        ForEach(closableTags, id: \.self) { tag in
                            VdChip(
                                tag,
                                icon: "vd:tag",
                                isSelected: true,
                                closable: true,
                                onClose: {
                                    withAnimation {
                                        closableTags.removeAll { $0 == tag }
                                    }
                                }
                            )
                        }
                    }
                }
                if closableTags.isEmpty {
                    Text("All tags removed")
                        .vdFont(.labelSmall)
                        .foregroundStyle(Color.vdContentDefaultTertiary)
                }
            }
        }
        .padding(VdSpacing.md)
        .background(Color.vdBackgroundDefaultSecondary)
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg))
    }
}
