import Foundation

/// String that includes a comment
struct CommentedString {
    
    /// Entity string value.
    let string: String
    
    /// String comment.
    let comment: String?

    /// Tab and new line should be escaped for valid string
    let specialFlag: Bool
    
    /// Initializes the commented string with the value and the comment.
    ///
    /// - Parameters:
    ///   - string: string value.
    ///   - comment: comment.
    ///   - specialFlag: tab and new line should be escaped for valid string
    init(_ string: String, comment: String? = nil, specialFlag: Bool = false) {
        self.string = string
        self.comment = comment
        self.specialFlag = specialFlag
    }

    private static var invalidCharacters: CharacterSet = {
        var invalidSet = CharacterSet(charactersIn: "_$")
        invalidSet.insert(charactersIn: UnicodeScalar(".")...UnicodeScalar("9"))
        invalidSet.insert(charactersIn: UnicodeScalar("A")...UnicodeScalar("Z"))
        invalidSet.insert(charactersIn: UnicodeScalar("a")...UnicodeScalar("z"))
        invalidSet.invert()
        return invalidSet
    }()

    var validString: String {
        switch string {
            case "": return "".quoted
            case "false": return "NO"
            case "true": return "YES"
            default: break
        }

        var escaped = string

        let replacements: [Character: String] = [
            "\u{0}": "\\U0000",
            "\u{1}": "$(inherited)",
            "\u{2}": "\\U0002",
            "\u{3}": "\\U0003",
            "\u{4}": "\\U0004",
            "\u{5}": "\\U0005",
            "\u{6}": "\\U0006",
            "\u{7}": "\\a",
            "\u{8}": "\\b",
            "\u{9}": specialFlag ? "\\t" : "\t",
            "\u{a}": specialFlag ? "\\n" : "\n",
            "\u{b}": "\\v",
            "\u{c}": "\\f",
            "\u{e}": "\\U000e",
            "\u{f}": "\\U000f",
            "\u{10}": "\\U0010",
            "\u{11}": "\\U0011",
            "\u{12}": "\\U0012",
            "\u{13}": "\\U0013",
            "\u{14}": "\\U0014",
            "\u{15}": "\\U0015",
            "\u{16}": "\\U0016",
            "\u{17}": "\\U0017",
            "\u{18}": "\\U0018",
            "\u{19}": "\\U0019",
            "\u{1a}": "\\U001a",
            "\u{1b}": "\\U001b",
            "\u{1c}": "\\U001c",
            "\u{1d}": "\\U001d",
            "\u{1e}": "\\U001e",
            "\u{1f}": "\\U001f",
            "\u{22}": "\\\"",
            "\u{5c}": "\\\\"
        ]

        // NB! It is important to escape `\` character before replacing other characters with it.
        // To achieve it, reverse `replacements` and start with `\` (0x5c) key.
        for (key, value) in replacements.sorted(by: { $0.key > $1.key }) {
            if escaped.contains(key) {
                escaped = escaped.replacingOccurrences(of: "\(key)", with: value)
            }
        }

        if !escaped.isQuoted && escaped.rangeOfCharacter(from: CommentedString.invalidCharacters) != nil {
            escaped = escaped.quoted
        }

        return escaped
    }
    
}

// MARK: - CommentedString Extension (Hashable)

extension CommentedString: Hashable {
    
    var hashValue: Int { return string.hashValue }
    static func == (lhs: CommentedString, rhs: CommentedString) -> Bool {
        return lhs.string == rhs.string && lhs.comment == rhs.comment
    }
    
}

// MARK: - CommentedString Extension (ExpressibleByStringLiteral)

extension CommentedString: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self.init(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        self.init(value)
    }
    
}
