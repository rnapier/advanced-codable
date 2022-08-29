import Foundation

extension JSONValue: Decodable {
  public init(from decoder: Decoder) throws {
    let matchers = [decodeNil, decodeString, decodeNumber,
                    decodeBool, decodeObject, decodeArray]

    for matcher in matchers {
      do {
        self = try matcher(decoder)
        return
      }
      catch DecodingError.typeMismatch { continue }
    }

    throw DecodingError.typeMismatch(JSONValue.self,
                                     .init(codingPath: decoder.codingPath,
                                           debugDescription: "Unknown JSON type"))
  }
}

extension JSONValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    switch self {
    case .string(let string):
      var container = encoder.singleValueContainer()
      try container.encode(string)

    case .number:
      var container = encoder.singleValueContainer()
      try container.encode(try self.decimalValue())

    case .bool(let value):
      var container = encoder.singleValueContainer()
      try container.encode(value)

    case .object(keyValues: let keyValues):
      var container = encoder.container(keyedBy: StringKey.self)
      for (key, value) in keyValues {
        try container.encode(value, forKey: StringKey(key))
      }

    case .array(let values):
      var container = encoder.unkeyedContainer()
      for value in values {
        try container.encode(value)
      }

    case .null:
      var container = encoder.singleValueContainer()
      try container.encodeNil()
    }
  }
}

private func decodeString(decoder: Decoder) throws -> JSONValue {
  try .string(decoder.singleValueContainer().decode(String.self))
}

private func decodeNumber(decoder: Decoder) throws -> JSONValue {
  try .number(digits: decoder.singleValueContainer().decode(Decimal.self).description)
}

private func decodeBool(decoder: Decoder) throws -> JSONValue {
  try .bool(decoder.singleValueContainer().decode(Bool.self))
}

private func decodeObject(decoder: Decoder) throws -> JSONValue {
  let object = try decoder.container(keyedBy: StringKey.self)
  let pairs = try object.allKeys.map(\.stringValue).map { key in
    (key, try object.decode(JSONValue.self, forKey: StringKey(key)))
  }
  return .object(keyValues: pairs)
}

private func decodeArray(decoder: Decoder) throws -> JSONValue {
  var array = try decoder.unkeyedContainer()
  var result: [JSONValue] = []
  if let count = array.count { result.reserveCapacity(count) }
  while !array.isAtEnd { result.append(try array.decode(JSONValue.self)) }
  return .array(result)
}

private func decodeNil(decoder: Decoder) throws -> JSONValue {
  if try decoder.singleValueContainer().decodeNil() { return .null }
  else { throw DecodingError.typeMismatch(JSONValue.self,
                                          .init(codingPath: decoder.codingPath,
                                                debugDescription: "Did not find nil")) }
}

// MARK: - StringKey
private struct StringKey: CodingKey, Hashable, CustomStringConvertible {
  public var description: String { stringValue }

  public let stringValue: String
  public init(_ string: String) { self.stringValue = string }
  public init?(stringValue: String) { self.init(stringValue) }
  public var intValue: Int? { nil }
  public init?(intValue: Int) { nil }
}
