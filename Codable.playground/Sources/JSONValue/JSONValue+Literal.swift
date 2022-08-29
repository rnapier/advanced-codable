// ExpressibleBy...Literal
extension JSONValue: ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) {
    self = .string(value)
  }
}

extension JSONValue: ExpressibleByUnicodeScalarLiteral {
  public init(unicodeScalarLiteral value: String) {
    self = .string(String(value))
  }
}

extension JSONValue: ExpressibleByExtendedGraphemeClusterLiteral {
  public init(extendedGraphemeClusterLiteral value: String) {
    self = .string(String(value))
  }
}

extension JSONValue: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: IntegerLiteralType) {
    self = .number(digits: "\(value)")
  }
}

extension JSONValue: ExpressibleByFloatLiteral {
  public init(floatLiteral value: FloatLiteralType) {
    self = .number(digits: "\(value)")
  }
}

extension JSONValue: ExpressibleByNilLiteral {
  public init(nilLiteral: ()) {
    self = .null
  }
}

extension JSONValue: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: BooleanLiteralType) {
    self = .bool(value)
  }
}

extension JSONValue: ExpressibleByArrayLiteral {
  public typealias ArrayLiteralElement = JSONValue
  public init(arrayLiteral elements: ArrayLiteralElement...) {
    self = .array(elements)
  }
}

extension JSONValue: ExpressibleByDictionaryLiteral {
  public typealias Key = String
  public typealias Value = JSONValue
  public init(dictionaryLiteral elements: (Key, Value)...) {
    self = .object(keyValues: elements)
  }
}
