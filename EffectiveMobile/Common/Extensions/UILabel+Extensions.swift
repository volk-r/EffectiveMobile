//
//  UILabel+Extensions.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 29.07.2025.
//

import UIKit

extension UILabel {

	func animateStrikethrough(isStrikethrough: Bool = true, duration: TimeInterval = 0.3) {
		let animation = CATransition()
		animation.duration = duration
		animation.type = .fade
		self.layer.add(animation, forKey: nil)
		setStrikethrough(shouldStrike: isStrikethrough)
	}

	private func setStrikethrough(shouldStrike: Bool) {
		guard let text = self.text else { return }

		let attributes: [NSAttributedString.Key: Any]
		if shouldStrike {
			attributes = [
				.strikethroughStyle: NSUnderlineStyle.single.rawValue,
				.foregroundColor: AppColor.Text.strikethrough
			]
		} else {
			attributes = [
				.strikethroughStyle: 0,
				.foregroundColor: AppColor.Text.primary
			]
		}

		let attributedString = NSAttributedString(string: text, attributes: attributes)
		self.attributedText = attributedString
	}
}
