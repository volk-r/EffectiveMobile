//
//  TodoStore.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 29.07.2025.
//

import CoreData
import Foundation

protocol TodoStoreProtocol {
	func createTodo(title: String, date: Date, description: String)
	func fetchTodo(with id: UUID) -> TodoEntity?
	func deleteTodo(with id: UUID)
	func toggleTodo(with id: UUID)
	func fetchTodos() -> [TodoEntity]
	func updateTodo(with id: UUID, title: String?, description: String?, date: Date?)
}

final class TodoStore: NSObject, TodoStoreProtocol {

	// MARK: - Private Properties

	private let coreDataStack = CoreDataStack.shared

	// MARK: - Public Methods

	func createTodo(title: String, date: Date, description: String) {
		let todoEntity = TodoEntity(context: coreDataStack.context)
		todoEntity.id = UUID()
		todoEntity.title = title
		todoEntity.taskDescription = description
		todoEntity.date = date
		todoEntity.completed = false
		coreDataStack.saveContext()
	}

	func fetchTodo(with id: UUID) -> TodoEntity? {
		let request: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
		request.predicate = NSPredicate(
			format: "%K == %@",
			#keyPath(TodoEntity.id),
			id.uuidString
		)
		request.fetchLimit = 1

		do {
			let todo = try coreDataStack.context.fetch(request)
			return todo.first
		} catch {
			print("can't fetch todo: \(error)")
			return nil
		}
	}

	func deleteTodo(with id: UUID) {
		guard let todo = fetchTodo(with: id) else {
			return
		}
		coreDataStack.context.delete(todo)
		coreDataStack.saveContext()
	}

	func toggleTodo(with id: UUID) {
		if let todo = fetchTodo(with: id) {
			todo.completed.toggle()
		}
		coreDataStack.saveContext()
	}

	func fetchTodos() -> [TodoEntity] {
		let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
		do {
			let todos = try coreDataStack.context.fetch(fetchRequest)
			return todos
		} catch {
			print("can't fetch todos: \(error)")
		}
		return []
	}

	func updateTodo(with id: UUID, title: String? = nil, description: String? = nil, date: Date? = nil) {
		guard let todo = fetchTodo(with: id) else { return }
		if let title = title {
			todo.title = title
		}
		if let description = description {
			todo.taskDescription = description
		}
		if let date = date {
			todo.date = date
		}
		coreDataStack.saveContext()
	}
}
