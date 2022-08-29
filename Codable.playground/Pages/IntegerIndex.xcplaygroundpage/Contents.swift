import Foundation

let json = Data(#"""
[
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
]
"""#.utf8)

struct Person: Decodable {
    var name: String
    var age: Int
    var children: [Person]?
}

struct PersonResponse: Decodable {
    var person: Person
    init(from decoder: Decoder) throws {
        let container = try decoder.anyKeyedContainer()
        person = try container[1]
    }
}

let person = try JSONDecoder().decode(PersonResponse.self, from: json).person
print(person)

