//
//  DumpTree.swift
//  RoadRunner
//
//  Created by Toni Kocjan on 03/05/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

class DumpTree {
  let tree: Tree
  let indentation: Int
  let outputStream: OutputStream
  private var indent = 0
  
  init(tree: Tree, indentation: Int = 2, outputStream: OutputStream) {
    self.tree = tree
    self.indentation = indentation
    self.outputStream = outputStream
  }
  
  func dump() {
    dumpTree(tree)
  }
}

private extension DumpTree {
  func dumpTree(_ tree: Tree) {
    switch tree {
    case .node(let tag, let children):
      dumpTag(tag)
      increaseIndent()
      children.forEach(dumpTree)
      decreaseIndent()
    case .empty:
      break
    }
  }
  
  func dumpTag(_ tag: Tag) {
    print(tag.name, tag.position)
    for attribute in tag.attributes {
      print("- a: " + attribute.name + ": " + attribute.value)
    }
    if let text = tag.content {
      print("- v: " + text)
    }
  }
}

private extension DumpTree {
  func print(_ string: String, _ position: Position) {
    outputStream.printLine("\(withIndent(string)) \(position.description):")
  }
  
  func print(_ string: String) {
    outputStream.printLine(withIndent(string))
  }
  
  func withIndent(_ string: String) -> String {
    return (0..<indent).reduce("", { acc, _ in acc + " " }) + string
  }
  
  func increaseIndent() {
    indent += indentation
  }
  
  func decreaseIndent() {
    indent -= indentation
  }
}
