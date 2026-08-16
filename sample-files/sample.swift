// Swift sample: protocols, extensions, optionals, enums with associated values.

import Foundation

let defaultHex = "#EEFFFF"
let maxDepth = 8

enum TokenKind: String, CaseIterable {
    case comment
    case keyword
    case string
    case number

    var isItalic: Bool {
        switch self {
        case .comment:
            return true
        default:
            return false
        }
    }
}

enum PaletteError: Error, LocalizedError {
    case invalidHex(String)
    case notFound(label: String)

    var errorDescription: String? {
        switch self {
        case .invalidHex(let hex):
            return "Invalid hex value: \(hex)"
        case .notFound(let label):
            return "Swatch not found: \(label)"
        }
    }
}

protocol Describable {
    var label: String { get }
    func describe() -> String
}

extension Describable {
    func shout() -> String {
        describe().uppercased()
    }
}

struct Swatch: Describable, Codable, Hashable {
    let label: String
    var hex: String = defaultHex
    var tags: [String] = []

    func describe() -> String {
        "\(label) => \(hex)"
    }

    var luminance: Double {
        let stripped = hex.dropFirst()
        guard stripped.count == 6, let value = Int(stripped, radix: 16) else {
            return -1
        }

        let red = Double((value >> 16) & 0xFF)
        let green = Double((value >> 8) & 0xFF)
        let blue = Double(value & 0xFF)

        return (0.2126 * red + 0.7152 * green + 0.0722 * blue) / 255
    }
}

final class Registry {
    private(set) var name: String
    private var swatches: [String: Swatch] = [:]

    init(name: String) {
        self.name = name
    }

    var count: Int { swatches.count }

    subscript(label: String) -> Swatch? {
        get { swatches[label] }
        set { swatches[label] = newValue }
    }

    func add(_ swatch: Swatch) throws {
        guard swatch.hex.hasPrefix("#"), swatch.hex.count == 7 else {
            throw PaletteError.invalidHex(swatch.hex)
        }

        swatches[swatch.label] = swatch
    }

    func sortedLabels() -> [String] {
        swatches.values
            .filter { $0.hex != defaultHex }
            .map(\.label)
            .sorted()
    }
}

let registry = Registry(name: "Themes of Shibbir")

let incoming = [
    Swatch(label: "background", hex: "#263238", tags: ["ui"]),
    Swatch(label: "keyword", hex: "#C792EA"),
]

for swatch in incoming {
    do {
        try registry.add(swatch)
        print("\(swatch.describe())  luminance=\(String(format: "%.4f", swatch.luminance))")
    } catch let error as PaletteError {
        print("skipped: \(error.localizedDescription)")
    } catch {
        print("unexpected: \(error)")
    }
}

let multiline = """
    Multi-line string literal.
    Interpolation works: \(registry.count) swatches, max depth \(maxDepth).
    """

print(multiline)
print(TokenKind.allCases.filter(\.isItalic).map(\.rawValue))
