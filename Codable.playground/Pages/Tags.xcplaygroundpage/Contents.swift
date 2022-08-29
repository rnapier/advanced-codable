import Foundation

let json = Data(#"""
[
    {
        "type": "book",
        "title": "The Title"
    },
    {
        "type": "author",
        "name": "Author Name",
        "id": 12345
    }
]
"""#.utf8)

struct Book: Decodable {
    var title: String
}

struct Author: Decodable {
    var name: String
    var id: Int
}

enum Record {
    case book(Book)
    case author(Author)
}

extension Record: Decodable {
    init(from decoder: Decoder) throws {
        enum CodingKeys: CodingKey { case type }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "book": self = .book(try Book(from: decoder))
        case "author": self = .author(try Author(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: .type,
                                                   in: container,
                                                   debugDescription: "Unknown type: \(type)")
        }
    }
}

let result = try JSONDecoder().decode([Record].self, from: json)
print(result)
