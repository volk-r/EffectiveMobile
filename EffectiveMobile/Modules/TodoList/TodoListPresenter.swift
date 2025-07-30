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
			let dateFormatter = DateFormatter() // TODO: refactoring
			dateFormatter.dateFormat = "dd/MM/yyyy"
			let todos: [TodoModel] = todoModel.map { todo in
				print("interactorDidFetchTodos todo", todo)
				let date = Date.now
				return TodoModel(
					id: todo.id,
					title: todo.title,
					description: todo.taskDescription ?? "",
					completed: todo.completed,
					date: dateFormatter.string(from: date)
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
		print("didTapCreateNewTodo: new todo")
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
}
