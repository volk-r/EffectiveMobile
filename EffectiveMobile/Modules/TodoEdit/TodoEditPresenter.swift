//
//  TodoEditPresenter.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 30.07.2025.
//

import Foundation

protocol TodoEditPresenterProtocol: AnyObject {
	var router: TodoEditRouterProtocol? {get set}
	var interactor: TodoEditInteractorProtocol? {get set}
	var textViewPlaceholder: String {get set}
	var view: TodoEditViewControllerProtocol? {get set}
	var viewModel: TodoModel? {get set}
	func didTapBack(title: String, description: String)
	var creationDelegate: TodoCreationProtocol? { get set }
}

protocol TodoCreationProtocol: AnyObject {
	func reloadTodos()
}

final class TodoEditPresenter: TodoEditPresenterProtocol {

	// MARK: - Public Properties

	var textViewPlaceholder: String = "Текст задачи..."

	var viewModel: TodoModel?
	var router: TodoEditRouterProtocol?
	var interactor: TodoEditInteractorProtocol?
	weak var view: TodoEditViewControllerProtocol?
	weak var creationDelegate: TodoCreationProtocol?

	// MARK: - Public Methods

	func didTapBack(title: String, description: String) {
		guard !title.isEmpty else {
			router?.navigateBack()
			return
		}

		guard let viewModel = viewModel else {
			interactor?.handleSavingTodo(title: title, description: description)
			creationDelegate?.reloadTodos()
			router?.navigateBack()
			return
		}

		interactor?.handleEditTodo(id: viewModel.id, title: title, description: description)
		creationDelegate?.reloadTodos()
		router?.navigateBack()
	}
}
