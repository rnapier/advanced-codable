import Foundation

let json = Data(#"""
{
    "name": "Alice",
    "age": 43,
    "addresses": [{
            "city": "New York",
            "street": "123 Wall St."
        },
        {
            "city": "New York",
            "street": "99 5th Ave."
        }
    ]
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

// Decode `[Address]` by hand.
extension Person: Decodable {
    enum CodingKeys: CodingKey {
        case name, age, addresses
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try container.decode(String.self, forKey: .name)
        self.age = try container.decode(Int.self, forKey: .age)

        var addressContainer = try container.nestedUnkeyedContainer(forKey: .addresses)
        var addresses: [Address] = []

        while !addressContainer.isAtEnd {
            addresses.append(try addressContainer.decode(Address.self))
        }

        self.addresses = addresses
    }
}

let person = try JSONDecoder().decode(Person.self, from: json)
print(person)
