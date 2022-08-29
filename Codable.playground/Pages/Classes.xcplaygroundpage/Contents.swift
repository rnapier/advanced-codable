//: [Previous](@previous)

import Foundation

class Super: Encodable {
    var superProperty: String
    init(superProperty: String) { self.superProperty = superProperty }
}

class Sub: Super {
    enum CodingKeys: CodingKey {
        case subProperty
    }
    var subProperty: String
    init(superProperty: String, subProperty: String) {
        self.subProperty = subProperty
        super.init(superProperty: superProperty)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.subProperty, forKey: .subProperty)
        try super.encode(to: container.superEncoder())
//        try super.encode(to: encoder)
    }
}

let value = Sub(superProperty: "Super", subProperty: "Sub")
let data = try JSONEncoder().encode(value)
print(String(data: data, encoding: .utf8)!)
