//
//  TodoListInteractor.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 29.07.2025.
//

import Foundation

protocol TodoListInteractorProtocol: AnyObject {
	var presenter: TodoListPresenterProtocol? { get set }
	func handleDoneTap(with id: UUID)
	func checkForFirstLaunch()
	func handleDelete(with id: UUID)
	func getToDosFromAPI()
}

final class TodoListInteractor: TodoListInteractorProtocol {

	// MARK: - Public Properties

	weak var presenter: TodoListPresenterProtocol?

	// MARK: - Private Properties

	private let todoService: TodoServiceProtocol

	// MARK: - Initializers

	init(todoService: TodoServiceProtocol = TodoService()) {
		self.todoService = todoService
	}

	// MARK: - Public Methods

	func getToDosFromAPI() {
		todoService.fetchTodosFromAPI { [weak self] result in
			guard let self = self else { return }
			DispatchQueue.main.async {
				self.presenter?.interactorDidFetchTodos(with: result)
			}
		}
	}

	func handleDoneTap(with id: UUID) {
		todoService.toggleTodo(with: id)
		let todos = todoService.fetchTodos()
		DispatchQueue.main.async {
			self.presenter?.interactorDidFetchTodos(with: .success(todos))
		}
	}

	func checkForFirstLaunch() {
		todoService.checkForFirstLaunch { [weak self] result in
			guard let self = self else { return }
			DispatchQueue.main.async {
				self.presenter?.interactorDidFetchTodos(with: result)
			}
		}
	}

	func handleDelete(with id: UUID) {
		todoService.deleteTodo(with: id)
		let todos = todoService.fetchTodos()
		DispatchQueue.main.async {
			self.presenter?.interactorDidFetchTodos(with: .success(todos))
		}
	}
}
