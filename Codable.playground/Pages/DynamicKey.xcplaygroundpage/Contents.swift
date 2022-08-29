import Foundation

let json = Data(#"""
{
    "522b27": {
        "name": "Alice",
        "age": 43
    },
    "48181a": {
        "name": "Bob",
        "age": 35
    }
}
"""#.utf8)

struct Person {
    let id: String
    var name: String
    var age: Int
}

struct PersonResponse: Decodable {
    private enum PersonKeys: CodingKey {
        case name, age
    }
    var persons: [Person]
    init(from decoder: Decoder) throws {
        let container = try decoder.anyKeyedContainer()
        
        persons = try container.allKeys.map { id in
            let personContainer = try container.nestedContainer(keyedBy: PersonKeys.self, forKey: id)
            return Person(id:   id.stringValue,
                          name: try personContainer[.name],
                          age:  try personContainer[.age])
        }
    }
}

print(try JSONDecoder().decode(PersonResponse.self, from: json).persons)
