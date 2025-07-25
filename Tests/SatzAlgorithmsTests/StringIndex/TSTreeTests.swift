import Foundation
import SatzAlgorithms
import Testing

struct TSTreeTests {

  @Test
  static func test_Update() {
    let tree = TSTree<Int>()

    // insert() and count
    tree.insert("banana", 2)
    #expect(tree.count == 1)
    tree.insert("apple", 1)
    #expect(tree.count == 2)
    tree.insert("orange", 3)
    #expect(tree.count == 3)
    tree.insert("apple", 5)  // repeat "apple"
    #expect(tree.count == 3)
    tree.insert("tomato", 5)
    #expect(tree.count == 4)

    // get() and contains()
    #expect(tree.get("apple") == 5)
    #expect(tree.get("banana") == 2)
    #expect(tree.get("orange") == 3)
    #expect(tree.get("tomato") == 5)
    #expect(tree.get("red") == nil)
    #expect(tree.contains("apple"))
    #expect(tree.contains("banana"))
    #expect(tree.contains("orange"))
    #expect(tree.contains("tomato"))
    #expect(tree.contains("red") == false)

    // keys()
    #expect(tree.keys() == ["apple", "banana", "orange", "tomato"])

    // remove()
    tree.delete("appl")
    #expect(tree.count == 4)
    #expect(
      tree.prettyPrint() == """
        b 
        ├ left: a 
        │ └ mid: p 
        │   └ mid: p 
        │     └ mid: l 
        │       └ mid: e ✓
        ├ mid: a 
        │ └ mid: n 
        │   └ mid: a 
        │     └ mid: n 
        │       └ mid: a ✓
        └ right: o 
          ├ mid: r 
          │ └ mid: a 
          │   └ mid: n 
          │     └ mid: g 
          │       └ mid: e ✓
          └ right: t 
            └ mid: o 
              └ mid: m 
                └ mid: a 
                  └ mid: t 
                    └ mid: o ✓
        """)

    tree.delete("apple")
    #expect(tree.count == 3)
    #expect(
      tree.prettyPrint() == """
        b 
        ├ mid: a 
        │ └ mid: n 
        │   └ mid: a 
        │     └ mid: n 
        │       └ mid: a ✓
        └ right: o 
          ├ mid: r 
          │ └ mid: a 
          │   └ mid: n 
          │     └ mid: g 
          │       └ mid: e ✓
          └ right: t 
            └ mid: o 
              └ mid: m 
                └ mid: a 
                  └ mid: t 
                    └ mid: o ✓
        """)

    tree.delete("tomato")
    #expect(tree.count == 2)
    #expect(
      tree.prettyPrint() == """
        b 
        ├ mid: a 
        │ └ mid: n 
        │   └ mid: a 
        │     └ mid: n 
        │       └ mid: a ✓
        └ right: o 
          └ mid: r 
            └ mid: a 
              └ mid: n 
                └ mid: g 
                  └ mid: e ✓
        """)

    tree.delete("banana")
    #expect(tree.count == 1)
    #expect(
      tree.prettyPrint() == """
        b 
        └ right: o 
          └ mid: r 
            └ mid: a 
              └ mid: n 
                └ mid: g 
                  └ mid: e ✓
        """)

    tree.delete("orange")
    #expect(tree.count == 0)
    #expect(tree.prettyPrint() == "")

    tree.delete("red")
    #expect(tree.count == 0)
    #expect(tree.prettyPrint() == "")
  }

  @Test
  static func test_Matching() {
    let tree = TSTree<Int>()

    // add words that are not prefix-free
    tree.insert("apple", 1)
    tree.insert("app", 2)
    tree.insert("pine", 3)
    tree.insert("pineapple", 4)
    tree.insert("orange", 5)
    tree.insert("or", 6)
    tree.insert("orangejuice", 8)
    tree.insert("banana", 7)
    tree.insert("ban", 9)
    tree.insert("man", 13)
    tree.insert("bar", 10)
    tree.insert("barn", 11)
    tree.insert("baz", 12)

    // search for longest prefix of a key
    #expect(tree.findPrefix(of: "orange juice") == "orange")
    #expect(tree.findPrefix(of: "orangejuice") == "orangejuice")
    #expect(tree.findPrefix(of: "orangejuic") == "orange")
    #expect(tree.findPrefix(of: "orang") == "or")
    #expect(tree.findPrefix(of: "owl") == "")
    #expect(tree.findPrefix(of: "kiwi") == "")

    // search for keys with prefix
    #expect(tree.search(withPrefix: "ap") == ["app", "apple"])
    #expect(tree.search(withPrefix: "app") == ["app", "apple"])
    #expect(tree.search(withPrefix: "appl") == ["apple"])
    #expect(tree.search(withPrefix: "apple") == ["apple"])
    #expect(tree.search(withPrefix: "apples") == [])
    #expect(tree.search(withPrefix: "pin") == ["pine", "pineapple"])
    #expect(tree.search(withPrefix: "pine") == ["pine", "pineapple"])
    #expect(tree.search(withPrefix: "pineapple") == ["pineapple"])

    #expect(tree.search(withPrefix: "p") == ["pine", "pineapple"])
    #expect(tree.search(withPrefix: "p", maxResults: 2) == ["pine", "pineapple"])
    #expect(tree.search(withPrefix: "p", maxResults: 1) == ["pine"])
    #expect(tree.search(withPrefix: "p", maxResults: 0) == [])

    // search for keys that match a pattern
    #expect(tree.search("ba.") == ["ban", "bar", "baz"])
    #expect(tree.search("ba..") == ["barn"])
    #expect(tree.search("ba.n") == ["barn"])
    #expect(tree.search(".a.") == ["ban", "bar", "baz", "man"])
    #expect(tree.search(".an") == ["ban", "man"])
  }

  @Test
  static func test_Enumerate() {
    let tree = TSTree<Int>()

    tree.insert("apple", 1)
    tree.insert("app", 2)
    tree.insert("pine", 3)
    tree.insert("pineapple", 4)

    var results: [(String, Int)] = []
    tree.enumerateKeysAndValues { key, value in
      results.append((key, value))
      return true
    }

    #expect(
      "\(results)" == """
        [("app", 2), ("apple", 1), ("pine", 3), ("pineapple", 4)]
        """)
  }
}
