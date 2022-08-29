import Foundation

struct Event {
    var type: Int
    var name: String
    var attributes: [String: String]
}

extension Event: Decodable {
    init(from decoder: Decoder) throws {
        let c = try decoder.anyKeyedContainer()

        self.type = try c["type"]
        self.name = try c["name"]

        let attributeKeys = Set(c.allKeys).subtracting(["type", "name"])

        let keyValues = try attributeKeys.map {
            ($0.stringValue, try c.decode(String.self, forKey: $0))
        }

        self.attributes = Dictionary(uniqueKeysWithValues: keyValues)
    }
}

extension Event: Encodable {
    func encode(to encoder: Encoder) throws {
        var c = encoder.anyKeyedContainer()
        try c.encode(type, forKey: "type")
        try c.encode(self.name, forKey: "name")

        for (key, value) in self.attributes {
            try c.encode(value, forKey: AnyCodingKey(key))
        }
    }
}

let json = Data(#"""
{
   "type" : 1,
   "name" : "name",
   "attribute1" : "One",
   "attribute2" : "Two"
}
"""#.utf8)


let event = try JSONDecoder().decode(Event.self, from: json)
print(event)

let data = try JSONEncoder().encode(event)
let output = String(data: data, encoding: .utf8)!
print(output)
