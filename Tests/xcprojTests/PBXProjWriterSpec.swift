import Foundation
import XCTest
import PathKit

@testable import xcproj

class PBXProjEncoderSpec: XCTestCase {

    func test_dictionaryPlistValue_returnsTheCorrectValue() {
        let dictionary: [String: Any] = [
            "a": "b",
            "c": ["d", "e"],
            "f": [
                "g": "h"
            ]
        ]
        let plist = dictionary.plist()
        XCTAssertEqual(plist.dictionary?[CommentedString("a")], .string(CommentedString("b")))
        XCTAssertEqual(plist.dictionary?[CommentedString("c")], .array([.string(CommentedString("d")), .string(CommentedString("e"))]))
        XCTAssertEqual(plist.dictionary?[CommentedString("f")], .dictionary([CommentedString("g"): .string(CommentedString("h"))]))
    }

    func test_arrayPlistValue_returnsTheCorrectValue() {
        let array: [Any] = [
            "a",
            ["b", "c"],
            ["d": "e"]
        ]
        let plist = array.plist()
        XCTAssertEqual(plist.array?[0], .string(CommentedString("a")))
        XCTAssertEqual(plist.array?[1], .array([.string(CommentedString("b")), .string(CommentedString("c"))]))
        XCTAssertEqual(plist.array?[2], .dictionary([CommentedString("d"): .string(CommentedString("e"))]))
    }

    func test_commentedStringEscaping() {

        let quote = "\""
        let escapedNewline = "\\n"
        let escapedQuote = "\\\""
        let escapedEscape = "\\\\"

        let values: [String: String] = [
            "a": "a",
            "a".quoted: "\(escapedQuote)a\(escapedQuote)".quoted,
            "@": "@".quoted,
            "[": "[".quoted,
            "<": "<".quoted,
            ">": ">".quoted,
            ";": ";".quoted,
            "&": "&".quoted,
            "$": "$",
            "{": "{".quoted,
            "}": "}".quoted,
            "\\": escapedEscape.quoted,
            "+": "+".quoted,
            "-": "-".quoted,
            "=": "=".quoted,
            ",": ",".quoted,
            " ": " ".quoted,
            "\t": "\t".quoted,
            "a;": "a;".quoted,
            "a_a": "a_a",
            "a a": "a a".quoted,
            "": "".quoted,
            "a\(quote)q\(quote)a": "a\(escapedQuote)q\(escapedQuote)a".quoted,
            "a\(quote)q\(quote)a".quoted: "\(escapedQuote)a\(escapedQuote)q\(escapedQuote)a\(escapedQuote)".quoted,
            "a\(escapedQuote)a\(escapedQuote)": "a\(escapedEscape)\(escapedQuote)a\(escapedEscape)\(escapedQuote)".quoted,
            "a\na": "a\na".quoted,
            "\n": "\n".quoted,
            "\na": "\na".quoted,
            "a\n": "a\n".quoted,
            "a\na".quoted: "\(escapedQuote)a\na\(escapedQuote)".quoted,
            "a\(escapedNewline)a": "a\(escapedEscape)na".quoted,
            "a\(escapedNewline)a".quoted: "\(escapedQuote)a\(escapedEscape)na\(escapedQuote)".quoted,
            "\"": escapedQuote.quoted,
            "\"\"": "\(escapedQuote)\(escapedQuote)".quoted,
            "".quoted.quoted: "\(escapedQuote)\(escapedQuote)\(escapedQuote)\(escapedQuote)".quoted,
            "a=\"\"": "a=\(escapedQuote)\(escapedQuote)".quoted,
            "马旭": "马旭".quoted,
        ]

        for (initial, expected) in values {
            let escapedString = CommentedString(initial).validString
            if escapedString != expected {
                XCTFail("Escaped strings are not equal:\ninitial: \(initial)\nexpect:  \(expected)\nescaped: \(escapedString) ")
            }
        }

        XCTAssertEqual(CommentedString("\t", specialFlag: true).validString, "\\t".quoted)
        XCTAssertEqual(CommentedString("\n", specialFlag: true).validString, "\\n".quoted)
    }

    func testShellScriptEscaping() {
        let buildPhase = PBXShellScriptBuildPhase(shellScript: """
        \u{9}cd ..
        \u{9}echo Hello world
        """)
        let proj = PBXProj(objectVersion: 1, rootObject: "", archiveVersion: 1)
        let (_, value) = buildPhase.plistKeyAndValue(proj: proj, reference: "ref")

        if let shellScriptString = value.dictionary?["shellScript"]?.string {
            XCTAssertEqual(shellScriptString.validString, "\\tcd ..\\n\\techo Hello world".quoted)
        } else {
            XCTFail("Expected 'shellScript' string.")
        }
    }

}
