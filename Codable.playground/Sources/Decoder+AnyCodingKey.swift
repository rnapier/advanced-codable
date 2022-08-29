import Foundation

extension Decoder {
    public func anyKeyedContainer() throws ->
    KeyedDecodingContainer<AnyCodingKey> {
        try container(keyedBy: AnyCodingKey.self)
    }
}

extension Encoder {
    public func anyKeyedContainer() -> KeyedEncodingContainer<AnyCodingKey> {
        container(keyedBy: AnyCodingKey.self)
    }
}

extension KeyedDecodingContainer {
    public func decode<T: Decodable>(_ key: Key) throws -> T {
        try self.decode(T.self, forKey: key)
    }
    public func decodeIfPresent<T: Decodable>(_ key: Key) throws -> T? {
        try self.decodeIfPresent(T.self, forKey: key)
    }

    public subscript<T: Decodable>(key: Key) -> T {
        get throws { try self.decode(T.self, forKey: key) }
    }
    public subscript<T: Decodable>(ifPresent key: Key) -> T? {
        get throws { try self.decodeIfPresent(T.self, forKey: key) }
    }

    public subscript<T: Decodable>(key: Key, default value: T) -> T {
        get throws { try self.decodeIfPresent(T.self, forKey: key) ?? value }
    }

    public subscript<T>(orEmpty key: Key) -> T
    where T: Decodable & RangeReplaceableCollection {
        get throws { try self.decodeIfPresent(T.self, forKey: key) ?? .init()}
    }

    public subscript<T: Decodable>(key: Key, failWith value: T) -> T {
        get {
            do {
                return try decode(T.self, forKey: key)
            } catch {
                assertionFailure("Could not decode \(key): \(error)")
                return value
            }
        }
    }

    public subscript<C>(compactingErrors key: Key) -> C
    where C : RangeReplaceableCollection, C.Element: Decodable {
        get {
            guard contains(key) else { return .init() }
            do {
                var container = try nestedUnkeyedContainer(forKey: key)
                return container.decodeCompactingErrors()
            } catch {
                assertionFailure("Could not decode \(key): \(error)")
                return .init()
            }
        }
    }

    public func nestedAnyContainer(_ key: Key) throws -> KeyedDecodingContainer<AnyCodingKey> {
        try nestedContainer(keyedBy: AnyCodingKey.self, forKey: key)
    }

}

extension UnkeyedDecodingContainer {
    public mutating func decodeCompactingErrors<C>(_: C.Type = C.self) -> C
    where C: RangeReplaceableCollection, C.Element: Decodable {
        var result: C = .init()
        while !isAtEnd {
            do { result.append(try self.decode(C.Element.self)) }
            catch { assertionFailure(
                "Could not decode element in \(codingPath) at index \(currentIndex): \(error)") }
        }
        return result
    }

    public mutating func map<T>(_ transform: (Decoder) throws -> T) throws -> [T] {
        var result: [T] = []
        while !isAtEnd {
            let childDecoder = try superDecoder()
            let element = try transform(childDecoder)
            result.append(element)
        }

        return result
    }
}
