//
//  DateFormatter+Extensions.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 30.07.2025.
//

import Foundation

extension DateFormatter {
	
	static let ddMMyyyy: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd/MM/yyyy"
		return formatter
	}()
}
