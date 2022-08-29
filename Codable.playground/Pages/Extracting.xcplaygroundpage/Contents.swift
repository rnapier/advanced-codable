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

extension KeyedDecodingContainer {
    func decodeArray<Element: Decodable>(of type: Element.Type, forKey key: Key) throws -> [Element] {
        var nestedContainer = try self.nestedUnkeyedContainer(forKey: key)
        var values: [Element] = []
        values.reserveCapacity(nestedContainer.count ?? 0)

        while !nestedContainer.isAtEnd {
            values.append(try nestedContainer.decode(Element.self))
        }
        return values
    }
}

struct Person: Codable {
    var name: String
    var age: Int
    var children: [Person]?

    enum CodingKeys: CodingKey {
        case name
        case age
        case children
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.age = try container.decode(Int.self, forKey: .age)

        if container.contains(.children) {
            self.children = try container.decodeArray(of: Person.self,
                                                      forKey: .children)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.age, forKey: .age)

        if let children {
            var childrenContainer = container.nestedUnkeyedContainer(forKey: .children)
            for child in children {
                try childrenContainer.encode(child)
            }
        }
    }
}

let person = try JSONDecoder().decode(Person.self, from: json)
print(person)
