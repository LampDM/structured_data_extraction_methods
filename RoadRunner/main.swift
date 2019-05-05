//
//  main.swift
//  RoadRunner
//
//  Created by Toni Kocjan on 03/05/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

func printInterface() {
  print("Usage: ./main base_file=path/to/base/file.html reference_file=path/to/reference/file.html [OPTIONS]")
  print("OPTIONS:")
  print("  -tag_id=id  Search for a tag with a given `id`. If not found, calculate wrapper on the whole tree")
  print("  -tree=path/to/file.html  By setting this flag, you don't have to provide `base_file` and `reference_file` arguments. This will inturn dump tree structure of provided file")
}

func logError(_ message: String) {
  print("⚠️  " + message)
}

func parseFile(_ file: String) throws -> Tree {
  let url = URL(string: file)!
  let reader = try FileReader(fileUrl: url)
  let inputStream = FileInputStream(fileReader: reader)
  let atheris = try Atheris(inputStream: inputStream)
  return try atheris.parseTree()
}

let argumentParser = ArgumentParser()
argumentParser.parseArguments(CommandLine.arguments)

print(CommandLine.arguments)
if let dumpTreeFile = argumentParser.string(for: "tree") {
  let tree = try parseFile(dumpTreeFile)
  print(tree)
  exit(0)
}

guard let baseFile = argumentParser.string(for: "base_file") else {
  logError("Missing `base_file` argument!")
  print()
  printInterface()
  exit(100)
}

guard let referenceFile = argumentParser.string(for: "reference_file") else {
  logError("Missing `reference_file` argument!")
  print()
  printInterface()
  exit(101)
}

let targetTag = argumentParser.string(for: "tag_id")

do {
  print("Parsing base file ...")
  let baseTree = try parseFile(baseFile)
  print("Successfuly parsed base file ...")
  
  print("Parsing reference file ...")
  let referenceTree = try parseFile(referenceFile)
  print("Successfuly parsed reference file ...")
  
  var baseSubTree = baseTree
  var referenceSubTree = referenceTree
  if let targetTag = targetTag,
    let fromBase = baseSubTree.elementById(targetTag),
    let fromReference = referenceSubTree.elementById(targetTag) {
    baseSubTree = fromBase
    referenceSubTree = fromReference
  }
  
  print("Initiating road runner ...")
  let algorithm = RoadRunnerLikeAlgorithm(baseTree: baseSubTree,
                                          referenceTree: referenceSubTree)
  let wrapper = algorithm.buildWrapper()
  print("Wrapper:")
  print(wrapper)
} catch {
  logError("Failed with error: " + error.localizedDescription)
}
