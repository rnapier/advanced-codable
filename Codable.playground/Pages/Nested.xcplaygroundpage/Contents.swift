//: [Previous](@previous)

import Foundation

let json = Data(#"""
{
    "name": "Alice",
    "address": {
        "city": "New York"
    }
}
"""#.utf8)

struct Subscriber {
    var name: String
    var city: String
}

extension Subscriber: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        self.name = try container.decode(String.self, forKey: "name")

        self.city = try container
            .nestedContainer(keyedBy: AnyCodingKey.self, forKey: "address")
            .decode(String.self, forKey: "city")
    }
}


let event = try JSONDecoder().decode(Subscriber.self, from: json)
print(event)


//: [Next](@next)
