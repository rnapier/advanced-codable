import Foundation

/*
 Clothing    -- Children
             |- Adult
 Electronics -- Computers -- Laptops
 */

let json = Data(#"""
[{
        "name": "Clothing",
        "children": [{
            "name": "Children"
        }, {
            "name": "Adult"
        }]
    },
    {
        "name": "Electronics",
        "children": [{
            "name": "Computers",
            "children": [{
                "name": "Laptops"
            }]
        }]
    }
]
"""#.utf8)

struct Category {
    var name: String
    var children: [Category]
    var path: [String]
}

extension Category: Decodable {
    enum CodingKeys: CodingKey {
        case name, children
    }

    private static func decodeChildren(from container: inout UnkeyedDecodingContainer,
                                       at path: [String]) throws -> [Self] {
        // Construct the children, one element at a time (if children exists)
        var children: [Self] = []

        // For each child
        while !container.isAtEnd {
            // Extract the child object
            let childDecoder = try container.superDecoder()

            // Pass the new path and decode recursively
            children.append(try Self(from: childDecoder, path: path))
        }
        return children
    }

    private init(from decoder: Decoder, path: [String]) throws {
        // Track our own path up to this point
        self.path = path

        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Unload the simple stuff
        self.name = try container[.name]

        // Decode the children
        if container.contains(.children) {
            var childPath = path
            childPath.append(self.name)

            var childrenContainer = try container.nestedUnkeyedContainer(forKey: .children)

            self.children = try Self.decodeChildren(from: &childrenContainer, at: childPath)
        } else {
            self.children = []
        }
    }

    // Top level decoder to kick everything off
    init(from decoder: Decoder) throws {
        try self.init(from: decoder, path: [])
    }
}

let result = try JSONDecoder().decode([Category].self, from: json)
dump(result)
