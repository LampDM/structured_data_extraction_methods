//
//  Tree.swift
//  RoadRunner
//
//  Created by Toni Kocjan on 04/05/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

enum Tree {
  case root(tag: Tag, children: [Tree])
  case empty
}

extension Tree {
  func elementById(_ id: String) -> Tree? {
    return element(by: "id", with: id)
  }
  
  func elementByClass(_ classValue: String) -> Tree? {
    return element(by: "class", with: classValue)
  }
  
  func element(by attribute: String, with value: String) -> Tree? {
    return first { $0.attribute(by: attribute, with: value) != nil }
  }
}

extension Tree {
  func first(where condition: @escaping (Tag) -> Bool) -> Tree? {
    switch self {
    case .root(let tag, let children):
      if condition(tag) {
        return self
      }
      for child in children {
        if let tree = child.first(where: condition) {
          return tree
        }
      }
    case .empty:
      break
    }
    return nil
  }
}

extension Tree: CustomStringConvertible {
  var description: String {
    let outputStream = StringOutputStream()
    let dump = DumpTree(tree: self, outputStream: outputStream)
    dump.dump()
    return outputStream.buffer
  }
}
