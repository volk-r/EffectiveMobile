//
//  TodoEditRouter.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 30.07.2025.
//

import UIKit

typealias TodoEditEntryPoint = TodoEditViewControllerProtocol & UIViewController

protocol TodoEditRouterProtocol {
	var todoEntryPoint: TodoEditEntryPoint? { get }
	static func start(_ viewModel: TodoModel?) -> TodoEditRouterProtocol
	func navigateBack()
}

final class TodoEditRouter: TodoEditRouterProtocol {

	// MARK: - Public Properties

	var todoEntryPoint: TodoEditEntryPoint?

	// MARK: - Public Methods

	static func start(_ viewModel: TodoModel? = nil) -> TodoEditRouterProtocol {
		let router = TodoEditRouter()
		let view: TodoEditViewControllerProtocol? = TodoEditViewController()
		let interactor: TodoEditInteractorProtocol = TodoEditInteractor()
		let presenter: TodoEditPresenterProtocol = TodoEditPresenter()

		view?.presenter = presenter
		interactor.presenter = presenter
		presenter.interactor = interactor
		presenter.router = router
		presenter.view = view
		presenter.viewModel = viewModel

		router.todoEntryPoint = view as? TodoEditEntryPoint

		return router
	}

	func navigateBack() {
		todoEntryPoint?.navigationController?.popViewController(animated: true)
	}
}
