//
//  LexAn.swift
//  Atheris
//
//  Created by Toni Kocjan on 21/09/2018.
//

import Foundation

public protocol LexicalAnalyzer: Sequence {
  func nextSymbol() -> Symbol
}
