//
//  TodoEntity.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 29.07.2025.
//

import CoreData
import Foundation

@objc(TodoEntity)
public class TodoEntity: NSManagedObject {

	@nonobjc public class func fetchRequest() -> NSFetchRequest<TodoEntity> {
		return NSFetchRequest<TodoEntity>(entityName: "TodoEntity")
	}

	@NSManaged public var taskDescription: String?
	@NSManaged public var completed: Bool
	@NSManaged public var date: Date?
	@NSManaged public var id: UUID
	@NSManaged public var title: String?
}
