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

struct Person: Decodable {
    let id: String
    var name: String
    var age: Int

    enum CodingKeys: CodingKey { case name, age }

    init(from decoder: Decoder) throws {
        guard let id = decoder.codingPath.last?.stringValue else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath,
                                                    debugDescription: "Person is not in expected container"))
        }
        self.id = id
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container[.name]
        self.age = try container[.age]
    }
}

print(try JSONDecoder().decode([String: Person].self, from: json).values)
