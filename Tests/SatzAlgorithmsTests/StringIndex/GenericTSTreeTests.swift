// Copyright 2024-2025 Lie Yan

import Foundation
import SatzAlgorithms
import Testing

struct GenericTSTreeTests {
  typealias _TSTree = GenericTSTree<Character, Int>
  typealias _Key = _TSTree.Key
  typealias _Slice = ArraySlice<Character>

  @Test
  static func test_Update() {
    let tree = _TSTree()

    // insert() and count
    tree.insert(_Key("banana"), 2)
    #expect(tree.count == 1)
    tree.insert(_Key("apple"), 1)
    #expect(tree.count == 2)
    tree.insert(_Key("orange"), 3)
    #expect(tree.count == 3)
    tree.insert(_Key("apple"), 5)  // repeat "apple"
    #expect(tree.count == 3)
    tree.insert(_Key("tomato"), 5)
    #expect(tree.count == 4)

    // get() and contains()
    #expect(tree.get(_Key("apple")) == 5)
    #expect(tree.get(_Key("banana")) == 2)
    #expect(tree.get(_Key("orange")) == 3)
    #expect(tree.get(_Key("tomato")) == 5)
    #expect(tree.get(_Key("red")) == nil)
    #expect(tree.contains(_Key("apple")))
    #expect(tree.contains(_Key("banana")))
    #expect(tree.contains(_Key("orange")))
    #expect(tree.contains(_Key("tomato")))
    #expect(tree.contains(_Key("red")) == false)

    // keys()
    #expect(
      tree.keys() == [_Key("apple"), _Key("banana"), _Key("orange"), _Key("tomato")])

    // remove()
    tree.delete(_Key("appl"))
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

    tree.delete(_Key("apple"))
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

    tree.delete(_Key("tomato"))
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

    tree.delete(_Key("banana"))
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

    tree.delete(_Key("orange"))
    #expect(tree.count == 0)
    #expect(tree.prettyPrint() == "")

    tree.delete(_Key("red"))
    #expect(tree.count == 0)
    #expect(tree.prettyPrint() == "")
  }

  @Test
  static func test_Matching() {
    let tree = _TSTree()

    // add words that are not prefix-free
    tree.insert(_Key("apple"), 1)
    tree.insert(_Key("app"), 2)
    tree.insert(_Key("pine"), 3)
    tree.insert(_Key("pineapple"), 4)
    tree.insert(_Key("orange"), 5)
    tree.insert(_Key("or"), 6)
    tree.insert(_Key("orangejuice"), 8)
    tree.insert(_Key("banana"), 7)
    tree.insert(_Key("ban"), 9)
    tree.insert(_Key("man"), 13)
    tree.insert(_Key("bar"), 10)
    tree.insert(_Key("barn"), 11)
    tree.insert(_Key("baz"), 12)

    // search for longest prefix of a key
    #expect(tree.findPrefix(of: _Key("orange juice")) == _Slice("orange"))
    #expect(tree.findPrefix(of: _Key("orangejuice")) == _Slice("orangejuice"))
    #expect(tree.findPrefix(of: _Key("orangejuic")) == _Slice("orange"))
    #expect(tree.findPrefix(of: _Key("orang")) == _Slice("or"))
    #expect(tree.findPrefix(of: _Key("owl")) == _Slice(""))
    #expect(tree.findPrefix(of: _Key("kiwi")) == _Slice(""))

    // search for keys with prefix
    #expect(tree.search(withPrefix: _Key("ap")) == [_Key("app"), _Key("apple")])
    #expect(tree.search(withPrefix: _Key("app")) == [_Key("app"), _Key("apple")])
    #expect(tree.search(withPrefix: _Key("appl")) == [_Key("apple")])
    #expect(tree.search(withPrefix: _Key("apple")) == [_Key("apple")])
    #expect(tree.search(withPrefix: _Key("apples")) == [])
    #expect(tree.search(withPrefix: _Key("pin")) == [_Key("pine"), _Key("pineapple")])
    #expect(tree.search(withPrefix: _Key("pine")) == [_Key("pine"), _Key("pineapple")])
    #expect(tree.search(withPrefix: _Key("pineapple")) == [_Key("pineapple")])

    #expect(tree.search(withPrefix: _Key("p")) == [_Key("pine"), _Key("pineapple")])
    #expect(
      tree.search(withPrefix: _Key("p"), maxResults: 2) == [
        _Key("pine"), _Key("pineapple"),
      ])
    #expect(tree.search(withPrefix: _Key("p"), maxResults: 1) == [_Key("pine")])
    #expect(tree.search(withPrefix: _Key("p"), maxResults: 0) == [])
  }

  @Test
  static func test_Enumerate() {
    let tree = _TSTree()

    tree.insert(_Key("apple"), 1)
    tree.insert(_Key("app"), 2)
    tree.insert(_Key("pine"), 3)
    tree.insert(_Key("pineapple"), 4)

    var results: [(_Key, Int)] = []
    tree.enumerateKeysAndValues { key, value in
      results.append((key, value))
      return true
    }

    let expected =
      """
      [(["a", "p", "p"], 2), (["a", "p", "p", "l", "e"], 1), (["p", "i", "n", "e"], 3), (["p", "i", "n", "e", "a", "p", "p", "l", "e"], 4)]
      """

    #expect("\(results)" == expected)
  }
}
