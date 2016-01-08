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
//		CodeSpan.self,
//		Link.self,
//		ReferenceLink.self,
		DoubleEmphasis.self,
//		Emphasis.self
	]

	private let spanRegularExpressions: [String: NSRegularExpression] = [
//		String(Emphasis.self): try! NSRegularExpression(pattern: "(?:\\s|^A)(\\*|_)(?=\\S)(.+?)(?<=\\S)(\\1)", options: []),
		String(DoubleEmphasis.self): try! NSRegularExpression(pattern: "(?:\\s|^A)(\\*\\*|__)(?=\\S)(.+?[*_]*)(?<=\\S)(\\1)", options: [])
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

	/// Returns a new version of container node with the subnodes array filed out
	private func parseInline(container: ContainerNode) -> [Node] {
		var subnodes = [Node]()

		func fillTo(location: Int) {
			let lastLocation = subnodes.last?.range.max ?? container.textRange.location
			if lastLocation < location {
				subnodes.append(Text(range: NSRange(location: lastLocation, length: location - lastLocation)))
			}
		}

		for type in spanParseOrder {
			guard let regularExpression = spanRegularExpressions[String(type)] else { continue }

			let matches = regularExpression.matchesInString(string, options: [], range: container.textRange)
			if matches.count == 0 {
				continue
			}

			for match in matches {
				if var node = type.init(match: match) {
					// Create a text node before if neccessary
					fillTo(node.range.location)

					// Recurse
					node.subnodes = parseInline(node)
					subnodes.append(node)
				}
			}
		}

		// Create a text node to the end if neccessary
		fillTo(container.textRange.max)

		return subnodes
	}
}
