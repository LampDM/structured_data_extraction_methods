//
//  main.swift
//  RoadRunner
//
//  Created by Toni Kocjan on 03/05/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

func logError(_ message: String) {
  print("⚠️ " + message)
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

guard let baseFile = argumentParser.string(for: "base_file") else {
  logError("Missing `base_file` argument!")
  exit(100)
}

guard let referenceFile = argumentParser.string(for: "reference_file") else {
  logError("Missing `reference_file` argument!")
  exit(101)
}

do {
  let baseTree = try parseFile(baseFile)
  let referenceTree = try parseFile(referenceFile)
  
  let algorithm = RoadRunnerLikeAlgorithm(baseTree: baseTree.elementById("neki")!,
                                          referenceTree: referenceTree.elementById("neki")!)
  let wrapper = algorithm.buildWrapper()
  print(wrapper)
} catch {
  logError("Failed with error: " + error.localizedDescription)
}
