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

class TodoListRouter: TodoListRouterProtocol {

	// MARK: - Public Properties

	var entry: TodoListEntryPoint?

	// MARK: - Public Methods

	static func start() -> TodoListRouterProtocol {
		let router = TodoListRouter()
		let view: TodoListViewControllerProtocol? = TodoListViewController()
		let presenter: TodoListPresenterProtocol = TodoListPresenter()
		let interactor: TodoListInteractorProtocol = TodoListInteractor()

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
