//
//  TodoStoreTests.swift
//  EffectiveMobileTests
//
//  Created by Roman Romanov on 30.07.2025.
//

import CoreData
@testable import EffectiveMobile
import Foundation
import Testing

// MARK: - TodoStore Tests

struct TodoStoreTests {

	@Test func testCreateTodo() {
		let mockStore = MockTodoStoreForTesting()

		let title = "Test Todo"
		let description = "Test Description"
		let date = Date()

		mockStore.createTodo(title: title, date: date, description: description)

		#expect(mockStore.createTodoCalled)
		#expect(mockStore.lastCreatedTitle == title)
		#expect(mockStore.lastCreatedDescription == description)
		#expect(mockStore.todos.count == 1)

		let createdTodo = mockStore.todos.first!
		#expect(createdTodo.title == title)
		#expect(createdTodo.taskDescription == description)
		#expect(createdTodo.completed == false)
		#expect(createdTodo.id != nil)
	}

	@Test func testFetchTodo() {
		let mockStore = MockTodoStoreForTesting()
		// Создаем задачу
		mockStore.createTodo(title: "Fetch Test", date: Date(), description: "Fetch Description")
		let todoId = mockStore.todos.first?.id ?? UUID()
		// Получаем задачу по ID
		let fetchedTodo = mockStore.fetchTodo(with: todoId)

		#expect(fetchedTodo != nil)
		#expect(fetchedTodo?.title == "Fetch Test")
		#expect(fetchedTodo?.taskDescription == "Fetch Description")
	}

	@Test func testFetchNonExistentTodo() {
		let mockStore = MockTodoStoreForTesting()
		let nonExistentId = UUID()
		let result = mockStore.fetchTodo(with: nonExistentId)
		#expect(result == nil)
	}

	@Test func testDeleteTodo() {
		let mockStore = MockTodoStoreForTesting()
		// Создаем задачу
		mockStore.createTodo(title: "Delete Test", date: Date(), description: "Delete Description")
		let todoId = mockStore.todos.first?.id ?? UUID()
		#expect(mockStore.todos.count == 1)
		// Удаляем задачу
		mockStore.deleteTodo(with: todoId)
		#expect(mockStore.deleteTodoCalled)
		#expect(mockStore.todos.count == 0)
	}

	@Test func testDeleteNonExistentTodo() {
		let mockStore = MockTodoStoreForTesting()
		let nonExistentId = UUID()
		// Попытка удалить несуществующую задачу не должна вызывать ошибок
		mockStore.deleteTodo(with: nonExistentId)

		#expect(mockStore.deleteTodoCalled)
		#expect(mockStore.todos.count == 0)
	}

	@Test func testToggleTodo() {
		let mockStore = MockTodoStoreForTesting()

		// Создаем задачу
		mockStore.createTodo(title: "Toggle Test", date: Date(), description: "Toggle Description")
		let todoId = mockStore.todos.first?.id ?? UUID()
		#expect(mockStore.todos.first!.completed == false)

		// Переключаем статус
		mockStore.toggleTodo(with: todoId)
		#expect(mockStore.toggleTodoCalled)
		#expect(mockStore.todos.first!.completed == true)

		// Переключаем обратно
		mockStore.toggleTodo(with: todoId)
		#expect(mockStore.todos.first!.completed == false)
	}

	@Test func testFetchTodos() {
		let mockStore = MockTodoStoreForTesting()
		// Создаем несколько задач
		mockStore.createTodo(title: "Todo 1", date: Date(), description: "Description 1")
		mockStore.createTodo(title: "Todo 2", date: Date(), description: "Description 2")
		mockStore.createTodo(title: "Todo 3", date: Date(), description: "Description 3")

		let todos = mockStore.fetchTodos()
		#expect(todos.count == 3)
		#expect(todos[0].title == "Todo 1")
		#expect(todos[1].title == "Todo 2")
		#expect(todos[2].title == "Todo 3")
	}

	@Test func testUpdateTodo() {
		let mockStore = MockTodoStoreForTesting()
		// Создаем задачу
		mockStore.createTodo(title: "Original Title", date: Date(), description: "Original Description")
		let todoId = mockStore.todos.first?.id ?? UUID()

		let newTitle = "Updated Title"
		let newDescription = "Updated Description"
		let newDate = Date().addingTimeInterval(3600) // +1 час
		// Обновляем задачу
		mockStore.updateTodo(with: todoId, title: newTitle, description: newDescription, date: newDate)
		#expect(mockStore.updateTodoCalled)

		let updatedTodo = mockStore.todos.first!
		#expect(updatedTodo.title == newTitle)
		#expect(updatedTodo.taskDescription == newDescription)
		#expect(updatedTodo.date == newDate)
	}

	@Test func testUpdateTodoPartially() {
		let mockStore = MockTodoStoreForTesting()

		let originalTitle = "Original Title"
		let originalDescription = "Original Description"
		let originalDate = Date()
		// Создаем задачу
		mockStore.createTodo(title: originalTitle, date: originalDate, description: originalDescription)
		let todoId = mockStore.todos.first?.id ?? UUID()
		// Обновляем только заголовок
		let newTitle = "Updated Title Only"
		mockStore.updateTodo(with: todoId, title: newTitle, description: nil, date: nil)

		let updatedTodo = mockStore.todos.first!
		#expect(updatedTodo.title == newTitle)
		#expect(updatedTodo.taskDescription == originalDescription) // Не изменилось
		#expect(updatedTodo.date == originalDate) // Не изменилось
	}

	@Test func testStoreProtocolConformance() {
		let store: TodoStoreProtocol = MockTodoStoreForTesting()
		// Проверяем, что все методы протокола доступны
		store.createTodo(title: "Protocol Test", date: Date(), description: "Protocol Description")
		let todos = store.fetchTodos()
		#expect(todos.count == 1)

		if let todoId = todos.first?.id {
			let fetchedTodo = store.fetchTodo(with: todoId)
			#expect(fetchedTodo != nil)

			store.toggleTodo(with: todoId)
			store.updateTodo(with: todoId, title: "Updated", description: "Updated", date: Date())
			store.deleteTodo(with: todoId)
		}
	}
}

// MARK: - Integration Tests

struct IntegrationTests {

	@Test func testTodoServiceWithMockStore() {
		let mockStore = MockTodoStoreForTesting()
		let service = TodoService(todoStore: mockStore)
		// Тестируем полный цикл через сервис
		service.createTodo(title: "Integration Test", date: Date(), description: "Integration Description")
		let todos = service.fetchTodos()
		#expect(todos.count == 1)

		let todoId = todos.first?.id ?? UUID()
		service.toggleTodo(with: todoId)
		let toggledTodo = service.fetchTodo(with: todoId)
		#expect(toggledTodo?.completed == true)

		service.updateTodo(with: todoId, title: "Updated Integration", description: "Updated Description", date: Date())

		let updatedTodo = service.fetchTodo(with: todoId)
		#expect(updatedTodo?.title == "Updated Integration")

		service.deleteTodo(with: todoId)

		let finalTodos = service.fetchTodos()
		#expect(finalTodos.count == 0)
	}

	@Test func testTodoListInteractorWithMockServices() {
		let mockStore = MockTodoStoreForTesting()
		let mockService = TodoService(todoStore: mockStore)
		let mockPresenter = MockTodoListPresenterForIntegration()

		let interactor = TodoListInteractor(todoService: mockService)
		interactor.presenter = mockPresenter
		// Создаем задачу через сервис
		mockService.createTodo(title: "Interactor Test", date: Date(), description: "Interactor Description")
		let todoId = mockStore.todos.first?.id ?? UUID()
		// Тестируем handleDoneTap
		interactor.handleDoneTap(with: todoId)
		#expect(mockPresenter.interactorDidFetchTodosCalled)
		// Тестируем handleDelete
		interactor.handleDelete(with: todoId)
		#expect(mockStore.todos.count == 0)
	}
}

// MARK: - Mock TodoStore for Testing

class MockTodoStoreForTesting: TodoStoreProtocol {
	var todos: [MockTodoEntity] = []

	var createTodoCalled = false
	var deleteTodoCalled = false
	var toggleTodoCalled = false
	var updateTodoCalled = false

	var lastCreatedTitle: String?
	var lastCreatedDescription: String?

	func createTodo(title: String, date: Date, description: String) {
		createTodoCalled = true
		lastCreatedTitle = title
		lastCreatedDescription = description

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
		return todos
	}

	func updateTodo(with id: UUID, title: String?, description: String?, date: Date?) {
		updateTodoCalled = true
		if let index = todos.firstIndex(where: { $0.id == id }) {
			if let title = title {
				todos[index].title = title
			}
			if let description = description {
				todos[index].taskDescription = description
			}
			if let date = date {
				todos[index].date = date
			}
		}
	}
}

// MARK: - Mock TodoListPresenter for Integration Tests

class MockTodoListPresenterForIntegration: TodoListPresenterProtocol {
	var router: TodoListRouterProtocol?
	var interactor: TodoListInteractorProtocol?
	var view: TodoListViewControllerProtocol?
	var viewModel: TodoListModel?

	var interactorDidFetchTodosCalled = false

	func interactorDidFetchTodos(with result: Result<[TodoEntity], Error>) {
		interactorDidFetchTodosCalled = true
	}

	func didTapCreateNewTodo() {}
	func didTapTodo(with id: UUID) {}
	func didDeleteTodo(with id: UUID) {}
	func searchTodo(with query: String) -> TodoListModel? { return nil }
	func didTapDone(at indexPath: IndexPath, for: EffectiveMobile.TodoModel) {}
	func didTapEditTodo(with id: UUID) {}
	func getTodosCount() -> Int {0}
	func getTodosCountString(for todoList: EffectiveMobile.TodoListModel?) -> String {""}
}
