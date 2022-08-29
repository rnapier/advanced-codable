do {
    struct Person: Decodable {
        var name: String?
        var age: Int?
        var children: [Person]?
    }

    let alice = Person(name: "Alice", age: 50, children: [
        Person(name: "Bob", age: 25, children: []),
        Person(name: "Charlie", age: 20, children: [])
    ])

    let name = alice.name ?? "UNKNOWN"
    let age = alice.age?.description ?? ""
    let children = alice.children?.map { $0.name ?? "" }.joined(separator: ", ") ?? ""

    let line = "\(alice.name ?? "UNKNOWN"), age \(alice.age?.description ?? ""), children: \(alice.children?.compactMap(\.name).joined(separator: ", ") ?? "")"
    print(line)
}

do {
    struct Person: Decodable {
        var name: String
        var age: Int
        var children: [Person]
    }

    let alice = Person(name: "Alice", age: 50, children: [
        Person(name: "Bob", age: 25, children: []),
        Person(name: "Charlie", age: 20, children: [])
    ])

    let name = alice.name
    let age = "\(alice.age)"
    let children = alice.children.map(\.name).joined(separator: ", ")

    let line = "\(alice.name), age \(alice.age), children: \(alice.children.map(\.name).joined(separator: ", "))"
    print(line)


}
