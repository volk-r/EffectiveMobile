//
//  PerformanceAndEdgeCaseTests.swift
//  EffectiveMobileTests
//
//  Created by Roman Romanov on 30.07.2025.
//

@testable import EffectiveMobile
import Foundation
import Testing

// MARK: - Performance Tests

struct PerformanceTests {

	@Test func testCreateManyTodosPerformance() {
		let mockStore = MockTodoStoreForTesting()
		let service = TodoService(todoStore: mockStore)
		let startTime = CFAbsoluteTimeGetCurrent()
		// Создаем 1000 задач
		for index in 0..<1000 {
			service.createTodo(
				title: "Performance Test Todo \(index)",
				date: Date(),
				description: "Performance test description \(index)"
			)
		}

		let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

		#expect(mockStore.todos.count == 1000)
		#expect(timeElapsed < 1.0) // Должно выполниться менее чем за 1 секунду
	}

	@Test func testFetchManyTodosPerformance() {
		let mockStore = MockTodoStoreForTesting()
		let service = TodoService(todoStore: mockStore)
		// Создаем много задач
		for index in 0..<500 {
			service.createTodo(
				title: "Fetch Test Todo \(index)",
				date: Date(),
				description: "Fetch test description \(index)"
			)
		}

		let startTime = CFAbsoluteTimeGetCurrent()
		// Получаем все задачи
		let todos = service.fetchTodos()
		let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
		#expect(todos.count == 500)
		#expect(timeElapsed < 0.5) // Должно выполниться менее чем за 0.5 секунды
	}

	@Test func testToggleManyTodosPerformance() {
		let mockStore = MockTodoStoreForTesting()
		let service = TodoService(todoStore: mockStore)

		// Создаем задачи
		for index in 0..<100 {
			service.createTodo(
				title: "Toggle Test Todo \(index)",
				date: Date(),
				description: "Toggle test description \(index)"
			)
		}

		let todoIds = service.fetchTodos().compactMap { $0.id }
		let startTime = CFAbsoluteTimeGetCurrent()
		// Переключаем статус всех задач
		for id in todoIds {
			service.toggleTodo(with: id)
		}
		let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
		#expect(timeElapsed < 0.5) // Должно выполниться менее чем за 0.5 секунды
		// Проверяем, что все задачи переключились
		let toggledTodos = service.fetchTodos()
		let allCompleted = toggledTodos.allSatisfy { $0.completed }
		#expect(allCompleted)
	}
}

// MARK: - Edge Case Tests

struct EdgeCaseTests {

	@Test func testCreateTodoWithVeryLongTitle() {
		let mockStore = MockTodoStoreForTesting()
		let service = TodoService(todoStore: mockStore)
		// Создаем очень длинный заголовок (1000 символов)
		let longTitle = String(repeating: "A", count: 1000)
		service.createTodo(title: longTitle, date: Date(), description: "Description")

		#expect(mockStore.todos.count == 1)
		#expect(mockStore.todos.first?.title == longTitle)
	}

	@Test func testCreateTodoWithVeryLongDescription() {
		let mockStore = MockTodoStoreForTesting()
		let service = TodoService(todoStore: mockStore)
		// Создаем очень длинное описание (5000 символов)
		let longDescription = String(repeating: "B", count: 5000)
		service.createTodo(title: "Title", date: Date(), description: longDescription)

		#expect(mockStore.todos.count == 1)
		#expect(mockStore.todos.first?.taskDescription == longDescription)
	}

	@Test func testCreateTodoWithSpecialCharacters() {
		let mockStore = MockTodoStoreForTesting()
		let service = TodoService(todoStore: mockStore)
		let specialTitle = "🚀 Задача с эмодзи & спецсимволами: <>&\"'"
		let specialDescription = "Описание с переносами\nстрок и табуляцией\t"

		service.createTodo(title: specialTitle, date: Date(), description: specialDescription)

		#expect(mockStore.todos.count == 1)
		#expect(mockStore.todos.first?.title == specialTitle)
		#expect(mockStore.todos.first?.taskDescription == specialDescription)
	}

	@Test func testCreateTodoWithFutureDate() {
		let mockStore = MockTodoStoreForTesting()
		let service = TodoService(todoStore: mockStore)
		// Дата в будущем (через год)
		let futureDate = Date().addingTimeInterval(365 * 24 * 60 * 60)
		service.createTodo(title: "Future Todo", date: futureDate, description: "Future Description")

		#expect(mockStore.todos.count == 1)
		#expect(mockStore.todos.first?.date == futureDate)
	}

	@Test func testCreateTodoWithPastDate() {
		let mockStore = MockTodoStoreForTesting()
		let service = TodoService(todoStore: mockStore)
		// Дата в прошлом (год назад)
		let pastDate = Date().addingTimeInterval(-365 * 24 * 60 * 60)

		service.createTodo(title: "Past Todo", date: pastDate, description: "Past Description")

		#expect(mockStore.todos.count == 1)
		#expect(mockStore.todos.first?.date == pastDate)
	}

	@Test func testSearchWithEmptyQuery() {
		let mockPresenter = TodoListPresenter()
		// Создаем тестовую модель
		let todos = [
			TodoModel(id: UUID(), title: "Test Todo", description: "Test Description", completed: false, date: "2025-07-30")
		]
		mockPresenter.viewModel = TodoListModel(todos: todos, total: 1)

		let result = mockPresenter.searchTodo(with: "")
		#expect(result?.todos.count == 1) // Пустой запрос должен возвращать все задачи
	}

	@Test func testSearchWithNonExistentQuery() {
		let mockPresenter = TodoListPresenter()
		let todos = [
			TodoModel(id: UUID(), title: "Test Todo", description: "Test Description", completed: false, date: "2025-07-30")
		]
		mockPresenter.viewModel = TodoListModel(todos: todos, total: 1)
		let result = mockPresenter.searchTodo(with: "NonExistent")
		#expect(result?.todos.count == 0) // Несуществующий запрос должен возвращать пустой массив
	}

	@Test func testSearchCaseInsensitive() {
		let mockPresenter = TodoListPresenter()
		let todos = [
			TodoModel(id: UUID(), title: "Test Todo", description: "Test Description", completed: false, date: "2025-07-30")
		]
		mockPresenter.viewModel = TodoListModel(todos: todos, total: 1)

		let result1 = mockPresenter.searchTodo(with: "test")
		let result2 = mockPresenter.searchTodo(with: "TEST")
		let result3 = mockPresenter.searchTodo(with: "Test")

		#expect(result1?.todos.count == 1)
		#expect(result2?.todos.count == 1)
		#expect(result3?.todos.count == 1)
	}

	@Test func testFetchErrorTypes() {
		let networkError = FetchError.networkError
		let decodingError = FetchError.decodingError
		let urlError = FetchError.urlError
		// Проверяем, что все типы ошибок различны
		#expect(networkError != decodingError)
		#expect(decodingError != urlError)
		#expect(networkError != urlError)
	}

	@Test func testTodoListModelWithEmptyTodos() {
		let emptyModel = TodoListModel(todos: [], total: 0)
		#expect(emptyModel.todos.isEmpty)
		#expect(emptyModel.total == 0)
	}
}

// MARK: - Memory Management Tests

struct MemoryManagementTests {
	@Test func testWeakReferencesInInteractor() {
		let mockService = MockTodoService()
		let interactor = TodoListInteractor(todoService: mockService)

		var presenter: TodoListPresenter? = TodoListPresenter()
		interactor.presenter = presenter

		#expect(interactor.presenter != nil)
		// Освобождаем presenter
		presenter = nil
		// Weak reference должен стать nil
		#expect(interactor.presenter == nil)
	}

	@Test func testWeakReferencesInEditInteractor() {
		let mockService = MockTodoService()
		let interactor = TodoEditInteractor(todoService: mockService)

		var presenter: TodoEditPresenter? = TodoEditPresenter()
		interactor.presenter = presenter

		#expect(interactor.presenter != nil)
		// Освобождаем presenter
		presenter = nil
		// Weak reference должен стать nil
		#expect(interactor.presenter == nil)
	}

	@Test func testWeakReferencesInPresenter() {
		let presenter = TodoListPresenter()

		var mockView: MockTodoListViewController? = MockTodoListViewController()
		presenter.view = mockView

		#expect(presenter.view != nil)
		// Освобождаем view
		mockView = nil
		// Weak reference должен стать nil
		#expect(presenter.view == nil)
	}
}

// MARK: - Mock Classes for Memory Tests

class MockTodoListViewController: TodoListViewControllerProtocol {

	var presenter: TodoListPresenterProtocol?

	func showTodos(with viewModel: TodoListModel) {}
	func showError(message: String) {}
	func showLoading() {}
	func hideLoading() {}
	func reloadTableView() {}
	func reloadCell(with indexPath: IndexPath) {}
	func update(with todos: EffectiveMobile.TodoListModel?) {}
	func update(with error: String) {}
}
