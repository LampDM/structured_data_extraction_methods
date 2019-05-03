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
  let content: Content
  let position: Position
}

extension Tag {
  struct Attribute {
    let name: String
    let value: String
  }
  
  enum Content {
    case container(text: String?, children: [Tag])
    case empty
  }
}

enum Tree {
  case root(children: [Tag])
  case empty
}
