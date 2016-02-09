//
//  Parser.swift
//  CanvasNative
//
//  Created by Sam Soffes on 1/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

/// Given a string, parse into BlockNodes.
public struct Parser {

	// MARK: - Properties

	public let string: String

	private let blockParseOrder: [BlockNode.Type] = [
		Blockquote.self,
		ChecklistItem.self,
		CodeBlock.self,
		Title.self,
		Heading.self,
//		HorizontalRule.self,
		Image.self,
		OrderedListItem.self,
		UnorderedListItem.self,
		Paragraph.self
	]

	private let spanParseOrder: [SpanNodeParseable.Type] = [
		CodeSpan.self,
		Link.self,
//		ReferenceLink.self,
		DoubleEmphasis.self,
		Emphasis.self
	]


	// MARK: - Initializers

	public init(string: String) {
		self.string = string
	}


	// MARK: - Parsing

	public func parse() -> [BlockNode] {
		var nodes = [BlockNode]()

		// Enumerate the string blocks of the `backingText`.
		let text = string as NSString
		text.enumerateSubstringsInRange(NSRange(location: 0, length: text.length), options: [.ByLines]) { substring, substringRange, _, _ in
			// Ensure we have a substring to work with
			guard let substring = substring else { return }

			for type in self.blockParseOrder {
				guard var node = type.init(string: substring, enclosingRange: substringRange) else { continue }

				if var container = node as? NodeContainer {
					container.subnodes = self.parseInline(container)

					// TODO: There has to be a better way to do this
					if let container = container as? BlockNode {
						node = container
					}
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
		}

		// Add position information
		var positionableType: Positionable.Type?
		var	positionables = [Positionable]()

		func applyPositions(index: Int) {
			let count = positionables.count
			for (i, p) in positionables.enumerate() {
				var positionable = p

				if count == 1 {
					positionable.position = .Single
				} else if i == 0 {
					positionable.position = .Top
				} else if i == count - 1 {
					positionable.position = .Bottom
				} else {
					positionable.position = .Middle
				}

				guard let node = positionable as? BlockNode else { continue }
				nodes[index - count + i] = node
			}

			positionableType = nil
			positionables.removeAll()
		}

		for (i, node) in nodes.enumerate() {
			guard let positionable = node as? Positionable else {
				applyPositions(i)
				continue
			}

			if positionableType != positionable.dynamicType {
				applyPositions(i)
				positionableType = positionable.dynamicType
			}

			positionables.append(positionable)
		}

		applyPositions(nodes.count)

		return nodes
	}


	// MARK: - Private

	private func parseInline(container: NodeContainer) -> [Node] {
		var subnodes = [Node]()

		for type in spanParseOrder {
			let regularExpression = type.regularExpression
			let matches = regularExpression.matchesInString(string, options: [], range: container.textRange)
			if matches.count == 0 {
				continue
			}

			for match in matches {
				// Skip if there is already a sibling for this range
				var skip = false
				for sibling in subnodes {
					if sibling.range.intersection(match.rangeAtIndex(0)) != nil {
						skip = true
						break
					}
				}

				if skip {
					continue
				}

				if var node = type.init(match: match) {
					// Recurse
					node.subnodes = parseInline(node)
					subnodes.append(node)
				}
			}
		}

		// Add text nodes
		var output = [Node]()

		var last = container.textRange.location

		for node in subnodes.sort({ $0.range.location < $1.range.location }) {
			if node.range.location != last {
				output.append(Text(range: NSRange(location: last, length: node.range.location - last)))
			}
			output.append(node)
			last = node.range.max
		}

		if last < container.textRange.max {
			output.append(Text(range: NSRange(location: last, length: container.textRange.max - last)))
		}

		return output
	}
}
