// Copyright 2024-2025 Lie Yan

import Foundation
import SatzAlgorithms
import Testing

struct TSTreeTests {

  @Test
  static func test_Update() {
    let tree = TSTree<Int>()

    // put() and count
    tree.put("banana", 2)
    #expect(tree.count == 1)
    tree.put("apple", 1)
    #expect(tree.count == 2)
    tree.put("orange", 3)
    #expect(tree.count == 3)
    tree.put("apple", 5)  // repeat "apple"
    #expect(tree.count == 3)
    tree.put("tomato", 5)
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
    tree.put("apple", 1)
    tree.put("app", 2)
    tree.put("pine", 3)
    tree.put("pineapple", 4)
    tree.put("orange", 5)
    tree.put("or", 6)
    tree.put("orangejuice", 8)
    tree.put("banana", 7)
    tree.put("ban", 9)
    tree.put("man", 13)
    tree.put("bar", 10)
    tree.put("barn", 11)
    tree.put("baz", 12)

    // search for longest prefix of a key
    #expect(tree.longestPrefixOf("orange juice") == "orange")
    #expect(tree.longestPrefixOf("orangejuice") == "orangejuice")
    #expect(tree.longestPrefixOf("orangejuic") == "orange")
    #expect(tree.longestPrefixOf("orang") == "or")
    #expect(tree.longestPrefixOf("owl") == "")
    #expect(tree.longestPrefixOf("kiwi") == "")

    // search for keys with prefix
    #expect(tree.keysWithPrefix("ap") == ["app", "apple"])
    #expect(tree.keysWithPrefix("app") == ["app", "apple"])
    #expect(tree.keysWithPrefix("appl") == ["apple"])
    #expect(tree.keysWithPrefix("apple") == ["apple"])
    #expect(tree.keysWithPrefix("apples") == [])
    #expect(tree.keysWithPrefix("pin") == ["pine", "pineapple"])
    #expect(tree.keysWithPrefix("pine") == ["pine", "pineapple"])
    #expect(tree.keysWithPrefix("pineapple") == ["pineapple"])

    // search for keys that match a pattern
    #expect(tree.keysThatMatch("ba.") == ["ban", "bar", "baz"])
    #expect(tree.keysThatMatch("ba..") == ["barn"])
    #expect(tree.keysThatMatch("ba.n") == ["barn"])
    #expect(tree.keysThatMatch(".a.") == ["ban", "bar", "baz", "man"])
    #expect(tree.keysThatMatch(".an") == ["ban", "man"])
  }
}
