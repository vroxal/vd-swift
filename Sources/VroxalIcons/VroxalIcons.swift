import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Resolves icons either from SF Symbols or this package's asset catalog.
public enum VdIconSource: Hashable, Sendable {
    case system(String)
    case custom(String)
    // Backward-compatible alias for previous naming.
    case asset(String)

    public static func sf(_ symbolName: String) -> Self {
        .system(symbolName)
    }

    public static func package(_ assetName: String) -> Self {
        .custom(assetName)
    }

    /// Parses icon tokens for a compact single-string API:
    /// - `sf:xmark` / `system:xmark` -> SF Symbol
    /// - `vd:chat-square-filled` / `asset:chat-square-filled` -> package asset (template tint)
    /// - no prefix -> SF Symbol (backward-compatible default)
    public static func parse(_ token: String) -> Self {
        let raw = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let separator = raw.firstIndex(of: ":") else {
            return .system(raw)
        }

        let scheme = raw[..<separator].lowercased()
        let value = String(raw[raw.index(after: separator)...]).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return .system(raw) }

        switch scheme {
        case "sf", "system":
            return .system(value)
        case "vd", "asset", "pkg", "package":
            return .custom(value)
        default:
            return .system(raw)
        }
    }

    /// Optical inset used when placing icons into fixed square containers.
    /// SF Symbols generally need a tiny inset on common icon sizes.
    public func defaultInset(for size: CGFloat) -> CGFloat {
        switch self {
        case .system:
            return 2
        case .custom, .asset:
            return 0
        }
    }
}

public extension Image {
    static func vdIcon(_ source: VdIconSource) -> Image {
        switch source {
        case .system(let symbolName):
            return Image(systemName: symbolName)
        case .custom(let assetName), .asset(let assetName):
            // Package icons default to template mode so token colors apply.
            return Image(assetName, bundle: .module).renderingMode(.template)
        }
    }

    static func vdIcon(_ token: String) -> Image {
        vdIcon(.parse(token))
    }
}

/// Convenience accessors for icon assets in `VroxalIcons`.
public enum VdIcons {
    public static func image(named name: String) -> Image {
        Image(name, bundle: .module)
    }

#if canImport(UIKit)
    public static func uiImage(named name: String) -> UIImage? {
        UIImage(named: name, in: .module, compatibleWith: nil)
    }
#endif
}
