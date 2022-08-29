import Foundation

let json = try Data(contentsOf: #fileLiteral(resourceName: "ditto.json"))

let ditto = try JSONDecoder().decode(JSONValue.self, from: json)

try ditto
    .value(for: "abilities")
    .value(at: 1)
    .value(for: "ability")
    .value(for: "name")
    .stringValue()

try ditto["abilities"][1]["ability"]["name"].stringValue()

try ditto.dictionaryValue()

let dd = ditto.dynamic

dd.abilities[1].ability.name

dd.game_indices[0].version.name
dd.game_indices[0].version.wrong¸Name

let spriteURLs = try dd.sprites.versions["generation-i"]["red-blue"]
    ._jsonValue.dictionaryValue().values

let person: JSONValue = [
    "name": "Alice",
    "age": 43,
    "active": true,
    "addresses": [
        [
            "street": "123 Main St.",
            "city": "New York",
            "state": "NY"
        ],
        [
            "street": "987 South East Blvd.",
            "city": "Los Angeles",
            "state": "CA"
        ],
    ]
]

print(String(data: try JSONEncoder().encode(person), encoding: .utf8)!)
