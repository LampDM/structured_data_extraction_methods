//
//  StringOutputStream.swift
//  RoadRunner
//
//  Created by Toni Kocjan on 04/05/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

class StringOutputStream: OutputStream {
  private(set) var buffer = ""
  
  func print(_ string: String) {
    buffer += string
  }
  
  func printLine(_ string: String) {
    buffer += string + "\n"
  }
}
