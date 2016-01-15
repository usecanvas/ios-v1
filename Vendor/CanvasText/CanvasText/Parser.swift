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

	private let blockParseOrder: [BlockNode.Type] = [
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

	private let spanParseOrder: [SpanNode.Type] = [
		CodeSpan.self,
		Link.self,
//		ReferenceLink.self,
		DoubleEmphasis.self,
		Emphasis.self
	]

	private let spanRegularExpressions: [String: NSRegularExpression] = [
		String(CodeSpan.self): try! NSRegularExpression(pattern: "(`+)(.+?)(?<!`)(\\1)(?!`)", options: []),
		String(Link.self): try! NSRegularExpression(pattern: "(\\[)((?:(?:\\\\.)|[^\\[\\]])+)(\\])(\\()([^\\(\\)\\s]+(?:\\(\\S*?\\))??[^\\(\\)\\s]*?)(?:\\s(['‘][^'’]*['’]|[\"“][^\"”]*[\"”]))?(\\))", options: []),
		String(Emphasis.self): try! NSRegularExpression(pattern: "(?:\\s|^)(\\*|_)(?=\\S)(.+?)(?<=\\S)(\\1)", options: []),
		String(DoubleEmphasis.self): try! NSRegularExpression(pattern: "(?:\\s|^)(\\*\\*|__)(?=\\S)(.+?[*_]*)(?<=\\S)(\\1)", options: [])
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

			for type in self.blockParseOrder {
				guard var node = type.init(string: substring, enclosingRange: substringRange) else { continue }

				if let prefixable = node as? NativePrefixable {
					shadows.append(Shadow(backingRange: prefixable.nativePrefixRange))
				}

				if var container = node as? ContainerNode {
					container.subnodes = self.parseInline(container)
					node = container as! BlockNode
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

	private func parseInline(container: ContainerNode) -> [Node] {
		var subnodes = [Node]()

		for type in spanParseOrder {
			guard let regularExpression = spanRegularExpressions[String(type)] else { continue }

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
