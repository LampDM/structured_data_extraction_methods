//
//  main.swift
//  RoadRunner
//
//  Created by Toni Kocjan on 03/05/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

let argumentParser = ArgumentParser()
argumentParser.parseArguments(CommandLine.arguments)

guard let inputFile = argumentParser.string(for: "source_file") else {
  LoggerFactory.logger.error(message: "Missing `source_file` argument!")
  exit(100)
}

do {
  let url = URL(string: inputFile)!
  let reader = try FileReader(fileUrl: url)
  let inputStream = FileInputStream(fileReader: reader)
  let atheris = try Atheris(inputStream: inputStream)
  try atheris.parseTree()
} catch {
  LoggerFactory.logger.error(message: "Failed with error: " + error.localizedDescription)
}
