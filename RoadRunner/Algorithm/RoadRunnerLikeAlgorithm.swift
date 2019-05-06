//
//  RoadRunnerLikeAlgorithm.swift
//  RoadRunner
//
//  Created by Toni Kocjan on 04/05/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

public class RoadRunnerLikeAlgorithm: Algorithm {
  let baseTree: Tree
  let referenceTree: Tree
  
  init(baseTree: Tree, referenceTree: Tree) {
    self.baseTree = baseTree
    self.referenceTree = referenceTree
  }
}

public extension RoadRunnerLikeAlgorithm {
  func buildWrapper() -> Wrapper {
    return buildWrapper(baseTree, referenceTree)
  }
}

private extension RoadRunnerLikeAlgorithm {
  func buildWrapper(_ first: Tree, _ second: Tree) -> Wrapper {
    switch (first, second) {
    case let (.node(firstTag, firstChildren), .node(secondTag, secondChildren)):
      let match = compareTags(firstTag, second: secondTag)
      let subtreesMatch = compareChildren(firstChildren, secondChildren)
      return .node(match: .compare(matching: match, base: firstTag, reference: secondTag),
                                   children: subtreesMatch)
    case let (.node(tag, children), .empty):
      return .node(match: .referenceMissing(base: tag), children: compareChildren(children, []))
    case let (.empty, .node(tag, children)):
      return .node(match: .baseMissing(reference: tag), children: compareChildren(children, []))
    default:
      return .empty
    }
  }
  
  func compareChildren(_ firstChildren: [Tree], _ secondChildren: [Tree]) -> [Wrapper] {
    let match = zip(firstChildren, secondChildren).map(buildWrapper)
    return match
  }
  
  func compareTags(_ first: Tag, second: Tag) -> CompareResult.Compare {
    guard first.name == second.name else { return .mismatch }
    switch (first.content, second.content) {
    case let (.some(firstContent), .some(secondContent)) where firstContent == secondContent:
      return .matches
    case (.none, .none):
      return .matches
    default:
      return .nameMatches
    }
  }
}

public extension RoadRunnerLikeAlgorithm {
  enum CompareResult {
    public enum Compare: String {
      case matches
      case nameMatches
      case mismatch
    }
    case compare(matching: Compare, base: Tag, reference: Tag)
    case baseMissing(reference: Tag)
    case referenceMissing(base: Tag)
  }
  
  enum Wrapper {
    case node(match: CompareResult, children: [Wrapper])
    case empty
  }
}

extension RoadRunnerLikeAlgorithm.Wrapper: CustomStringConvertible {
  public var description: String {
    let outputStream = StringOutputStream()
    let dump = DumpWrapper(tree: self, outputStream: outputStream)
    dump.dump()
    return outputStream.buffer
  }
}