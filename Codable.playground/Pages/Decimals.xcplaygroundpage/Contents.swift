import Foundation

let decimal = Decimal(string: "0.1")!
let double = 0.1

3 * double == 0.3
3 * decimal == 0.3

let json = Data(#"""
0.1
"""#.utf8)

let decodedDecimal = try JSONDecoder().decode(Decimal.self, from: json)
3 * decodedDecimal == 0.3
