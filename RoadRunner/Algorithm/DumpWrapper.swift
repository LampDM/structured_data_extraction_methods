//
//  DumpWrapper.swift
//  RoadRunner
//
//  Created by Toni Kocjan on 04/05/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

class DumpWrapper {
  typealias Tree = RoadRunnerLikeAlgorithm.Wrapper
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

private extension DumpWrapper {
  func dumpTree(_ tree: Tree) {
    switch tree {
    case .node(let compare, let children):
      dumpTag(compare)
      increaseIndent()
      children.forEach(dumpTree)
      decreaseIndent()
    case .empty:
      break
    }
  }
  
  func dumpTag(_ tag: RoadRunnerLikeAlgorithm.CompareResult) {
    switch tag {
    case let .compare(matching, base, reference):
      print(matching.rawValue)
      increaseIndent()
      print("b: " + base.name + ", " + (base.content?.limit(10) ?? ""))
      print("r: " + reference.name + ", " + (reference.content?.limit(10) ?? ""))
      decreaseIndent()
    case let .referenceMissing(base):
      print("Reference missing")
      increaseIndent()
      print("b: " + base.name + ", " + (base.content?.limit(10) ?? ""))
      decreaseIndent()
    case let .baseMissing(reference):
      print("Base missing")
      increaseIndent()
      print("b: " + reference.name + ", " + (reference.content?.limit(10) ?? ""))
      decreaseIndent()
    }
  }
}

private extension DumpWrapper {
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

extension String {
  func limit(_ int: Int) -> String.SubSequence {
    return self[self.startIndex..<self.index(self.startIndex, offsetBy: min(self.count, int))]
  }
}
