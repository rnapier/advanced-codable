import Foundation

public struct AnyCodingKey: Hashable {
    public let stringValue: String
    public var intValue: Int?
    public init(stringValue: String, intValue: Int?) {
        self.stringValue = stringValue
        self.intValue = intValue
    }
}

extension AnyCodingKey: CodingKey {
    public init(stringValue: String) { self.init(stringValue: stringValue, intValue: nil) }
    public init(intValue: Int) { self.init(stringValue: "\(intValue)", intValue: intValue) }
}

extension AnyCodingKey {
    public init(_ key: some CodingKey) { self.init(stringValue: key.stringValue, intValue: key.intValue) }
    public init(_ key: some CodingKeyRepresentable) { self.init(stringValue: key.codingKey.stringValue) }
}

extension AnyCodingKey: CustomStringConvertible {
    public var description: String { stringValue }
}

extension AnyCodingKey: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) { self.init(value) }
}

extension AnyCodingKey: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) { self.init(intValue: value) }
}

extension AnyCodingKey: Comparable {
    public static func < (lhs: AnyCodingKey, rhs: AnyCodingKey) -> Bool {
        lhs.stringValue < rhs.stringValue
    }
}

