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
  func element(by id: String) -> Tree? {
    switch self {
    case .root(let tag, let children):
      if let _ = tag.attribute(by: "id", with: id) {
        return self
      }
      for child in children {
        if let subtree = child.element(by: id) {
          return subtree
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
