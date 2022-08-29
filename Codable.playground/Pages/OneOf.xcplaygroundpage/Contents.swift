import Foundation

let json1 = Data(#"""
{
    "name": "Alice",
    "age": 43,
    "addresses": [{
        "city": "New York",
        "street": "123 Wall St."
    }]
}
"""#.utf8)

let json2 = Data(#"""
{
    "name": "Alice",
    "age": 43,
    "addresses": {
        "city": "New York",
        "street": "123 Wall St."
    }
}
"""#.utf8)

let json3 = Data(#"""
{
    "name": "Alice",
    "age": 43
}
"""#.utf8)

let json4 = Data(#"""
{
    "name": "Alice",
    "age": 43,
    "addresses": [{
        "cityName": "New York",
        "streetName": "Wall St.",
        "streetNumber": "123"
    }]
}
"""#.utf8)

let json5 = Data(#"""
{
    "name": "Alice",
    "age": 43,
    "addresses": [{
        "cityame": "New York",
        "streetName": "Wall St.",
        "streetNumber": "123"
    }]
}
"""#.utf8)

struct Address: Decodable {
    var street: String
    var city: String
}

struct Person {
    var name: String
    var age: Int
    var addresses: [Address]
}

struct OldAddress: Decodable {
    var streetNumber: String?
    var streetName: String
    var cityName: String
}

extension Address {
    init(_ oldAddress: OldAddress) {
        self.street = [oldAddress.streetNumber, oldAddress.streetName].compactMap{$0}.joined(separator: " ")
        self.city = oldAddress.cityName
    }
}

struct KeyedDecodingAdapter<T: Decodable, Key: CodingKey> {
    struct Context {
        var container: KeyedDecodingContainer<Key>
        var key: Key
        var errors: [Error]
    }
    var transform: (Context) throws -> T
    var errors: [Error] = []

    static func from<U: Decodable>(_ f: @escaping (U) -> T) -> Self {
        Self(transform: { f(try $0.container.decode(U.self, forKey: $0.key))})
    }

    static func ifMissing(_ value: T) -> Self {
        Self {
            if !$0.container.contains($0.key) {
                return value
            } else {
                throw DecodingError.dataCorrupted(.init(codingPath: $0.container.codingPath,
                                                        debugDescription: "Found key when expected missing: \($0.key)"))
            }
        }
    }

    static func logErrors(_ message: String? = nil, returnValue: T) -> Self {
        Self(transform: { context in
            let message = message ?? "Error decoding '\(context.key.stringValue)'."
            print("\(message) \(context.errors)")
            return returnValue
        })
    }
}

extension KeyedDecodingAdapter where T: RangeReplaceableCollection, T.Element: Decodable {
    static var singleElement: Self { from { T.init(CollectionOfOne($0))} }
}

extension KeyedDecodingContainer {
    func decode<T: Decodable>(_ type: T.Type, forKey key: Key,
                              fallbacks: [KeyedDecodingAdapter<T, Key>]) throws -> T {
        do { return try decode(T.self, forKey: key) }
        catch let originalError {
            var errors = [originalError]
            for adapter in fallbacks {
                do {
                    return try adapter.transform(.init(container: self, key: key, errors: errors))
                } catch {
                    errors.append(error)
                }
            }
            throw originalError
        }
    }
}

// Decode either Address or [Address] for addresses
extension Person: Decodable {
    enum CodingKeys: CodingKey {
        case name, age, addresses
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try container.decode(String.self, forKey: .name)
        self.age = try container.decode(Int.self, forKey: .age)

        self.addresses = try container.decode([Address].self, forKey: .addresses,
                                              fallbacks: [
                                                .singleElement,
                                                .from { (old: [OldAddress]) in old.map(Address.init) },
                                                .from { (old: OldAddress) in [Address(old)] },
                                                .ifMissing([]),
                                                .logErrors(returnValue: []),
                                              ])
    }
}

let person1 = try JSONDecoder().decode(Person.self, from: json1)
print(person1)

let person2 = try JSONDecoder().decode(Person.self, from: json2)
print(person2)

let person3 = try JSONDecoder().decode(Person.self, from: json3)
print(person3)

let person4 = try JSONDecoder().decode(Person.self, from: json4)
print(person4)

let person5 = try JSONDecoder().decode(Person.self, from: json5)
print(person5)
