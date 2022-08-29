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

    init(from decoder: Decoder) throws {
        let c = try decoder.anyKeyedContainer()

        name     = try c["name"]
        age      = try c["age"]
        children = try c[ifPresent: "children"]
    }
}

let person = try JSONDecoder().decode(Person.self, from: json)
print(person)

struct Person2: Decodable {
    var name: String
    var age: Int
    var children: [Person]?

    init(from decoder: Decoder) throws {
        let c = try decoder.anyKeyedContainer()

        name     = try c["name", default: ""]
        age      = try c["age"]
        children = try c[orEmpty: "children"]
    }
}
