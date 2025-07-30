//
//  FetchError.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 30.07.2025.
//

import Foundation

enum FetchError: Error {
	case urlError
	case networkError
	case decodingError
}
