//
//  Atheris.swift
//  Atheris
//
//  Created by Toni Kocjan on 25/09/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class Atheris {
  private let inputStream: InputStream
  
  public init(inputStream: InputStream) throws {
    self.inputStream = inputStream
  }
  
  public func parseTree() throws -> Tree {
    let lexan = LexAn(inputStream: inputStream)
    let parser = TreeParser(lexan: lexan)
    let tree = parser.parseTree()
    return tree
  }
}
