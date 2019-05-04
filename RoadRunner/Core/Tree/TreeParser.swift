//
//  TreeParser.swift
//  RoadRunner
//
//  Created by Toni Kocjan on 03/05/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

class TreeParser<Lexan: LexicalAnalyzer> {
  let lexan: Lexan
  let logger: LoggerProtocol = LoggerFactory.logger
  private var symbol: Symbol
  
  init(lexan: Lexan) {
    self.lexan = lexan
    symbol = lexan.nextSymbol()
  }
  
  func parseTree() -> Tree {
    if symbol.token == .eof { return .empty }
    return parse()
  }
}

private extension TreeParser {
  func parse() -> Tree {
    let nodes = parseChildren()
    return .root(tag: Tag(name: "", attributes: [], content: nil, position: .zero),
                 children: nodes)
  }
  
  func parseTag() -> Tree {
    guard expecting(.tagIdentifier) else {
      print(symbol.token, symbol.position)
      fatalError("Expecting tag identifier")
    }
    let startPosition = symbol.position
    let tagName = String(symbol.lexeme.dropFirst())
    nextSymbol()
    let attributes = parseAttributes()
    if symbol.token == .selfClosingTag {
      let endPosition = symbol.position
      nextSymbol()
      let tag = Tag(name: tagName,
                    attributes: attributes,
                    content: nil,
                    position: startPosition + endPosition)
      return .root(tag: tag, children: [])
    }
    if symbol.token != .closeTag {
      fatalError("Expecting close tag")
    }
    nextSymbol()
    var text: String?
    if expecting(.identifier) {
      text = symbol.lexeme
      nextSymbol()
    }
    let children = parseChildren()
    if expecting(.identifier) {
      text = (text ?? "") + symbol.lexeme
      nextSymbol()
    }
    if expecting(.eof) {
      let tag = Tag(name: tagName,
                    attributes: attributes,
                    content: text,
                    position: startPosition + symbol.position)
      return .root(tag: tag, children: children)
    }
    guard expecting(.closeTagIdentifier) else {
      fatalError("Expecting close tag identifier")
    }
    let closingIdentifier = symbol.lexeme[symbol.lexeme.index(symbol.lexeme.startIndex, offsetBy: 2)...]
    if closingIdentifier != tagName {
//      if (tagName == "p") {
        lexan.injectSymbol(buffer: ">\(symbol.lexeme)>")
//      } else {
//        fatalError("Expecting close tag identifier for \(tagName), found \(closingIdentifier) instead")
//      }
    }
    nextSymbol()
    let endPosition = symbol.position
    guard expecting(.closeTag) else {
      fatalError("Expecting close tag")
    }
    nextSymbol()
    let tag = Tag(name: tagName,
                  attributes: attributes,
                  content: text,
                  position: startPosition + endPosition)
    return .root(tag: tag, children: children)
  }
  
  func parseAttributes() -> [Tag.Attribute] {
    var attributes = [Tag.Attribute]()
    while symbol.token == .identifier {
      let name = symbol.lexeme
      nextSymbol()
      if !expecting(.assign) {
        attributes.append(.init(name: name, value: ""))
        continue
      }
      nextSymbol()
      guard expecting(.stringLiteral) else {
        fatalError("Expecting string constant")
      }
      let value = symbol.lexeme
      attributes.append(.init(name: name, value: value))
      nextSymbol()
    }
    return attributes
  }
  
  func parseChildren() -> [Tree] {
    var children = [Tree]()
    while !(symbol.token == .closeTagIdentifier || symbol.token == .identifier) {
      let childNode = parseTag()
      children.append(childNode)
      if expecting(.eof) { return children }
    }
    return children
  }
}

private extension TreeParser {
  @discardableResult
  func nextSymbol() -> Symbol {
    symbol = lexan.nextSymbol()
    return symbol
  }
  
  func expecting(_ type: TokenType) -> Bool {
    return symbol.token == type
  }
  
  func expecting(_ lexeme: String) -> Bool {
    return symbol.lexeme == lexeme
  }
}
