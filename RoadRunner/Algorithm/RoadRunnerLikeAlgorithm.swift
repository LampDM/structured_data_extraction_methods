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
    guard firstChildren.count == secondChildren.count else { return fallbackCompare(firstChildren, secondChildren) }
    let match = zip(firstChildren, secondChildren).map(buildWrapper)
    return match
  }
  
  private func fallbackCompare(_ firstChildren: [Tree], _ secondChildren: [Tree]) -> [Wrapper] {
    func mismatches(_ wrappers: [Wrapper]) -> Int {
      return wrappers.reduce(0) { acc, next in acc + next.mismatchCount }
    }
    
    if firstChildren.isEmpty, let referenceTag = secondChildren.first?.tag {
      return [.node(match: .baseMissing(reference: referenceTag),
                    children: compareChildren([], secondChildren.first!.children))]
    }
    
    if secondChildren.isEmpty, let baseTag = firstChildren.first?.tag {
      return [.node(match: .referenceMissing(base: baseTag),
                    children: compareChildren([], firstChildren.first!.children))]
    }
    
    let minList: [Tree]
    let maxList: [Tree]
    if firstChildren.count < secondChildren.count {
      minList = firstChildren
      maxList = secondChildren
    } else {
      minList = secondChildren
      maxList = firstChildren
    }
    
    let wrappers = (0..<(maxList.count - minList.count + 1))
      .map { zip(minList, maxList[$0...]).map(buildWrapper)
    }
    let heights = wrappers
      .map { ($0, $0.map { $0.height }.max()!) }
      .max { $0.1 > $1.1 }
    return heights!.0
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
    // NOTE: - not used atm
    case baseMissing(reference: Tag)
    case referenceMissing(base: Tag)
  }
  
  enum Wrapper {
    case node(match: CompareResult, children: [Wrapper])
    case empty
  }
}

extension RoadRunnerLikeAlgorithm.Wrapper {
  var mismatchCount: Int {
    return countMismatches(in: self)
  }
  
  private func countMismatches(in wrapper: RoadRunnerLikeAlgorithm.Wrapper) -> Int {
    switch wrapper {
    case .node(let match, let children):
      var count = 0
      switch match {
      case .compare(let matching, _, _):
        switch matching {
        case .mismatch:
          count += 1
        default:
          break
        }
      default:
        break
      }
      for child in children {
        count += countMismatches(in: child)
      }
      return count
    case .empty:
      return 0
    }
  }
  
  var height: Int {
    return calculateHeight(in: self)
  }
  
  private func calculateHeight(in wrapper: RoadRunnerLikeAlgorithm.Wrapper) -> Int {
    switch wrapper {
    case .node(_, let children):
      let maxHeightChild = children.map { $0.height }.max() ?? 0
      return maxHeightChild + 1
    case .empty:
      return 0
    }
  }
  
  var count: Int {
    return countNodes(in: self)
  }
  
  func countNodes(in: RoadRunnerLikeAlgorithm.Wrapper) -> Int {
    switch self {
    case .node(_, let children):
      let sum = children.reduce(0) { $0 + $1.count }
      return sum + 1
    case .empty:
      return 0
    }
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
