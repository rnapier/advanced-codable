import Foundation
import CoreGraphics

let json = Data(#"""
{
    "name": "A",
    "location": [100, 250]
}
"""#.utf8)

struct MapPoint: Decodable {
    var name: String
    var location: CGPoint
}

let point = try JSONDecoder().decode(MapPoint.self, from: json)
//print(point)

enum E: Decodable { case a,b,c }
