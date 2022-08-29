// Returns value or null
@dynamicMemberLookup
public struct DynamicJSONValue {
    public var jsonValue: JSONValue
    public init(_ jsonValue: JSONValue) {
        jsonValue = jsonValue
    }

    public subscript(dynamicMember key: String) -> Self {
        self[key]
    }

    public subscript(_ key: String) -> Self {
        Self((try? jsonValue[key]) ?? .null)
    }

    public subscript(_ index: Int) -> Self {
        Self((try? jsonValue[index]) ?? .null)
    }
}

extension DynamicJSONValue: CustomStringConvertible {
    public var description: String { jsonValue.description }
}

extension JSONValue {
    public var dynamic: DynamicJSONValue { DynamicJSONValue(self) }
}
