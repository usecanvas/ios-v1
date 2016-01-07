//
//  ContainerNode.swift
//  CanvasText
//
//  Created by Sam Soffes on 1/6/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

protocol ContainerNode: Node {
	var subnodes: [Node] { get set }
}


func parseSpanLevelNodes(string string: String, enclosingRange: NSRange) -> [Node] {
	return []
}
