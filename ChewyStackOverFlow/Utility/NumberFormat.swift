//
//  NumberFormat.swift
//  ChewyStackOverFlow
//
//  Created by Ivan A. Echeverria on 3/13/20.
//  Copyright © 2020 Ivan A. Echeverria. All rights reserved.
//

import Foundation

final class NumberFormat {
	class func shortenNumber(_ num: Int) -> String {
		let number = Double(num)

		if number >= 10000, number <= 999999 {
            return String(format: "%.1fK", locale: Locale.current, number / 1000).replacingOccurrences(of: ".0", with: "")
        }

        if number > 999999 {
            return String(format: "%.1fM", locale: Locale.current, number/1000000).replacingOccurrences(of: ".0", with: "")
        }

        return String(format: "%.0f", locale: Locale.current, number)
	}
}
