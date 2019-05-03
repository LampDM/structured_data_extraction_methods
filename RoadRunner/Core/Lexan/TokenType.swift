//
//  TokenType.swift
//  Atheris
//
//  Created by Toni Kocjan on 21/09/2018.
//

import Foundation

public enum TokenType: String {
  case tagIdentifier // `<head`
  case closeTagIdentifier // `</head`
  case closeTag // `>`
  case selfClosingTag // `/>`
  
  case backslash
  case singleQuote
  case doubleQuote
  case identifier
  case stringLiteral
  case integerLiteral
  case floatingLiteral
  case eof
}
