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

struct Root {
    var categories: [Category]
    var totalCount: Int
}

extension Root: Decodable {
    init(from decoder: Decoder) throws {
        var totalCount = 0

        var container = try decoder.unkeyedContainer()
        self.categories = try container.map {
            try Category(from: $0,
                         path: [],
                         totalCount: &totalCount)
        }
        self.totalCount = totalCount
    }
}

struct Category {
    var name: String
    var children: [Category]
    var path: [String]
}

extension Category {
    enum CodingKeys: CodingKey {
        case name, children
    }

    init(from decoder: Decoder, path: [String], totalCount: inout Int) throws {
        // Track our own path up to this point
        self.path = path

        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Unload the simple stuff
        self.name = try container[.name]

        // Construct the children, one element at a time (if children exists)
        var children: [Self] = []
        if container.contains(.children) {
            var childPath = path
            childPath.append(self.name)

            // Extract the array of children
            var childrenContainer = try container.nestedUnkeyedContainer(forKey: .children)
            children = try childrenContainer.map {
                try Category(from: $0, path: childPath, totalCount: &totalCount)
            }
        }
        self.children = children
        totalCount += 1
    }
}

let result = try JSONDecoder().decode(Root.self, from: json)
dump(result)
