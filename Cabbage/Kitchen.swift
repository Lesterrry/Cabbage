//
//  Kitchen.swift
//  Cabbage
//
//  Created by Lesterrry on 19.04.2022.
//

import Foundation

struct Kitchen {
	
	static let KITCHEN_KEY = String(1923457204628414, radix: 2)
	
	static func cook(_ file: URL, with fileManager: FileManager) {
		guard var data = fileManager.contents(atPath: file.path) else {
			return
		}
		if data.count > 100 {
			var idata = data[0...100]
			let pdata = idata
			idata = chopBytes(idata)
//			for i in idata {
//				print("\(i) ", terminator: "")
//			}
//			print("\n=========")
			idata = restoreBytes(idata)
//			for i in idata {
//				print(i, terminator: " ")
//			}
//			print("\n=========")
//			for i in pdata {
//				print(i, terminator: " ")
//			}
//			print("\n=========")
			assert(idata == pdata)
		} else {
			chopBytes(data)
		}
	}
	
	static func uncook(_ file: URL, with fileManager: FileManager) {
		
	}
	
	static func cookedData(from file: URL, with fileManager: FileManager) -> Data {
		Data()
	}
	
	private static func chopBytes(_ bytes: Data) -> Data {
		var ret = bytes
		var j = 0
		for i in KITCHEN_KEY {
			if i == "1" {
				let b = ret[j]
				//print("j: \(j), val j: \(ret[j]), val j+1: \(ret[j + 1])")
				ret[j] = ret[j + 1]
				ret[j + 1] = b
				j += 1
			}
			j += 1
		}
		return ret
	}
	
	private static func restoreBytes(_ bytes: Data) -> Data {
		var ret = bytes
		var j = 0
		for i in KITCHEN_KEY {
			if i == "1" {
				let b = ret[j + 1]
				//print("j: \(j), val j: \(ret[j]), val j+1: \(ret[j + 1])")
				ret[j + 1] = ret[j]
				ret[j] = b
				j += 1
			}
			j += 1
		}
		return ret
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
