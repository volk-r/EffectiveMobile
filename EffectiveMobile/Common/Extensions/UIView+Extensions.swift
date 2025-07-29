//
//  UIView+Extensions.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 29.07.2025.
//

import UIKit

extension UIView {
	
	func addSubviews(_ views: UIView...) {
		for view in views {
			addSubview(view)
			view.translatesAutoresizingMaskIntoConstraints = false
		}
	}
}
