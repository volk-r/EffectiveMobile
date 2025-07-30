//
//  TodoListPresenter.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 29.07.2025.
//

import UIKit

protocol TodoListPresenterProtocol: AnyObject {
	var router: TodoListRouterProtocol? { get set }
	var interactor: TodoListInteractorProtocol? { get set }
	var view: TodoListViewControllerProtocol? { get set }
	var viewModel: TodoListModel? { get set }

	func interactorDidFetchTodos(with result: Result<[TodoEntity], Error>)
	func didTapDone(at indexPath: IndexPath, for: TodoModel)
	func didTapCreateNewTodo()
	func didDeleteTodo(with id: UUID)
	func didTapEditTodo(with id: UUID)
	func searchTodo(with query: String) -> TodoListModel?

	func getTodosCount() -> Int
	func getTodosCountString(for todoList: TodoListModel?) -> String
}

class TodoListPresenter: TodoListPresenterProtocol {

	// MARK: - Public Properties

	var viewModel: TodoListModel?
	var router: TodoListRouterProtocol?
	weak var view: TodoListViewControllerProtocol?
	var interactor: TodoListInteractorProtocol? {
		didSet {
			interactor?.checkForFirstLaunch()
		}
	}

	// MARK: - Public Methods

	func interactorDidFetchTodos(with result: Result<[TodoEntity], Error>) {
		switch result {
		case.success(let todoModel):
			let todos: [TodoModel] = todoModel.map { todo in
				return TodoModel(
					id: todo.id,
					title: todo.title,
					description: todo.taskDescription ?? "",
					completed: todo.completed,
					date: DateFormatter.ddMMyyyy.string(from: Date.now)
				)
			}
			let todoListModel: TodoListModel = TodoListModel(todos: todos, total: todos.count)
			viewModel = todoListModel
			view?.update(with: todoListModel)
		case.failure:
			view?.update(with: "Something went wrong")
		}
	}

	func getTodosCount() -> Int {
		viewModel?.todos.count ?? 0
	}

	func didTapDone(at indexPath: IndexPath, for todo: TodoModel) {
		interactor?.handleDoneTap(with: todo.id)
		updateTodoCell(at: indexPath, with: todo)
	}

	func updateTodoCell(at indexPath: IndexPath, with todo: TodoModel) {
		updateLocalTodoProperties(with: todo)
		view?.reloadCell(with: indexPath)
	}

	func didTapCreateNewTodo() {
		guard let viewController = view as? UIViewController else { return }
		router?.navigateToDetail(from: viewController, with: nil)
	}

	func didTapEditTodo(with id: UUID) {
		guard
			let viewController = view as? UIViewController,
			let viewModel = viewModel?.todos.filter({$0.id == id}).first
		else {
			return
		}
		router?.navigateToDetail(from: viewController, with: viewModel)
	}

	func didDeleteTodo(with id: UUID) {
		interactor?.handleDelete(with: id)
	}

	func searchTodo(with query: String) -> TodoListModel? {
		guard let todos = viewModel?.todos else { return viewModel }
		let filterText = query.lowercased()
		let filteredList = todos.filter {
			return query.isEmpty || $0.title?.localizedCaseInsensitiveContains(filterText) ?? false
		}
		let updatedModel = TodoListModel(todos: filteredList, total: filteredList.count)

		return updatedModel
	}

	func getTodosCountString(for todoList: TodoListModel?) -> String {
		pluralizeTask(count: todoList?.todos.count ?? 0)
	}
}

// MARK: - Private Methods

private extension TodoListPresenter {

	func updateLocalTodoProperties(with todo: TodoModel) {
		if let index = viewModel?.todos.firstIndex(where: { $0.id == todo.id }) {
			viewModel?.todos[index] = TodoModel(
					id: todo.id,
					title: todo.title,
					description: todo.description,
					completed: !todo.completed,
					date: todo.date
				)
		}
	}

	func pluralizeTask(count: Int) -> String {
		let remainder10 = count % 10
		let remainder100 = count % 100

		let word: String
		if remainder10 == 1 && remainder100 != 11 {
			word = "Задача"
		} else if (2...4).contains(remainder10) && !(12...14).contains(remainder100) {
			word = "Задачи"
		} else {
			word = "Задач"
		}

		return "\(count) \(word)"
	}
}
