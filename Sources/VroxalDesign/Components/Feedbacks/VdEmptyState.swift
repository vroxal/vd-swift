// Components/Feedback/VdEmptyState.swift — Vroxal Design

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
        icon: String = "vd:info-circle-filled",
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
        VdIcon(icon, size: VdIconSize.xl, color: .vdContentDefaultSecondary)
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
