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
}

let person = try JSONDecoder().decode(Person.self, from: json)
print(person)

