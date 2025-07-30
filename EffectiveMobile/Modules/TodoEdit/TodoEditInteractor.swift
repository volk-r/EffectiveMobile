//
//  TodoEditInteractor.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 30.07.2025.
//

import Foundation

protocol TodoEditInteractorProtocol: AnyObject {
	var presenter: TodoEditPresenterProtocol? { get set }
	func handleSavingTodo(title: String, description: String)
	func handleEditTodo(id: UUID, title: String, description: String)
}

final class TodoEditInteractor: TodoEditInteractorProtocol {

	// MARK: - Public Properties

	weak var presenter: TodoEditPresenterProtocol?

	// MARK: - Private Properties

	private let todoService: TodoServiceProtocol

	// MARK: - Initializers

	init(todoService: TodoServiceProtocol = TodoService()) {
		self.todoService = todoService
	}

	// MARK: - Public Methods

	func handleSavingTodo(title: String, description: String) {
		todoService.createTodo(title: title, date: Date.now, description: description)
	}

	func handleEditTodo(id: UUID, title: String, description: String) {
		todoService.updateTodo(with: id, title: title, description: description, date: .now)
	}
}
