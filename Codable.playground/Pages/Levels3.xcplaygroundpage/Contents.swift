import Foundation

struct Event {
    var type: Int
    var name: String
    var attributes: [String: String]
}

extension Event: Decodable {
    enum CodingKeys: CodingKey, CaseIterable {
        case type, name
    }

    init(from decoder: Decoder) throws {
        let explicitContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try explicitContainer[.type]
        self.name = try explicitContainer[.name]

        let attributeContainer = try decoder.anyKeyedContainer()

        let allKeys = attributeContainer.allKeys.map(\.stringValue)
        let explicitKeys = CodingKeys.allCases.map(\.stringValue)
        let attributeKeys = Set(allKeys).subtracting(explicitKeys)

        let keyValues = try attributeKeys.map {
            ($0, try attributeContainer.decode(String.self, forKey: AnyCodingKey($0)))
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
