//
//  TodoListRouter.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 29.07.2025.
//

import UIKit

typealias TodoListEntryPoint = TodoListViewControllerProtocol & UIViewController

protocol TodoListRouterProtocol: AnyObject {
	var entry: TodoListEntryPoint? { get }
	static func start() -> TodoListRouterProtocol
	func navigateToDetail(from view: UIViewController, with viewModel: TodoModel?)
}

final class TodoListRouter: TodoListRouterProtocol {

	// MARK: - Public Properties

	var entry: TodoListEntryPoint?

	// MARK: - Public Methods

	static func start() -> TodoListRouterProtocol {
		let router = TodoListRouter()
		let view: TodoListViewControllerProtocol? = TodoListViewController()
		let presenter: TodoListPresenterProtocol = TodoListPresenter()

		let todoStore = TodoStore()
		let todoService = TodoService(todoStore: todoStore)
		let interactor: TodoListInteractorProtocol = TodoListInteractor(todoService: todoService)

		view?.presenter = presenter
		interactor.presenter = presenter

		presenter.interactor = interactor

		presenter.router = router
		presenter.view = view

		router.entry = view as? TodoListEntryPoint

		return router
	}

	func navigateToDetail(from view: UIViewController, with viewModel: TodoModel?) {
		print("navigateToDetail")
	}
}
