//
//  LexAn.swift
//  RoadRunner
//
//  Created by Toni Kocjan on 03/05/2019.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class LexAn: LexicalAnalyzer {
  public let inputStream: InputStream
  
  private var currentLocation = Location(row: 1, column: 1)
  private var bufferCharacter: Character?
  private var streamBuffer: String?
  private var parsingTagContent = false
  private var potentiallyParsingTagContent = false
  
  public init(inputStream: InputStream) {
    self.inputStream = inputStream
  }
  
  public func nextSymbol() -> Symbol {
    guard let symbol = parseSymbol() else {
      let symbol = Symbol(token: .eof, lexeme: "$", position: Position(startLocation: currentLocation,
                                                                           endLocation: Location(row: currentLocation.row,
                                                                                                 column: currentLocation.column + 1)))
      return symbol
    }
    return symbol
  }
  
  public func injectSymbol(buffer: String) {
    bufferCharacter = nil
    if streamBuffer == nil {
      streamBuffer = buffer
    } else {
      streamBuffer! += buffer
    }
  }
}

extension LexAn {
  public struct Iterator: IteratorProtocol {
    public let lexan: LexAn
    private var didEnd = false
    
    public init(lexan: LexAn) {
      self.lexan = lexan
    }
    
    public mutating func next() -> Symbol? {
      guard !didEnd else { return nil }
      let symbol = lexan.nextSymbol()
      didEnd = symbol.token == .eof
      return symbol
    }
  }
  
  public func parseSymbol() -> Symbol? {
    while let character = nextCharacter() {
      if character == " " { continue }
      if character == "\n" {
        currentLocation = Location(row: currentLocation.row + 1, column: 1)
        continue
      }
      if character == "\t" {
        currentLocation = Location(row: currentLocation.row, column: currentLocation.column + 4)
        continue
      }
      
      //////////////////////////////
      
      if potentiallyParsingTagContent {
        parsingTagContent = !isLowerThanSymbol(character)
        potentiallyParsingTagContent = false
      }
      if parsingTagContent {
        bufferCharacter = character
        return parseTagContent()
      }
      
      if isLowerThanSymbol(character) {
        return parseTagOrComment(character)
      }
      
      if isGreaterThanSymbol(character) {
        potentiallyParsingTagContent = true
        parsingTagContent = false
        return Symbol(token: .closeTag, lexeme: ">", position: position(count: 1))
      }
      
      if isSlash(character), let next = nextCharacter() {
        if isGreaterThanSymbol(next) {
          return Symbol(token: .selfClosingTag, lexeme: "/>", position: position(count: 2))
        }
        bufferCharacter = next
        continue
      }
      
      if isAlphabet(character) {
        return parseIdentifier(character)
      }
      
      if isAssign(character) {
        return Symbol(token: .assign, lexeme: "=", position: position(count: 1))
      }
      
      if isDoubleQuote(character) {
        return parseStringConstant()
      }
      
      bufferCharacter = character
      
      if isNumeric(character) {
        return parseNumericConstant()
      }
    }
    return nil
  }
  
  public func makeIterator() -> LexAn.Iterator {
    return Iterator(lexan: self)
  }
}

private extension LexAn {
  func parseTagContent() -> Symbol {
    func didCloseTag(lexeme: String) -> String.Index? {
      guard let index = lexeme.lastIndex(of: "<") else { return nil }
      let nextIndex = lexeme.index(after: index)
      if isSlash(lexeme[nextIndex]) {
        return lexeme.index(before: index)
      }
      return nil
    }
    
    var lexeme = ""
    while let char = nextCharacter() {
      lexeme += "\(char)"
      if char == " " { continue }
      if char == "\n" {
        currentLocation = Location(row: currentLocation.row + 1, column: 1)
        continue
      }
      if char == "\t" {
        currentLocation = Location(row: currentLocation.row, column: currentLocation.column + 4)
        continue
      }
      
      if isGreaterThanSymbol(char), let tagStartIndex = didCloseTag(lexeme: lexeme) {
        streamBuffer = String(lexeme[lexeme.index(after: tagStartIndex)...])
        lexeme = String(lexeme[...tagStartIndex])
        break
      }
    }
    parsingTagContent = false
    return Symbol(token: .identifier,
                  lexeme: lexeme,
                  position: position(count: lexeme.count))
  }
  
  func parseTagOrComment(_ character: Character) -> Symbol? {
    func parseComment() -> Symbol? {
      var buffer = ""
      while let char = nextCharacter() {
        buffer += "\(char)"
        if buffer.count >= 3 && buffer[buffer.index(buffer.endIndex, offsetBy: -3)...] == "-->" {
          return parseSymbol()
        }
      }
      return nil
    }
    
    var lexeme = "\(character)"
    var tokenType = Token.tagIdentifier
    
    while let char = nextCharacter() {
      if isWhitespace(char) || isGreaterThanSymbol(char) {
        bufferCharacter = char
        break
      }
      if isSlash(char) {
        if lexeme.count > 1 {
          bufferCharacter = char
          break
        }
        tokenType = .closeTagIdentifier
      }
      
      lexeme += "\(char)"
      
      if lexeme.count == 4 && lexeme == "<!--" {
        return parseComment()
      }
    }
    
    return Symbol(token: tokenType,
                  lexeme: lexeme,
                  position: position(count: lexeme.count))
  }
  
  func parseIdentifier(_ character: Character) -> Symbol {
    var lexeme = "\(character)"
    while let char = nextCharacter() {
      if isAlphabet(char) || isMinus(char) {
        lexeme += "\(char)"
        continue
      }
      bufferCharacter = char
      break
    }
    return Symbol(token: .identifier, lexeme: lexeme, position: position(count: lexeme.count))
  }
  
  func parseStringConstant() -> Symbol? {
    var lexeme = ""
    while let character = nextCharacter() {
      if character == "\"" {
        let newPosition = position(count: lexeme.count + 2)
        return Symbol(token: .stringLiteral, lexeme: lexeme, position: newPosition)
      } else {
        lexeme.append(character)
      }
    }
    return nil
  }
  
  func parseNumericConstant() -> Symbol {
    var lexeme = ""
    var tokenType = Token.integerLiteral
    while let character = nextCharacter() {
      if isNumeric(character) {
        lexeme.append(character)
        continue
      }
      if character == "." && tokenType == .integerLiteral {
        lexeme.append(character)
        tokenType = .floatingLiteral
        continue
      }
      
      bufferCharacter = character
      break
    }
    
    let newPosition = position(count: lexeme.count)
    return Symbol(token: tokenType, lexeme: lexeme, position: newPosition)
  }
}

private extension LexAn {
  func isLowerThanSymbol(_ char: Character) -> Bool {
    return char == "<"
  }
  
  func isGreaterThanSymbol(_ char: Character) -> Bool {
    return char == ">"
  }
  
  func isDoubleQuote(_ char: Character) -> Bool {
    return char == "\""
  }
  
  func isNumeric(_ char: Character) -> Bool {
    return char >= "0" && char <= "9"
  }
  
  func isAlphabet(_ char: Character) -> Bool {
    return char >= "a" && char <= "z" || char >= "A" && char <= "Z"
  }
  
  func isMinus(_ char: Character) -> Bool {
    return char == "-"
  }
  
  func isSlash(_ char: Character) -> Bool {
    return char == "/"
  }
  
  func isAssign(_ char: Character) -> Bool {
    return char == "="
  }
  
  func isWhitespace(_ char: Character) -> Bool {
    return char == " " || char == "\n" || char == "\t"
  }
}

private extension LexAn {
  func nextCharacter() -> Character? {
    if let char = bufferCharacter {
      self.bufferCharacter = nil
      return char
    }
    
    if let buffer = streamBuffer, let nextChar = buffer.first {
      if buffer.count == 1 {
        streamBuffer = nil
      } else {
        streamBuffer = String(streamBuffer![buffer.index(after: buffer.startIndex)...])
      }
      return nextChar
    }
    
    do {
      let next = try inputStream.next()
      currentLocation = Location(row: currentLocation.row, column: currentLocation.column + 1)
      return next
    } catch {
      return nil
    }
  }
  
  func position(count: Int) -> Position {
    let buffer = bufferCharacter == nil ? 0 : 1
    return Position(startLocation: Location(row: currentLocation.row,
                                            column: currentLocation.column - count - buffer),
                    endLocation: Location(row: currentLocation.row,
                                          column: currentLocation.column - buffer))
  }
}