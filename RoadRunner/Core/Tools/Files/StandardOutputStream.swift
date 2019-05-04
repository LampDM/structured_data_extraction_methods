//
//  StandardOutputStream.swift
//  RoadRunner
//
//  Created by Toni Kocjan on 03/05/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

class StandardOutputStream: OutputStream {
  func print(_ string: String) {
    Swift.print(string)
  }
  
  func printLine(_ string: String) {
    Swift.print(string)
  }
}
