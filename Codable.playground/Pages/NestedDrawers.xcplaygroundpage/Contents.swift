import Foundation

let json = Data("""
{
  "7E7-M001" : {
    "Drawer1" : {
      "101" : {
        "Partnumber" : "F101"
      },
      "102" : {
        "Partnumber" : "F121"
      }
    },
    "Drawer2" : {
      "101" : {
        "Partnumber" : "F101"
      },
      "102" : {
        "Partnumber" : "F121"
      }
    }
  },
  "7E7-M002": {
    "Drawer1": {
      "201": {
        "Partnumber": "F201"
      },
      "202": {
        "Partnumber": "F221"
      }
    }
  }
}
""".utf8)

extension Decoder {
    func keyedContainer() throws -> KeyedDecodingContainer<AnyCodingKey> {
        try container(keyedBy: AnyCodingKey.self)
    }
}
extension KeyedDecodingContainer {
    func decodeAllKeys<T: Decodable>(as type: T.Type = T.self) throws -> [T] {
        try allKeys.map { try T(from: superDecoder(forKey: $0)) }
    }
}

//extension JSONDecoder {
//    private struct DecoderCloner: Decodable {
//        var decoder: Decoder
//        init(from decoder: Decoder) throws {
//            self.decoder = decoder
//        }
//    }
//
//    func decoder(for data: Data) throws -> Decoder {
//        try decode(DecoderCloner.self, from: data).decoder
//    }
//
//    func decode<T: Decodable>(_ type: T.Type, from data: Data, using strategy: (Decoder) throws -> T) throws -> T {
//        try strategy(decoder(for: data))
//    }
//
//    func decodeDictionaryAsArray<T: Decodable>(of type: T.Type, from data: Data) throws -> [T] {
//        try decode([T].self, from: data, using: {
//            try $0.keyedContainer().decodeAllKeys()
//        })
//    }
//}

struct Container: Decodable {
    var name: String
    var drawers: [Drawer]

    init(from decoder: Decoder) throws {
        self.name = decoder.codingPath.last?.stringValue ?? ""
        self.drawers = try decoder.keyedContainer().decodeAllKeys()
    }
}

struct Drawer: Decodable {
    var name: String
    var tools: [Tool]

    init(from decoder: Decoder) throws {
        self.name = decoder.codingPath.last?.stringValue ?? ""
        self.tools = try decoder.keyedContainer().decodeAllKeys()
    }
}

struct Tool: Decodable {
    var name: String
    var partNumber: String

    init(from decoder: Decoder) throws {
        self.name = decoder.codingPath.last?.stringValue ?? ""
        self.partNumber = try decoder.keyedContainer().decode(String.self, forKey: "Partnumber")
    }
}

//let decoder = try JSONDecoder().decoder(for: json)
//let containers = try decoder.keyedContainer().decodeAllKeys(as: Container.self)
let containers = try JSONDecoder().decode([String: Container].self, from: json).values
print(containers)

