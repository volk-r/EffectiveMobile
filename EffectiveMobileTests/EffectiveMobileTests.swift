//
//  EffectiveMobileTests.swift
//  EffectiveMobileTests
//
//  Created by Roman Romanov on 30.07.2025.
//

import Testing
import Foundation
@testable import EffectiveMobile

// MARK: - Mock Classes

class MockTodoStore: TodoStoreProtocol {
	var todos: [TodoEntity] = []
	var createTodoCalled = false
	var deleteTodoCalled = false
	var toggleTodoCalled = false
	var fetchTodosCalled = false
	var updateTodoCalled = false

	func createTodo(title: String, date: Date, description: String) {
		createTodoCalled = true
		// Создаем мок TodoEntity без CoreData
		let todo = MockTodoEntity()
		todo.id = UUID()
		todo.title = title
		todo.taskDescription = description
		todo.date = date
		todo.completed = false
		todos.append(todo)
	}

	func fetchTodo(with id: UUID) -> TodoEntity? {
		return todos.first { $0.id == id }
	}

	func deleteTodo(with id: UUID) {
		deleteTodoCalled = true
		todos.removeAll { $0.id == id }
	}

	func toggleTodo(with id: UUID) {
		toggleTodoCalled = true
		if let index = todos.firstIndex(where: { $0.id == id }) {
			todos[index].completed.toggle()
		}
	}

	func fetchTodos() -> [TodoEntity] {
		fetchTodosCalled = true
		return todos
	}

	func updateTodo(with id: UUID, title: String?, description: String?, date: Date?) {
		updateTodoCalled = true
		if let index = todos.firstIndex(where: { $0.id == id }) {
			if let title = title { todos[index].title = title }
			if let description = description { todos[index].taskDescription = description }
			if let date = date { todos[index].date = date }
		}
	}
}

class MockTodoEntity: TodoEntity {
	override var id: UUID {
		get { _id }
		set { _id = newValue }
	}

	override var title: String? {
		get { _title }
		set { _title = newValue }
	}

	override var taskDescription: String? {
		get { _taskDescription }
		set { _taskDescription = newValue }
	}

	override var date: Date? {
		get { _date }
		set { _date = newValue }
	}

	override var completed: Bool {
		get { _completed }
		set { _completed = newValue }
	}

	private var _id: UUID = UUID()
	private var _title: String?
	private var _taskDescription: String?
	private var _date: Date?
	private var _completed: Bool = false
}

class MockTodoListPresenter: TodoListPresenterProtocol {

	var router: TodoListRouterProtocol?
	var interactor: TodoListInteractorProtocol?
	var view: TodoListViewControllerProtocol?
	var viewModel: TodoListModel?

	var interactorDidFetchTodosCalled = false
	var lastFetchResult: Result<[TodoEntity], Error>?

	func interactorDidFetchTodos(with result: Result<[TodoEntity], Error>) {
		interactorDidFetchTodosCalled = true
		lastFetchResult = result
	}

	func getTodosCount() -> Int { 0 }
	func didTapDone(at indexPath: IndexPath, for todo: TodoModel) {}
	func updateTodoCell(at indexPath: IndexPath, with todo: TodoModel) {}
	func didDeleteTodo(with id: UUID) {}
	func searchTodo(with query: String) -> TodoListModel? { nil }
	func getTodosCountString(for todoList: TodoListModel?) -> String { "" }
	func didTapCreateNewTodo() {}
	func didTapEditTodo(with id: UUID) {}
}

// MARK: - TodoService Tests

struct TodoServiceTests {

	@Test func testCreateTodo() {
		let mockStore = MockTodoStore()
		let service = TodoService(todoStore: mockStore)

		service.createTodo(title: "Test Todo", date: Date(), description: "Test Description")

		#expect(mockStore.createTodoCalled)
		#expect(mockStore.todos.count == 1)
		#expect(mockStore.todos.first?.title == "Test Todo")
		#expect(mockStore.todos.first?.taskDescription == "Test Description")
	}

	@Test func testToggleTodo() {
		let mockStore = MockTodoStore()
		let service = TodoService(todoStore: mockStore)

		// Создаем тестовую задачу
		service.createTodo(title: "Test Todo", date: Date(), description: "Test Description")
		let todoId = mockStore.todos.first?.id
		let initialCompleted = mockStore.todos.first!.completed

		service.toggleTodo(with: todoId ?? UUID())

		#expect(mockStore.toggleTodoCalled)
		#expect(mockStore.todos.first!.completed != initialCompleted)
	}

	@Test func testFetchTodos() {
		let mockStore = MockTodoStore()
		let service = TodoService(todoStore: mockStore)

		// Создаем несколько тестовых задач
		service.createTodo(title: "Todo 1", date: Date(), description: "Description 1")
		service.createTodo(title: "Todo 2", date: Date(), description: "Description 2")

		let todos = service.fetchTodos()

		#expect(mockStore.fetchTodosCalled)
		#expect(todos.count == 2)
	}

	@Test func testFetchTodoById() {
		let mockStore = MockTodoStore()
		let service = TodoService(todoStore: mockStore)

		// Создаем тестовую задачу
		service.createTodo(title: "Test Todo", date: Date(), description: "Test Description")
		let todoId = mockStore.todos.first?.id

		let fetchedTodo = service.fetchTodo(with: todoId ?? UUID())

		#expect(fetchedTodo != nil)
		#expect(fetchedTodo?.title == "Test Todo")
	}

	@Test func testUpdateTodo() {
		let mockStore = MockTodoStore()
		let service = TodoService(todoStore: mockStore)

		// Создаем тестовую задачу
		service.createTodo(title: "Original Title", date: Date(), description: "Original Description")
		let todoId = mockStore.todos.first?.id

		service.updateTodo(with: todoId ?? UUID(), title: "Updated Title", description: "Updated Description", date: Date())

		#expect(mockStore.updateTodoCalled)
		#expect(mockStore.todos.first?.title == "Updated Title")
		#expect(mockStore.todos.first?.taskDescription == "Updated Description")
	}
}

// MARK: - TodoListInteractor Tests

struct TodoListInteractorTests {

	@Test func testHandleDoneTap() {
		let mockStore = MockTodoStore()
		let mockService = TodoService(todoStore: mockStore)
		let mockPresenter = MockTodoListPresenter()
		let interactor = TodoListInteractor(todoService: mockService)
		interactor.presenter = mockPresenter
		// Создаем тестовую задачу
		mockService.createTodo(title: "Test Todo", date: Date(), description: "Test Description")
		let todoId = mockStore.todos.first?.id

		interactor.handleDoneTap(with: todoId ?? UUID())

		#expect(mockStore.toggleTodoCalled)
		#expect(mockStore.fetchTodosCalled)
		// Проверяем, что presenter был вызван асинхронно
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			#expect(mockPresenter.interactorDidFetchTodosCalled)
		}
	}

	@Test func testHandleDelete() {
		let mockStore = MockTodoStore()
		let mockService = TodoService(todoStore: mockStore)
		let mockPresenter = MockTodoListPresenter()
		let interactor = TodoListInteractor(todoService: mockService)
		interactor.presenter = mockPresenter

		// Создаем тестовую задачу
		mockService.createTodo(title: "Test Todo", date: Date(), description: "Test Description")
		let todoId = mockStore.todos.first?.id

		interactor.handleDelete(with: todoId ?? UUID())

		#expect(mockStore.deleteTodoCalled)
		#expect(mockStore.fetchTodosCalled)

		// Проверяем, что presenter был вызван асинхронно
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			#expect(mockPresenter.interactorDidFetchTodosCalled)
		}
	}
}

// MARK: - TodoModel Tests

struct TodoModelTests {

	@Test func testTodoModelInitialization() {
		let id = UUID()
		let todo = TodoModel(
			id: id,
			title: "Test Title",
			description: "Test Description",
			completed: true,
			date: "2025-01-01"
		)

		#expect(todo.id == id)
		#expect(todo.title == "Test Title")
		#expect(todo.description == "Test Description")
		#expect(todo.completed == true)
		#expect(todo.date == "2025-01-01")
		#expect(todo.taskId == 0)
	}

	@Test func testTodoModelDefaultValues() {
		let todo = TodoModel(description: "Test Description")

		#expect(todo.title == nil)
		#expect(todo.description == "Test Description")
		#expect(todo.completed == false)
		#expect(todo.date == nil)
		#expect(todo.taskId == 0)
	}

	@Test func testTodoModelHashable() {
		let id = UUID()
		let todo1 = TodoModel(id: id, description: "Test")
		let todo2 = TodoModel(id: id, description: "Test")

		#expect(todo1 == todo2)
		#expect(todo1.hashValue == todo2.hashValue)
	}
}

// MARK: - TodoListModel Tests

struct TodoListModelTests {

	@Test func testTodoListModelInitialization() {
		let todo1 = TodoModel(description: "Todo 1")
		let todo2 = TodoModel(description: "Todo 2")
		let todos = [todo1, todo2]

		let todoListModel = TodoListModel(todos: todos, total: 2)

		#expect(todoListModel.todos.count == 2)
		#expect(todoListModel.total == 2)
		#expect(todoListModel.todos[0].description == "Todo 1")
		#expect(todoListModel.todos[1].description == "Todo 2")
	}

	@Test func testEmptyTodoListModel() {
		let todoListModel = TodoListModel(todos: [], total: 0)

		#expect(todoListModel.todos.isEmpty)
		#expect(todoListModel.total == 0)
	}
}

// MARK: - FetchError Tests

struct FetchErrorTests {

	@Test func testFetchErrorCases() {
		let urlError = FetchError.urlError
		let networkError = FetchError.networkError
		let decodingError = FetchError.decodingError

		#expect(urlError != networkError)
		#expect(networkError != decodingError)
		#expect(decodingError != urlError)
	}
}

// MARK: - TodoListPresenter Tests

struct TodoListPresenterTests {

	@Test func testSearchTodoWithEmptyQuery() {
		let presenter = TodoListPresenter()
		let todo1 = TodoModel(title: "Buy groceries", description: "Milk, bread, eggs")
		let todo2 = TodoModel(title: "Walk the dog", description: "30 minutes in the park")
		let todoListModel = TodoListModel(todos: [todo1, todo2], total: 2)
		presenter.viewModel = todoListModel

		let result = presenter.searchTodo(with: "")

		#expect(result?.todos.count == 2)
		#expect(result?.total == 2)
	}

	@Test func testSearchTodoWithQuery() {
		let presenter = TodoListPresenter()
		let todo1 = TodoModel(title: "Buy groceries", description: "Milk, bread, eggs")
		let todo2 = TodoModel(title: "Walk the dog", description: "30 minutes in the park")
		let todoListModel = TodoListModel(todos: [todo1, todo2], total: 2)
		presenter.viewModel = todoListModel

		let result = presenter.searchTodo(with: "buy")

		#expect(result?.todos.count == 1)
		#expect(result?.todos.first?.title == "Buy groceries")
		#expect(result?.total == 1)
	}

	@Test func testGetTodosCount() {
		let presenter = TodoListPresenter()
		let todo1 = TodoModel(description: "Todo 1")
		let todo2 = TodoModel(description: "Todo 2")
		let todoListModel = TodoListModel(todos: [todo1, todo2], total: 2)
		presenter.viewModel = todoListModel
		let count = presenter.getTodosCount()
		#expect(count == 2)
	}

	@Test func testGetTodosCountWithNilViewModel() {
		let presenter = TodoListPresenter()
		presenter.viewModel = nil
		let count = presenter.getTodosCount()
		#expect(count == 0)
	}

	@Test func testInteractorDidFetchTodosSuccess() {
		let presenter = TodoListPresenter()
		let mockTodo = MockTodoEntity()
		mockTodo.id = UUID()
		mockTodo.title = "Test Todo"
		mockTodo.taskDescription = "Test Description"
		mockTodo.completed = false

		presenter.interactorDidFetchTodos(with: .success([mockTodo]))

		#expect(presenter.viewModel != nil)
		#expect(presenter.viewModel?.todos.count == 1)
		#expect(presenter.viewModel?.total == 1)
		#expect(presenter.viewModel?.todos.first?.title == "Test Todo")
	}
}
