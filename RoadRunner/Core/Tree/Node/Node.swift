//
//  Node.swift
//  RoadRunner
//
//  Created by Toni Kocjan on 03/05/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

public struct Tag {
  let name: String
  let attributes: [Attribute]
  let content: String?
  let position: Position
}

public extension Tag {
  struct Attribute {
    let name: String
    let value: String
  }
}

public extension Tag {
  func attribute(by name: String, with value: String) -> String? {
    return attributes.last { $0.name == name && $0.value == value }?.value
  }
}
