import Foundation

public enum VDFParserError: Error, LocalizedError, Equatable {
    case unexpectedEnd
    case unexpectedToken(String)
    case expectedString

    public var errorDescription: String? {
        switch self {
        case .unexpectedEnd:
            return "Unexpected end of VDF input."
        case let .unexpectedToken(token):
            return "Unexpected VDF token: \(token)"
        case .expectedString:
            return "Expected a quoted VDF string."
        }
    }
}

public struct VDFNode: Equatable, Sendable {
    public var values: [String: String]
    public var children: [String: VDFNode]

    public init(values: [String: String] = [:], children: [String: VDFNode] = [:]) {
        self.values = values
        self.children = children
    }

    public func value(named name: String) -> String? {
        if let value = values[name] {
            return value
        }
        return values.first { key, _ in key.caseInsensitiveCompare(name) == .orderedSame }?.value
    }

    public func child(named name: String) -> VDFNode? {
        if let child = children[name] {
            return child
        }
        return children.first { key, _ in key.caseInsensitiveCompare(name) == .orderedSame }?.value
    }
}

public struct VDFParser: Sendable {
    public init() {}

    public func parse(_ source: String) throws -> VDFNode {
        let tokens = tokenize(source)
        var cursor = VDFCursor(tokens: tokens)
        return try parseRoot(cursor: &cursor)
    }

    private func parseRoot(cursor: inout VDFCursor) throws -> VDFNode {
        var root = VDFNode()

        while let token = cursor.peek() {
            guard token != "}" else {
                throw VDFParserError.unexpectedToken(token)
            }

            guard let key = cursor.nextString() else {
                throw VDFParserError.expectedString
            }

            guard let valueToken = cursor.peek() else {
                throw VDFParserError.unexpectedEnd
            }

            if valueToken == "{" {
                _ = cursor.next()
                root.children[key] = try parseObject(cursor: &cursor)
            } else if let value = cursor.nextString() {
                root.values[key] = value
            } else {
                throw VDFParserError.unexpectedToken(valueToken)
            }
        }

        return root
    }

    private func parseObject(cursor: inout VDFCursor) throws -> VDFNode {
        var node = VDFNode()

        while let token = cursor.peek() {
            if token == "}" {
                _ = cursor.next()
                return node
            }

            guard let key = cursor.nextString() else {
                throw VDFParserError.expectedString
            }

            guard let nextToken = cursor.peek() else {
                throw VDFParserError.unexpectedEnd
            }

            if nextToken == "{" {
                _ = cursor.next()
                node.children[key] = try parseObject(cursor: &cursor)
            } else if let value = cursor.nextString() {
                node.values[key] = value
            } else {
                throw VDFParserError.unexpectedToken(nextToken)
            }
        }

        throw VDFParserError.unexpectedEnd
    }

    private func tokenize(_ source: String) -> [String] {
        var tokens: [String] = []
        var index = source.startIndex

        while index < source.endIndex {
            let character = source[index]

            if character.isWhitespace {
                source.formIndex(after: &index)
                continue
            }

            if character == "/", source.index(after: index) < source.endIndex, source[source.index(after: index)] == "/" {
                index = consumeLineComment(in: source, from: index)
                continue
            }

            if character == "{" || character == "}" {
                tokens.append(String(character))
                source.formIndex(after: &index)
                continue
            }

            if character == "\"" {
                let result = consumeQuotedString(in: source, from: index)
                tokens.append(result.value)
                index = result.nextIndex
                continue
            }

            let result = consumeBareToken(in: source, from: index)
            tokens.append(result.value)
            index = result.nextIndex
        }

        return tokens
    }

    private func consumeLineComment(in source: String, from startIndex: String.Index) -> String.Index {
        var index = startIndex
        while index < source.endIndex, !source[index].isNewline {
            source.formIndex(after: &index)
        }
        return index
    }

    private func consumeQuotedString(in source: String, from startIndex: String.Index) -> (value: String, nextIndex: String.Index) {
        var index = source.index(after: startIndex)
        var value = ""
        var isEscaped = false

        while index < source.endIndex {
            let character = source[index]

            if isEscaped {
                switch character {
                case "n":
                    value.append("\n")
                case "t":
                    value.append("\t")
                default:
                    value.append(character)
                }
                isEscaped = false
                source.formIndex(after: &index)
                continue
            }

            if character == "\\" {
                isEscaped = true
                source.formIndex(after: &index)
                continue
            }

            if character == "\"" {
                source.formIndex(after: &index)
                return (value, index)
            }

            value.append(character)
            source.formIndex(after: &index)
        }

        return (value, index)
    }

    private func consumeBareToken(in source: String, from startIndex: String.Index) -> (value: String, nextIndex: String.Index) {
        var index = startIndex
        var value = ""

        while index < source.endIndex {
            let character = source[index]
            if character.isWhitespace || character == "{" || character == "}" {
                break
            }
            value.append(character)
            source.formIndex(after: &index)
        }

        return (value, index)
    }
}

private struct VDFCursor {
    private let tokens: [String]
    private var position: Int = 0

    init(tokens: [String]) {
        self.tokens = tokens
    }

    func peek() -> String? {
        guard position < tokens.count else { return nil }
        return tokens[position]
    }

    mutating func next() -> String? {
        guard position < tokens.count else { return nil }
        defer { position += 1 }
        return tokens[position]
    }

    mutating func nextString() -> String? {
        guard let token = peek(), token != "{", token != "}" else { return nil }
        return next()
    }
}