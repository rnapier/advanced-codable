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

struct Person: Decodable {
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

        if try container.contains(.children) && !container.decodeNil(forKey: .children) {
            var childrenContainer = try container.nestedUnkeyedContainer(forKey: .children)
            var children: [Person] = []

            while !childrenContainer.isAtEnd {
                children.append(try childrenContainer.decode(Person.self))
            }
            self.children = children
        }
    }
}

let person = try JSONDecoder().decode(Person.self, from: json)
print(person)

