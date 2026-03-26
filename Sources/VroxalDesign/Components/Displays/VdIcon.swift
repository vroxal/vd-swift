import SwiftUI
import VroxalIcons

/// Shared icon view for system and package icons with consistent sizing/inset behavior.
public struct VdIcon: View {
    private let source: VdIconSource
    private let size: CGFloat
    private let color: Color?

    /// - Parameters:
    ///   - source: icon source (`.system` or `.custom`)
    ///   - size: icon width/height (defaults to `VdIconSize.md`)
    ///   - color: optional tint color. If nil, inherits foreground style from parent.
    public init(
        _ source: VdIconSource,
        size: CGFloat = VdIconSize.md,
        color: Color? = nil
    ) {
        self.source = source
        self.size = size
        self.color = color
    }

    /// - Parameters:
    ///   - source: icon source (`.system` or `.custom`)
    ///   - size: icon width/height (defaults to `VdIconSize.md`)
    ///   - color: optional tint color. If nil, inherits foreground style from parent.
    public init(
        source: VdIconSource,
        size: CGFloat = VdIconSize.md,
        color: Color? = nil
    ) {
        self.source = source
        self.size = size
        self.color = color
    }

    /// Convenience initializer using token parsing:
    /// - `sf:xmark` for SF Symbols
    /// - `vd:chat-square-filled` for package icons
    /// - no prefix defaults to SF Symbols
    public init(
        _ icon: String,
        size: CGFloat = VdIconSize.md,
        color: Color? = nil
    ) {
        self.source = .parse(icon)
        self.size = size
        self.color = color
    }

    private var resolvedInset: CGFloat {
        source.defaultInset(for: size)
    }

    public var body: some View {
        let base = Image.vdIcon(source)
            .resizable()
            .scaledToFit()
            .padding(resolvedInset)
            .frame(width: size, height: size)

        if let color {
            base.foregroundStyle(color)
        } else {
            base
        }
    }
}
