//
//  TodoService.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 29.07.2025.
//

import Foundation

protocol TodoServiceProtocol {
	func createTodo(title: String, date: Date, description: String)
	func updateTodo(with id: UUID, title: String, description: String, date: Date)
	func deleteTodo(with id: UUID)
	func toggleTodo(with id: UUID)
	func fetchTodos() -> [TodoEntity]
	func fetchTodo(with id: UUID) -> TodoEntity?
	func fetchTodosFromAPI(completion: @escaping (Result<[TodoEntity], Error>) -> Void)
	func checkForFirstLaunch(completion: @escaping (Result<[TodoEntity], Error>) -> Void)
}

final class TodoService: TodoServiceProtocol {

	// MARK: - Private Properties

	private let todoStore: TodoStoreProtocol
	private let userDefaults: UserDefaults = UserDefaults.standard
	private let isFirstLaunchKey = "isFirstLaunch"

	// MARK: - Initializers

	init(todoStore: TodoStoreProtocol = TodoStore()) {
		self.todoStore = todoStore
	}

	// MARK: - Public Methods

	func deleteTodo(with id: UUID) {
		todoStore.deleteTodo(with: id)
	}

	func toggleTodo(with id: UUID) {
		todoStore.toggleTodo(with: id)
	}

	func fetchTodos() -> [TodoEntity] {
		return todoStore.fetchTodos()
	}

	func fetchTodosFromAPI(completion: @escaping (Result<[TodoEntity], Error>) -> Void) {
		let url = URL(string: "https://dummyjson.com/todos")

		guard let url else {
			completion(.failure(FetchError.urlError))
			return
		}

		let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] data, _, error in
			guard
				let data = data,
				error == nil,
				let self = self
			else {
				completion(.failure(FetchError.networkError))
				return
			}

			do {
				let entities = try JSONDecoder().decode(TodoListModel.self, from: data)
				for entity in entities.todos {
					self.todoStore.createTodo(
						title: entity.title ?? "Задача № \(entity.taskId)",
						date: Date.now,
						description: entity.description
					)
				}
				let taskArray = self.todoStore.fetchTodos()
				completion(.success(taskArray))
			} catch {
				completion(.failure(FetchError.decodingError))
			}
		}
		task.resume()
	}

	func checkForFirstLaunch(completion: @escaping (Result<[TodoEntity], Error>) -> Void) {
		let launchedBefore = userDefaults.bool(forKey: isFirstLaunchKey)

		if launchedBefore {
			print("Not first launch")
			let taskArray = fetchTodos()
			completion(.success(taskArray))
		} else {
			print("First launch, setting UserDefault.")
			fetchTodosFromAPI { result in
				self.userDefaults.set(true, forKey: self.isFirstLaunchKey)
				completion(result)
			}
		}
	}

	func createTodo(title: String, date: Date, description: String) {
		todoStore.createTodo(title: title, date: date, description: description)
	}

	func fetchTodo(with id: UUID) -> TodoEntity? {
		return todoStore.fetchTodo(with: id)
	}

	func updateTodo(with id: UUID, title: String, description: String, date: Date) {
		todoStore.updateTodo(with: id, title: title, description: description, date: date)
	}
}
