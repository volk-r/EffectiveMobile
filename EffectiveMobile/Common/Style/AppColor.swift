//
//  AppColor.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 29.07.2025.
//

import UIKit

enum AppColor {

	enum Background {
		static let primary = UIColor.systemBackground
		static let footer = UIColor.systemGray6
	}

	enum Todo {
		static let completed = UIColor.systemYellow
		static let uncompleted = UIColor.secondaryLabel
	}

	enum Button {
		static let primary = UIColor.systemYellow
	}

	enum Text {
		static let primary = UIColor.label
		static let secondary = UIColor.secondaryLabel
		static let placeholder = UIColor.lightGray
		static let error = UIColor.red
		static let strikethrough = UIColor.systemGray2
	}
}
