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


struct Address: Decodable {
    var street: String
    var city: String
}

struct Person {
    var name: String
    var age: Int
    var addresses: [Address]
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
            self.addresses = try container.decode([Address].self, forKey: .addresses)
        } catch {
            self.addresses = [try container.decode(Address.self, forKey: .addresses)]
        }
    }
}

let person1 = try JSONDecoder().decode(Person.self, from: json1)
print(person1)

let person2 = try JSONDecoder().decode(Person.self, from: json2)
print(person2)
