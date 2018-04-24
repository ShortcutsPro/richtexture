//
//  Document.swift
//  Textor
//
//  Created by Louis D'hauwe on 31/12/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import UIKit
import Foundation
import MobileCoreServices

enum DocumentError: Error {
	case saveError
	case loadError
}

class Document: UIDocument {

	var text: NSAttributedString?

	var encodingUsed: String.Encoding?

	override func contents(forType typeName: String) throws -> Any {
		
		var documentType = NSAttributedString.DocumentType.rtf
		if UTTypeConformsTo(typeName as CFString, kUTTypeRTFD) {
			documentType = NSAttributedString.DocumentType.rtfd
		} else if UTTypeConformsTo(typeName as CFString, kUTTypeRTF) {
			documentType = NSAttributedString.DocumentType.rtf
		} else if UTTypeConformsTo(typeName as CFString, kUTTypePlainText) {
			documentType = NSAttributedString.DocumentType.plain
		} else {
			print("Unknown type name \(typeName)")
		}
		
		guard let data = try text?.fileWrapper(from: NSRange(location: 0, length: text!.length), documentAttributes: [.documentType: documentType]) else {
			throw DocumentError.saveError
		}

		return data
	}
	
	
	
	
	func readFromURL(_ url: URL, ofType typeName: String, encoding desiredEncoding: String.Encoding, ignoreRTF: Bool, ignoreHTML: Bool) throws {
		var docAttrs: NSDictionary? = nil
		let options: [NSAttributedString.DocumentReadingOptionKey : AnyObject] = [:]
		let attributedString = try NSAttributedString.init(url: url, options: options, documentAttributes: &docAttrs)
		self.text = attributedString.copy() as? NSAttributedString
	}

	override func load(fromContents contents: Any, ofType typeName: String?) throws {

		guard let typeName = typeName else { throw DocumentError.loadError }
		var options: [NSAttributedString.DocumentReadingOptionKey : NSAttributedString.DocumentType] = [:]
		var docAttrs: NSDictionary? = nil

		if UTTypeConformsTo(typeName as CFString, kUTTypeRTFD) {
			options = [.documentType : NSAttributedString.DocumentType.rtfd]
		
			guard let _ = contents as? FileWrapper else {
				throw DocumentError.loadError
			}
			
			//TODO This doesn't seem right, seems like I should be using readFromURL
			let attributedString = try NSAttributedString.init(url: self.fileURL, options: options, documentAttributes: &docAttrs)
			self.text = attributedString.copy() as? NSAttributedString
			
		} else if UTTypeConformsTo(typeName as CFString, kUTTypeRTF) {
			options = [.documentType : NSAttributedString.DocumentType.rtf]
			
			guard let data = contents as? Data else {
				throw DocumentError.loadError
			}
			
			let attributedString = try NSAttributedString(data: data, options: options, documentAttributes: &docAttrs)
			self.text = attributedString.copy() as? NSAttributedString
		} else if UTTypeConformsTo(typeName as CFString, kUTTypePlainText) {
			options = [.documentType : NSAttributedString.DocumentType.plain]
		} else {
			print("Unknown type name \(typeName)")
		}
    }
}
