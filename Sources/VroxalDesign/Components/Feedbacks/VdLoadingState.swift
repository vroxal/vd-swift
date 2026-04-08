// Components/Feedback/VdLoadingState.swift — Vroxal Design

import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: — VdLoadingStyle
// ─────────────────────────────────────────────────────────────

public enum VdLoadingStyle {
    case inline     // renders in place within layout
    case overlay    // full-screen dimmed overlay
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdLoadingState
// ─────────────────────────────────────────────────────────────

public struct VdLoadingState: View {

    private let style:       VdLoadingStyle
    private let title:       String?
    private let description: String?

    public init(
        style:       VdLoadingStyle = .inline,
        title:       String?        = nil,
        description: String?        = nil
    ) {
        self.style       = style
        self.title       = title
        self.description = description
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Body
    // ─────────────────────────────────────────────────────────

    public var body: some View {
        switch style {
        case .inline:
            content
        case .overlay:
            ZStack {
                // Dimmed backdrop
                Color.vdBackgroundDefaultTertiary
                    .ignoresSafeArea()
                    .allowsHitTesting(true)     // blocks all taps beneath

                content
                    .padding(VdSpacing.xl)
                    .background(
                        RoundedRectangle(cornerRadius: VdRadius.lg)
                            .fill(Color.vdBackgroundDefaultSecondary)
                    )
                    .padding(VdSpacing.xl)
            }
        }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: Core content — spinner + optional text
    // ─────────────────────────────────────────────────────────

    private var content: some View {
        VStack(spacing: VdSpacing.lg) {         // 24pt gap (scale/spacing/600)

            // ── Spinner ───────────────────────────────────────
            ProgressView()
                .progressViewStyle(.circular)
        
            // ── Text block (only if title or description given) ──
            if title != nil || description != nil {
                VStack(spacing: VdSpacing.xs) { // 4pt gap (scale/spacing/100)
                    if let t = title {
                        Text(t)
                            .vdFont(.titleLarge)
                            .foregroundStyle(Color.vdContentDefaultBase)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    if let d = description {
                        Text(d)
                            .vdFont(.bodyMedium)
                            .foregroundStyle(Color.vdContentDefaultSecondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: 480)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — VdSkeletonModifier
// Shimmer animation for placeholder content.
// ─────────────────────────────────────────────────────────────

private struct VdSkeletonModifier: ViewModifier {

    let isEnabled:     Bool
    let cornerRadius:  CGFloat

    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        if isEnabled {
            content
                .hidden()
                .overlay(
                    GeometryReader { geo in
                        shimmer(width: geo.size.width)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    }
                )
        } else {
            content
        }
    }

    @ViewBuilder
    private func shimmer(width: CGFloat) -> some View {
        let secondary = Color.vdBackgroundNeutralSecondary
        let highlight = Color.vdBackgroundNeutralTertiary.opacity(0.6)
        let leadingStop = 0.3 + phase * 0.4
        let centerStop = 0.5 + phase * 0.4
        let trailingStop = 0.7 + phase * 0.4
        let stops: [Gradient.Stop] = [
            .init(color: secondary, location: 0),
            .init(color: secondary, location: leadingStop),
            .init(color: highlight, location: centerStop),
            .init(color: secondary, location: trailingStop),
            .init(color: secondary, location: 1),
        ]
        let gradient = LinearGradient(
            stops: stops,
            startPoint: .leading,
            endPoint: .trailing
        )

        Rectangle()
            .fill(gradient)
            .onAppear {
                withAnimation(
                    .linear(duration: 1.4).repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: — View extensions
// ─────────────────────────────────────────────────────────────

public extension View {

    /// Replaces this view with an animated shimmer placeholder.
    /// - Parameters:
    ///   - isEnabled: When true the shimmer is shown, when false the original view is shown.
    ///   - cornerRadius: Corner radius of the shimmer shape. Defaults to `VdRadius.xs` (4pt).
    func vdSkeleton(
        _ isEnabled:    Bool    = true,
        cornerRadius:   CGFloat = VdRadius.md
    ) -> some View {
        modifier(VdSkeletonModifier(isEnabled: isEnabled, cornerRadius: cornerRadius))
    }
}
