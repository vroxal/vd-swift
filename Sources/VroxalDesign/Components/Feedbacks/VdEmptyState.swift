// Components/Feedback/VdEmptyState.swift — Vroxal Design
// ─────────────────────────────────────────────────────────────
// Figma source: node 541-11772
//
// Variants:
// - boxed: true/false
// - actions: primary + secondary (optional)
//
// Layout tokens from design:
// - Container gap: 24pt
// - Boxed padding: 40pt
// - Icon container padding: 16pt
// - Text gap: 4pt
// - Action gap: 16pt
// - Max width: 640pt
// ─────────────────────────────────────────────────────────────

import SwiftUI

public struct VdEmptyState: View {

    private let title: String
    private let description: String
    private let icon: String
    private let boxed: Bool
    private let actions: Bool
    private let primaryAction: Bool
    private let secondaryAction: Bool
    private let primaryActionTitle: String?
    private let secondaryActionTitle: String?
    private let onPrimaryAction: (() -> Void)?
    private let onSecondaryAction: (() -> Void)?

    public init(
        title: String = "Title goes here",
        description: String = "Nothing more exciting happening here in terms of content, but just filling up the space to make it look representative.",
        icon: String = "square.grid.2x2",
        boxed: Bool = true,
        actions: Bool = true,
        primaryAction: Bool = true,
        secondaryAction: Bool = true,
        primaryActionTitle: String? = "Confirm",
        secondaryActionTitle: String? = "Cancel",
        onPrimaryAction: (() -> Void)? = nil,
        onSecondaryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.boxed = boxed
        self.actions = actions
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.primaryActionTitle = primaryActionTitle
        self.secondaryActionTitle = secondaryActionTitle
        self.onPrimaryAction = onPrimaryAction
        self.onSecondaryAction = onSecondaryAction
    }

    public var body: some View {
        VStack(spacing: VdSpacing.lg) {
            iconContainer
            textContent

            if showsActions {
                HStack(spacing: VdSpacing.md) {
                    if secondaryAction, let secondaryActionTitle {
                        VdButton(
                            secondaryActionTitle,
                            color: .neutral,
                            style: .solid,
                            size: .small,
                            action: { onSecondaryAction?() }
                        )
                    }

                    if primaryAction, let primaryActionTitle {
                        VdButton(
                            primaryActionTitle,
                            size: .small,
                            action: { onPrimaryAction?() }
                        )
                    }
                }
            }
        }
        .frame(maxWidth: 640)
        .padding(boxed ? VdSpacing.xxl : 0)
        .background(boxed ? Color.vdBackgroundDefaultTertiary : .clear)
        .clipShape(
            RoundedRectangle(cornerRadius: boxed ? VdRadius.xl : VdRadius.lg, style: .continuous)
        )
        .overlay {
            if boxed {
                RoundedRectangle(cornerRadius: VdRadius.xl, style: .continuous)
                    .strokeBorder(Color.vdBorderDefaultTertiary, lineWidth: VdBorderWidth.sm)
            }
        }
    }

    private var iconContainer: some View {
        VdIcon(icon, size: VdIconSize.lg, color: .vdContentDefaultSecondary)
            .frame(width: VdIconSize.xl, height: VdIconSize.xl)
            .padding(VdSpacing.md)
            .background(boxed ? Color.vdBackgroundDefaultBase : Color.vdBackgroundDefaultTertiary)
            .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg, style: .continuous))
    }

    private var textContent: some View {
        VStack(spacing: VdSpacing.xs) {
            Text(title)
                .vdFont(.titleLarge)
                .foregroundStyle(Color.vdContentDefaultBase)
                .frame(maxWidth: .infinity)

            Text(description)
                .vdFont(.bodyMedium)
                .foregroundStyle(Color.vdContentDefaultSecondary)
                .frame(maxWidth: .infinity)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: 480)
    }

    private var showsActions: Bool {
        actions && (
            (primaryAction && primaryActionTitle != nil)
            || (secondaryAction && secondaryActionTitle != nil)
        )
    }
}

#Preview("VdEmptyState — All Variants") {
    ScrollView {
        VStack(alignment: .leading, spacing: VdSpacing.xl) {
            previewSection("Boxed · With Actions") {
                VdEmptyState()
                    .frame(maxWidth: .infinity)
            }

            previewSection("Plain · With Actions") {
                VdEmptyState(boxed: false)
                    .frame(maxWidth: .infinity)
            }

            previewSection("Boxed · No Actions") {
                VdEmptyState(
                    actions: false
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding(VdSpacing.lg)
    }
    .background(Color.vdBackgroundDefaultSecondary)
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
