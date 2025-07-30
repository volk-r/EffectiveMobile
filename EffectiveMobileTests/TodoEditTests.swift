//
//  TodoEditTests.swift
//  EffectiveMobileTests
//
//  Created by Roman Romanov on 30.07.2025.
//

@testable import EffectiveMobile
import Foundation
import Testing

// MARK: - TodoEditInteractor Tests

struct TodoEditInteractorTests {

	@Test func testHandleSavingTodo() {
		let mockService = MockTodoService()
		let interactor = TodoEditInteractor(todoService: mockService)
		let title = "New Todo"
		let description = "New Description"
		interactor.handleSavingTodo(title: title, description: description)

		#expect(mockService.createTodoCalled)
		#expect(mockService.lastCreatedTitle == title)
		#expect(mockService.lastCreatedDescription == description)
	}

	@Test func testHandleEditTodo() {
		let mockService = MockTodoService()
		let interactor = TodoEditInteractor(todoService: mockService)
		let todoId = UUID()
		let title = "Updated Todo"
		let description = "Updated Description"
		interactor.handleEditTodo(id: todoId, title: title, description: description)

		#expect(mockService.updateTodoCalled)
		#expect(mockService.lastUpdatedId == todoId)
		#expect(mockService.lastUpdatedTitle == title)
		#expect(mockService.lastUpdatedDescription == description)
	}

	@Test func testInteractorProtocolConformance() {
		let mockService = MockTodoService()
		let interactor: TodoEditInteractorProtocol = TodoEditInteractor(todoService: mockService)
		// Проверяем, что все методы протокола доступны
		interactor.handleSavingTodo(title: "Test", description: "Test Description")
		interactor.handleEditTodo(id: UUID(), title: "Edit Test", description: "Edit Description")

		#expect(interactor.presenter == nil) // По умолчанию nil
	}
}

// MARK: - TodoEditPresenter Tests

struct TodoEditPresenterTests {

	@Test func testDidTapBackWithEmptyTitle() {
		let mockRouter = MockTodoEditRouter()
		let mockInteractor = MockTodoEditInteractor()
		let presenter = TodoEditPresenter()

		presenter.router = mockRouter
		presenter.interactor = mockInteractor
		// Тестируем с пустым заголовком
		presenter.didTapBack(title: "", description: "Some description")

		#expect(mockRouter.navigateBackCalled)
		#expect(!mockInteractor.handleSavingTodoCalled)
		#expect(!mockInteractor.handleEditTodoCalled)
	}

	@Test func testDidTapBackWithNewTodo() {
		let mockRouter = MockTodoEditRouter()
		let mockInteractor = MockTodoEditInteractor()
		let mockDelegate = MockTodoCreationDelegate()
		let presenter = TodoEditPresenter()

		presenter.router = mockRouter
		presenter.interactor = mockInteractor
		presenter.creationDelegate = mockDelegate
		presenter.viewModel = nil // Новая задача

		let title = "New Todo"
		let description = "New Description"

		presenter.didTapBack(title: title, description: description)

		#expect(mockInteractor.handleSavingTodoCalled)
		#expect(mockInteractor.lastSavedTitle == title)
		#expect(mockInteractor.lastSavedDescription == description)
		#expect(mockDelegate.reloadTodosCalled)
		#expect(mockRouter.navigateBackCalled)
	}

	@Test func testDidTapBackWithExistingTodo() {
		let mockRouter = MockTodoEditRouter()
		let mockInteractor = MockTodoEditInteractor()
		let mockDelegate = MockTodoCreationDelegate()
		let presenter = TodoEditPresenter()

		presenter.router = mockRouter
		presenter.interactor = mockInteractor
		presenter.creationDelegate = mockDelegate
		// Устанавливаем существующую задачу
		let existingTodo = TodoModel(
			id: UUID(),
			title: "Existing Todo",
			description: "Existing Description",
			completed: false,
			date: "2025-07-30"
		)
		presenter.viewModel = existingTodo

		let newTitle = "Updated Todo"
		let newDescription = "Updated Description"

		presenter.didTapBack(title: newTitle, description: newDescription)

		#expect(mockInteractor.handleEditTodoCalled)
		#expect(mockInteractor.lastEditedId == existingTodo.id)
		#expect(mockInteractor.lastEditedTitle == newTitle)
		#expect(mockInteractor.lastEditedDescription == newDescription)
		#expect(mockDelegate.reloadTodosCalled)
		#expect(mockRouter.navigateBackCalled)
	}

	@Test func testTextViewPlaceholder() {
		let presenter = TodoEditPresenter()
		#expect(presenter.textViewPlaceholder == "Текст задачи...")
		// Тестируем изменение placeholder
		presenter.textViewPlaceholder = "Custom placeholder"
		#expect(presenter.textViewPlaceholder == "Custom placeholder")
	}

	@Test func testPresenterProtocolConformance() {
		let presenter: TodoEditPresenterProtocol = TodoEditPresenter()
		// Проверяем, что все свойства протокола доступны
		#expect(presenter.router == nil)
		#expect(presenter.interactor == nil)
		#expect(presenter.view == nil)
		#expect(presenter.viewModel == nil)
		#expect(presenter.creationDelegate == nil)
		#expect(presenter.textViewPlaceholder == "Текст задачи...")
	}
}

// MARK: - Mock Classes for TodoEdit Tests

class MockTodoService: TodoServiceProtocol {

	var createTodoCalled = false
	var updateTodoCalled = false
	var lastCreatedTitle: String?
	var lastCreatedDescription: String?
	var lastUpdatedId: UUID?
	var lastUpdatedTitle: String?
	var lastUpdatedDescription: String?

	func createTodo(title: String, date: Date, description: String) {
		createTodoCalled = true
		lastCreatedTitle = title
		lastCreatedDescription = description
	}

	func updateTodo(with id: UUID, title: String, description: String, date: Date) {
		updateTodoCalled = true
		lastUpdatedId = id
		lastUpdatedTitle = title
		lastUpdatedDescription = description
	}

	func deleteTodo(with id: UUID) {}
	func toggleTodo(with id: UUID) {}
	func fetchTodos() -> [TodoEntity] { return [] }
	func fetchTodo(with id: UUID) -> TodoEntity? { return nil }
	func fetchTodosFromAPI(completion: @escaping (Result<TodoListModel, Error>) -> Void) {}
	func checkForFirstLaunch(completion: @escaping (Result<[TodoEntity], Error>) -> Void) {}
	func fetchTodosFromAPI(completion: @escaping (Result<[EffectiveMobile.TodoEntity], any Error>) -> Void) {}
}

class MockTodoEditInteractor: TodoEditInteractorProtocol {
	var presenter: TodoEditPresenterProtocol?
	var handleSavingTodoCalled = false
	var handleEditTodoCalled = false
	var lastSavedTitle: String?
	var lastSavedDescription: String?
	var lastEditedId: UUID?
	var lastEditedTitle: String?
	var lastEditedDescription: String?

	func handleSavingTodo(title: String, description: String) {
		handleSavingTodoCalled = true
		lastSavedTitle = title
		lastSavedDescription = description
	}

	func handleEditTodo(id: UUID, title: String, description: String) {
		handleEditTodoCalled = true
		lastEditedId = id
		lastEditedTitle = title
		lastEditedDescription = description
	}
}

class MockTodoEditPresenter: TodoEditPresenterProtocol {
	var router: TodoEditRouterProtocol?
	var interactor: TodoEditInteractorProtocol?
	var textViewPlaceholder: String = "Test placeholder"
	var view: TodoEditViewControllerProtocol?
	var viewModel: TodoModel?
	var creationDelegate: TodoCreationProtocol?

	func didTapBack(title: String, description: String) {}
}

class MockTodoEditRouter: TodoEditRouterProtocol {

	var todoEntryPoint: TodoEditEntryPoint?
	var navigateBackCalled = false

	func navigateBack() {
		navigateBackCalled = true
	}

	static func start(_ viewModel: EffectiveMobile.TodoModel?) -> any EffectiveMobile.TodoEditRouterProtocol {
		TodoEditRouter()
	}
}

class MockTodoEditViewController: TodoEditViewControllerProtocol {
	var presenter: TodoEditPresenterProtocol?
}

class MockTodoCreationDelegate: TodoCreationProtocol {
	var reloadTodosCalled = false

	func reloadTodos() {
		reloadTodosCalled = true
	}
}
