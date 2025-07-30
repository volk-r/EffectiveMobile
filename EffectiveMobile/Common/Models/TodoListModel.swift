//
//  TodoListModel.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 29.07.2025.
//

import Foundation

struct TodoListModel: Decodable {
	var todos: [TodoModel]
	var total: Int
}
