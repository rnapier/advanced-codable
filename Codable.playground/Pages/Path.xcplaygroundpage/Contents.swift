import Foundation

/*
 Clothing    -- Children
             |- Adult
 Electronics -- Computers -- Laptops
 */

let json = Data(#"""
[
  { "name": "Clothing",
    "children": [
      { "name": "Children" },
      { "name": "Adult" }
    ]
  },
  { "name": "Electronics",
    "children": [
      { "name": "Computers",
        "children": [
          { "name": "Laptops" }
        ]
      }
    ]
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

    // For each element, decode out of the container by hand rather than recursing into init(from: Decoder)
    private init(from container: KeyedDecodingContainer<CodingKeys>, path: [String]) throws {
        // Track our own path up to this point
        self.path = path

        // Unload the simple stuff
        self.name = try container.decode(String.self, forKey: .name)

        // Construct the children, one element at a time (if children exists)
        var children: [Category] = []

        if container.contains(.children) {
            // Extract the array of children
            var childrenContainer = try container.nestedUnkeyedContainer(forKey: .children)
            let childPath = path + [self.name]
            while !childrenContainer.isAtEnd {
                // Extract the child object
                let childContainer = try childrenContainer.nestedContainer(keyedBy: CodingKeys.self)

                // For each child, pass the new path and decode
                let child = try Category(from: childContainer, path: childPath)

                // And append
                children.append(child)
            }
        }
        self.children = children
    }

    // Top level decoder to kick everything off
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(from: container, path: [])
    }
}

let result = try JSONDecoder().decode([Category].self, from: json)
dump(result)
