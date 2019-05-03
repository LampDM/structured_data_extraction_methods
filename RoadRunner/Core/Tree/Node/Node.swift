//
//  Node.swift
//  RoadRunner
//
//  Created by Toni Kocjan on 03/05/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

struct Tag {
  let name: String
  let attributes: [Attribute]
  let children: [Tag]
  let position: Position
}

extension Tag {
  struct Attribute {
    let name: String
    let value: String
  }
}

enum Tree {
  case root(children: [Tag])
  case tag(Tag)
  case empty
}
