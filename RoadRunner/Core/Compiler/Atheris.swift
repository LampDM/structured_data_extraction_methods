//
//  Atheris.swift
//  Atheris
//
//  Created by Toni Kocjan on 25/09/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class Atheris {
  public var logger: LoggerProtocol = LoggerFactory.logger
  private let inputStream: InputStream
  
  public init(inputStream: InputStream) throws {
    self.inputStream = inputStream
  }
  
  public func parseTree() throws {
    do {
      logger.log(message: "RoadRunner [0.0.1 (pre-alpha)]:")
      
      let lexan = LexAn(inputStream: inputStream)
//      for symbol in lexan {
//        print(symbol.description)
//      }
      
      // Parse syntax
      let parser = TreeParser(lexan: lexan)
      let tree = parser.parseTree()
      let dumpTree = DumpTree(tree: tree, outputStream: StandardOutputStream())
      dumpTree.dump()
      
      // Dump ast
//      try dumpAst(ast)
      
    } catch {
      throw error
    }
  }
  
  private func dumpAst(outputFile: String = "ast") throws {
    let outputStream = FileOutputStream(fileWriter: try FileWriter(fileUrl: URL(string: outputFile)!))
//    let dumpVisitor = DumpVisitor(outputStream: outputStream,
//                                  symbolDescription: symbolDescription)
//    try dumpVisitor.visit(node: ast)
  }
}

public extension Atheris {
  enum Error: Swift.Error {
    case invalidPath(String)
    case fileNotFound(URL)
    case invalidArguments(errorMessage: String)
    
    var localizedDescription: String {
      switch self {
      case .invalidArguments(let errMessage):
        return errMessage
      case .invalidPath(let url):
        return "\(url) is not a valid URL!"
      case .fileNotFound:
        return "File not found or cannot be opened!"
      }
    }
  }
}
