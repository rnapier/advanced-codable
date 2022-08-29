//: [Previous](@previous)

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

// Decode either Address or [Address] for addresses
extension Person: Decodable {
    enum CodingKeys: CodingKey {
        case name, age, addresses
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try container.decode(String.self, forKey: .name)
        self.age = try container.decode(Int.self, forKey: .age)

        do {
            self.addresses = try container.decodeIfPresent([Address].self, forKey: .addresses) ?? []
        } catch let originalError {
            do {
                self.addresses =
                (try? container.decode(Address.self, forKey: .addresses)).map({[$0]}) ??
                (try? container.decode([OldAddress].self, forKey: .addresses).map(Address.init)) ??
                (try? container.decode(OldAddress.self, forKey: .addresses)).map({[Address($0)]}) ??
                {
                    assertionFailure("Unexpected address format. \(originalError)")
                    return []
                }()
            }
        }
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
