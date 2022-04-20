//
//  Kitchen.swift
//  Cabbage
//
//  Created by Lesterrry on 19.04.2022.
//

import Foundation

struct Kitchen {
	
	private enum Operation {
		case cook
		case uncook
		case `return`
	}
	
	// Your key here. No restrictions;
	// the longer the key, the more bytes will be chopped
	static let СЕКРЕТНЫЙ_ИНГРИДИЕНТ = String(1923457204628414, radix: 2)
	
	static func workCulinaryMiracle(with file: URL, using fileManager: FileManager) throws -> URL {
		if file.pathExtension == Strings.DEEPFRIED_FILE_EXTENSION {
			return try uncook(file, using: fileManager)
		} else {
			return try cook(file, using: fileManager)
		}
	}
	
	static func cook(_ file: URL, using fileManager: FileManager) throws -> URL {
		guard file.pathExtension != Strings.DEEPFRIED_FILE_EXTENSION else {
			throw NSError()
		}
		return try perform(.cook, file: file, using: fileManager).1!
	}
	
	static func uncook(_ file: URL, using fileManager: FileManager) throws -> URL {
		guard file.pathExtension == Strings.DEEPFRIED_FILE_EXTENSION else {
			throw NSError()
		}
		return try perform(.uncook, file: file, using: fileManager).1!
	}
	
	static func cookedData(from file: URL, with fileManager: FileManager) throws -> Data {
		return try perform(.return, file: file, using: fileManager).0!
	}
	
	@discardableResult
	private static func perform(_ operation: Operation, file: URL, using fileManager: FileManager) throws -> (Data?, URL?) {
		guard var data = fileManager.contents(atPath: file.path) else {
			throw NSError()
		}
		let len = (СЕКРЕТНЫЙ_ИНГРИДИЕНТ.count * 2) - 1
		if data.count > len {
			var idata = data[0 ..< len]
			if operation == .cook {
				#if DEBUG
				let bdata = idata
				chopBytes(&idata)
				restoreBytes(&idata)
				assert(idata == bdata)
				#endif
				chopBytes(&idata)
			} else {
				restoreBytes(&idata)
			}
			data = idata + data.advanced(by: len)
		} else {
			if operation == .cook {
				chopBytes(&data)
			} else {
				restoreBytes(&data)
			}
		}
		if operation == .return {
			return (data, nil)
		}
		let newFile = operation == .cook ? file.appendingPathExtension(Strings.DEEPFRIED_FILE_EXTENSION) : file.deletingPathExtension()
		try data.write(to: file)
		try fileManager.moveItem(at: file, to: newFile)
		return (nil, newFile)
	}
	
	private static func chopBytes(_ bytes: inout Data) {
		var ret = bytes
		var j = 0
		for i in СЕКРЕТНЫЙ_ИНГРИДИЕНТ {
			if i == "1" {
				let b = ret[j]
				ret[j] = ret[j + 1]
				ret[j + 1] = b
				j += 1
			}
			j += 1
		}
		bytes = ret
	}
	
	private static func restoreBytes(_ bytes: inout Data) {
		var ret = bytes
		var j = 0
		for i in СЕКРЕТНЫЙ_ИНГРИДИЕНТ {
			if i == "1" {
				let b = ret[j + 1]
				//print("j: \(j), val j: \(ret[j]), val j+1: \(ret[j + 1])")
				ret[j + 1] = ret[j]
				ret[j] = b
				j += 1
			}
			j += 1
		}
		bytes = ret
	}
	
}

extension String {

	var length: Int {
		return count
	}

	subscript (i: Int) -> String {
		return self[i ..< i + 1]
	}

	func substring(fromIndex: Int) -> String {
		return self[min(fromIndex, length) ..< length]
	}

	func substring(toIndex: Int) -> String {
		return self[0 ..< max(0, toIndex)]
	}

	subscript (r: Range<Int>) -> String {
		let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
											upper: min(length, max(0, r.upperBound))))
		let start = index(startIndex, offsetBy: range.lowerBound)
		let end = index(start, offsetBy: range.upperBound - range.lowerBound)
		return String(self[start ..< end])
	}
	
}
