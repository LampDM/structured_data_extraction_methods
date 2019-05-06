//
//  DumpWrapper.swift
//  RoadRunner
//
//  Created by Toni Kocjan on 04/05/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

private let limit = 100

private extension Optional where Wrapped == String {
  var isNilOrEmpty: Bool {
    switch self {
    case .some(let string):
      return string.isEmpty
    case .none:
      return true
    }
  }
}

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
      print("b \(base.position): " + base.name + (base.content.isNilOrEmpty ? "" : ", content: " + (base.content?.limit(limit) ?? "")))
      print("r \(reference.position): " + reference.name + (reference.content.isNilOrEmpty ? "" : ", content: " + (reference.content?.limit(limit) ?? "")))
      decreaseIndent()
    case let .referenceMissing(base):
      print("Reference missing")
      increaseIndent()
      print("b \(base.position): " + base.name + ", content: " + (base.content?.limit(limit) ?? ""))
      decreaseIndent()
    case let .baseMissing(reference):
      print("Base missing")
      increaseIndent()
      print("r [\(reference.position): " + reference.name + ", content: " + (reference.content?.limit(limit) ?? ""))
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
  func limit(_ int: Int) -> String {
    if int == 0 { return self }
    return String(self[self.startIndex..<self.index(self.startIndex, offsetBy: min(self.count, int))])
  }
}
