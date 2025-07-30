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
}

final class TodoListInteractor: TodoListInteractorProtocol {

	// MARK: - Public Properties

	weak var presenter: TodoListPresenterProtocol?

	// MARK: - Private Properties

	private let todoStore: TodoStoreProtocol = TodoStore()

	// MARK: - Public Methods

	func getToDosFromAPI() {
		// TODO: refactoring
		let url = URL(string: "https://dummyjson.com/todos")!
		let task = URLSession.shared.dataTask(with: URLRequest(url: url)) {
			[weak self] data,
			_,
			error in
			guard
				let data = data,
				error == nil,
				let self = self
			else {
				print("got error fetching todos") // TODO: refactoring
//				self?.presenter?.interactorDidFetchTodos(with: .failure(FetchError.unknown))
				return
			}
			do {
				print("Get data from api", data)
				let entities = try JSONDecoder().decode(TodoListModel.self, from: data)
				var counter = 0
				for entity in entities.todos {
					self.todoStore.createTodo(
						title: entity.title ?? "Задача № \(entity.taskId)",
						date: Date.now,
						description: entity.description
					)
					counter += 1
				}
				let taskArray = self.todoStore.fetchTodos()
				self.presenter?.interactorDidFetchTodos(with: .success(taskArray))
			} catch {
				self.presenter?.interactorDidFetchTodos(with: .failure(error))
			}
		}
		task.resume()
	}

	func handleDoneTap(with id: UUID) {
		print("handleDoneTap")
		todoStore.toggleTodo(with: id)
		let todos = todoStore.fetchTodos()
		presenter?.interactorDidFetchTodos(with: .success(todos))
	}

	func checkForFirstLaunch() {
//		UserDefaults.standard.set(false, forKey: "launchedBefore")// TODO: refactoring
		let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
		if launchedBefore  {
			print("Not first launch")
			let taskArray = todoStore.fetchTodos()

			if taskArray.isEmpty {
				DispatchQueue.main.async {
//					self.presenter?.interactorDidFetchTodos(with: .failure(CoreDataError.NoTodo))
					print("no todos")
					return
				}
			} else {
				print("yes todos")
				DispatchQueue.main.async {
					self.presenter?.interactorDidFetchTodos(with: .success(taskArray))
				}
			}
		} else {
			print("First launch, setting UserDefault.")
			getToDosFromAPI()
			UserDefaults.standard.set(true, forKey: "launchedBefore")
		}
	}

	func handleDelete(with id: UUID) {
		todoStore.deleteTodo(with: id)
		let todos = todoStore.fetchTodos()
		presenter?.interactorDidFetchTodos(with: .success(todos))
	}
}
