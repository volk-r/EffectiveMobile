//
//  TodoModel.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 29.07.2025.
//

import Foundation

struct TodoModel: Hashable, Decodable {
	var id: UUID = UUID()
	let taskId: Int
	let title: String?
	let description: String
	let completed: Bool
	let date: String?

	private enum CodingKeys: String, CodingKey {
		case taskId = "id"
		case title
		case description = "todo"
		case completed
		case date
	}

	init(
		id: UUID = UUID(),
		title: String? = nil,
		description: String,
		completed: Bool = false,
		date: String? = nil
	) {
		self.id = id
		self.title = title
		self.taskId = 0
		self.description = description
		self.completed = completed
		self.date = date
	}
}
