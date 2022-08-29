import Foundation

let json = Data(#"""
{
    "response": {
        "results": [{
            "name": "Alice",
            "age": 43
        }],
        "count": 1
    },
    "status": 200
}
"""#.utf8)

struct Person: Decodable {
    var name: String
    var age: Int
}

struct PersonResponse: Decodable {
    var results: [Person]
    init(from decoder: Decoder) throws {
        let c = try decoder.anyKeyedContainer()
        results = try decoder.anyKeyedContainer()
            .nestedAnyContainer("response")
            .decode("results")
    }
}

let persons = try JSONDecoder().decode(PersonResponse.self, from: json).results
print(persons)

extension JSONDecoder {
    private struct DecoderCloner: Decodable {
        var decoder: Decoder
        init(from decoder: Decoder) throws {
            self.decoder = decoder
        }
    }

    func decoder(for data: Data) throws -> Decoder {
        try decode(DecoderCloner.self, from: data).decoder
    }
}

let decoder = try JSONDecoder().decoder(for: json)

try decoder.container(keyedBy: AnyCodingKey.self)
    .nestedContainer(keyedBy: AnyCodingKey.self, forKey: "response")
    .decode([Person].self, forKey: "results")
