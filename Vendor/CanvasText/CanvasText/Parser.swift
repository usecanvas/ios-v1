//
//  Parser.swift
//  CanvasText
//
//  Created by Sam Soffes on 1/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct Parser {

	// MARK: - Properties

	public let string: String

	private let blockLevelParseOrder: [BlockNode.Type] = [
		Blockquote.self,
		Checklist.self,
		CodeBlock.self,
		Title.self,
		Heading.self,
		Image.self,
		OrderedList.self,
		UnorderedList.self,
		Paragraph.self
	]


	// MARK: - Initializers

	public init(string: String) {
		self.string = string
	}


	// MARK: - Parsing

	public func parse() -> (nodes: [BlockNode], shadows: [Shadow]) {
		var shadows = [Shadow]()
		var nodes = [BlockNode]()

		// Enumerate the string blocks of the `backingText`.
		let text = string as NSString
		text.enumerateSubstringsInRange(NSRange(location: 0, length: text.length), options: [.ByLines]) { substring, substringRange, _, _ in
			// Ensure we have a substring to work with
			guard let substring = substring else { return }

			for type in self.blockLevelParseOrder {
				guard var node = type.init(string: substring, enclosingRange: substringRange) else { continue }

				if let delimitable = node as? NativeDelimitable, prefixable = node as? Prefixable {
					shadows.append(Shadow(backingRange: delimitable.delimiterRange.union(prefixable.prefixRange)))
				} else {
					if let delimitable = node as? NativeDelimitable {
						shadows.append(Shadow(backingRange: delimitable.delimiterRange))
					}

					if let prefixable = node as? Prefixable {
						shadows.append(Shadow(backingRange: prefixable.prefixRange))
					}
				}

				if let container = node as? ContainerNode {
					node = self.parseInline(container) as! BlockNode
				}

				nodes.append(node)
				return
			}

			// Unsupported range
			var range = substringRange

			// Account for new line
			if range.max + 1 < text.length {
				range.length += 1
			}

			shadows.append(Shadow(backingRange: range))
		}

		return (nodes, shadows)
	}


	// MARK: - Private

	/// Returns a new version of container node with the subnodes array filed out
	private func parseInline(node: ContainerNode) -> ContainerNode {

		// TODO: Implement
		return node
	}
}
