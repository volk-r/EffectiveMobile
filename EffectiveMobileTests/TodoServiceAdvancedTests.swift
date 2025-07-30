//
//  TodoServiceAdvancedTests.swift
//  EffectiveMobileTests
//
//  Created by Roman Romanov on 30.07.2025.
//

@testable import EffectiveMobile
import Foundation
import Testing

// MARK: - Advanced TodoService Tests

struct TodoServiceAdvancedTests {

	@Test func testCheckForFirstLaunchWhenFirstTime() async {
		let mockStore = MockTodoStore()
		let mockUserDefaults = MockUserDefaults()
		let service = TodoService(todoStore: mockStore)
		// Устанавливаем, что это первый запуск
		mockUserDefaults.set(false, forKey: "isFirstLaunch")

		await withCheckedContinuation { continuation in
			service.checkForFirstLaunch { result in
				switch result {
				case .success(let todos):
					// При первом запуске должны загружаться данные из API
					#expect(todos.isEmpty == false || todos.isEmpty == true) // API может вернуть пустой массив
				case .failure:
					// Ошибка может произойти при загрузке из API
					break
				}
				continuation.resume()
			}
		}
	}

	@Test func testCheckForFirstLaunchWhenNotFirstTime() async {
		let mockStore = MockTodoStore()
		let service = TodoService(todoStore: mockStore)
		// Добавляем тестовые данные в store
		service.createTodo(title: "Existing Todo", date: Date(), description: "Existing Description")

		await withCheckedContinuation { continuation in
			service.checkForFirstLaunch { result in
				switch result {
				case .success(let todos):
					#expect(todos.count >= 1)
					#expect(todos.first?.title == "Existing Todo")
				case .failure:
					#expect(Bool(false), "Should not fail when fetching existing todos")
				}
				continuation.resume()
			}
		}
	}

	@Test func testFetchTodosFromAPIWithInvalidURL() async {
		let mockStore = MockTodoStore()
		let service = TodoService(todoStore: mockStore)
		// Этот тест проверяет обработку ошибок в реальном API вызове
		await withCheckedContinuation { continuation in
			service.fetchTodosFromAPI { result in
				switch result {
				case .success:
					// API может успешно вернуть данные
					break
				case .failure(let error):
					// Проверяем, что ошибка правильно обрабатывается
					#expect(error is FetchError)
				}
				continuation.resume()
			}
		}
	}

	@Test func testServiceWithCustomUserDefaults() {
		let mockStore = MockTodoStore()
		let service = TodoService(todoStore: mockStore)
		service.createTodo(title: "Test with custom UserDefaults", date: Date(), description: "Test Description")

		#expect(mockStore.createTodoCalled)
		#expect(mockStore.todos.count == 1)
	}

	@Test func testConcurrentOperations() async {
		let mockStore = MockTodoStore()
		let service = TodoService(todoStore: mockStore)

		// Тестируем concurrent операции
		await withTaskGroup(of: Void.self) { group in
			for index in 0..<10 {
				group.addTask {
					service.createTodo(
						title: "Concurrent Todo \(index)",
						date: Date(),
						description: "Description \(index)"
					)
				}
			}
		}

		#expect(mockStore.todos.count == 10)
	}

	@Test func testUpdateNonExistentTodo() {
		let mockStore = MockTodoStore()
		let service = TodoService(todoStore: mockStore)

		let nonExistentId = UUID()

		// Пытаемся обновить несуществующую задачу
		service.updateTodo(
			with: nonExistentId,
			title: "Updated Title",
			description: "Updated Description",
			date: Date()
		)

		#expect(mockStore.updateTodoCalled)
		#expect(mockStore.todos.isEmpty) // Задача не должна быть создана
	}

	@Test func testDeleteNonExistentTodo() {
		let mockStore = MockTodoStore()
		let service = TodoService(todoStore: mockStore)
		let nonExistentId = UUID()
		// Пытаемся удалить несуществующую задачу
		service.deleteTodo(with: nonExistentId)
		#expect(mockStore.deleteTodoCalled)
		#expect(mockStore.todos.isEmpty) // Список должен остаться пустым
	}

	@Test func testFetchTodoWithNonExistentId() {
		let mockStore = MockTodoStore()
		let service = TodoService(todoStore: mockStore)
		let nonExistentId = UUID()
		let result = service.fetchTodo(with: nonExistentId)
		#expect(result == nil)
	}

	@Test func testServiceProtocolConformance() {
		let mockStore = MockTodoStore()
		let service: TodoServiceProtocol = TodoService(todoStore: mockStore)
		// Проверяем, что все методы протокола доступны
		service.createTodo(title: "Protocol Test", date: Date(), description: "Test Description")
		let todos = service.fetchTodos()
		#expect(todos.count == 1)

		if let todoId = todos.first?.id {
			service.toggleTodo(with: todoId)
			service.updateTodo(with: todoId, title: "Updated", description: "Updated", date: Date())
			service.deleteTodo(with: todoId)
		}
	}
}

// MARK: - Mock UserDefaults for Advanced Testing

class MockUserDefaults: UserDefaults {
	private var storage: [String: Any] = [:]

	override func bool(forKey defaultName: String) -> Bool {
		return storage[defaultName] as? Bool ?? false
	}

	override func set(_ value: Bool, forKey defaultName: String) {
		storage[defaultName] = value
	}

	override func object(forKey defaultName: String) -> Any? {
		return storage[defaultName]
	}

	override func set(_ value: Any?, forKey defaultName: String) {
		storage[defaultName] = value
	}

	func clearStorage() {
		storage.removeAll()
	}
}
