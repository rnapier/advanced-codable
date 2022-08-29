import Foundation

let json = Data(#"""
{
    "name": "Alice",
    "age": 43,
    "children": [{
            "name": "Charlie",
            "age": 15
        },
        {
            "name": "Denice",
            "age": 10
        }
    ]
}
"""#.utf8)

public struct AnyCodingKey: CodingKey, CustomStringConvertible, ExpressibleByStringLiteral,
                            ExpressibleByIntegerLiteral, Hashable, Comparable {
    public var description: String { stringValue }
    public let stringValue: String
    public init(_ string: String) { self.stringValue = string }
    public init?(stringValue: String) { self.init(stringValue) }
    public var intValue: Int?
    public init(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
    public init(stringLiteral value: String) { self.init(value) }
    public init(integerLiteral value: Int) { self.init(intValue: value) }
    public static func < (lhs: AnyCodingKey, rhs: AnyCodingKey) -> Bool {
        lhs.stringValue < rhs.stringValue
    }
}

extension Decoder {
     var anyKeyedContainer: KeyedDecodingContainer<AnyCodingKey> {
        get throws { try container(keyedBy: AnyCodingKey.self) }
    }

    func decode<T>(_ key: AnyCodingKey) throws -> T where T : Decodable {
        try anyKeyedContainer.decode(T.self, forKey: key)
    }

    func decodeIfPresent<T>(_ key: AnyCodingKey) throws -> T? where T : Decodable {
        try anyKeyedContainer.decodeIfPresent(T.self, forKey: key)
    }

    func decode<T>(_ key: AnyCodingKey, default: T) throws -> T where T : Decodable {
        try anyKeyedContainer.decodeIfPresent(T.self, forKey: key) ?? `default`
    }

    func decodeOrEmpty<C>(_ key: AnyCodingKey, type: C.Type = C.self) throws -> C
    where C : RangeReplaceableCollection & Decodable {
        try decode(key, default: .init())
    }
}

extension KeyedDecodingContainer {
    func decode<T>(_ key: Key, type: T.Type = T.self, default value: T? = nil) throws -> T
    where T : Decodable {
        if let value {
            return try decodeIfPresent(T.self, forKey: key) ?? value
        } else {
            return try decode(T.self, forKey: key)
        }
    }

    func decode<T>(_ key: Key, type: T.Type = T.self, failWith value: T) -> T
    where T : Decodable {
        do {
            return try decode(T.self, forKey: key)
        } catch {
            assertionFailure("Could not decode \(key): \(error)")
            return value
        }
    }

    func decodeCompactingErrors<C>(_ key: Key, type: C.Type = C.self) -> C
    where C : RangeReplaceableCollection, C.Element: Decodable {
        guard contains(key) else { return .init() }
        do {
            var container = try nestedUnkeyedContainer(forKey: key)
            var result: C = .init()
            while !container.isAtEnd {
                do {
                    result.append(try container.decode(C.Element.self))
                } catch {
                    assertionFailure("Could not decode element in \(container.codingPath) at index \(container.currentIndex): \(error)")
                }
            }
            return result
        } catch {
            assertionFailure("Could not decode \(key): \(error)")
            return .init()
        }
    }
}

struct Person {
    var name: String
    var age: Int
    var children: [Person]
}

extension Person: Decodable {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: AnyCodingKey.self)

        self.name     = c.decode("name", failWith: "")
        self.age      = try c.decode("age")
        self.children = c.decodeCompactingErrors("children")
    }
}

let person = try JSONDecoder().decode(Person.self, from: json)
print(person)


