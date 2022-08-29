import Foundation

struct Event {
    var type: String
    var name: String
    var attributes: [String: String]
}

extension Event: Decodable {
    enum CodingKeys: CodingKey, CaseIterable {
        case type, name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        var attributes = try container.decode([String: String].self)

        self.type = attributes.removeValue(forKey: "type") ?? ""
        self.name = attributes.removeValue(forKey: "name") ?? ""
        self.attributes = attributes
    }
}

extension Event: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.name, forKey: .name)

        try self.attributes.encode(to: encoder)
    }
}

let json = Data(#"""
{
   "type" : "type",
   "name" : "name",
   "attribute1" : "One",
   "attribute2" : "Two"
}
"""#.utf8)


let event = try JSONDecoder().decode(Event.self, from: json)
print(event)

let output = String(data: try JSONEncoder().encode(event), encoding: .utf8)!
print(output)
