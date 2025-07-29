//
//  CoreDataStack.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 29.07.2025.
//

import Foundation
import CoreData

final class CoreDataStack: CoreDataStackProtocol {

	static let shared = CoreDataStack()

	var context: NSManagedObjectContext {
		return persistentContainer.viewContext
	}

	private lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "TrackersDataBase")
		container.loadPersistentStores { (storeDescription, error) in
			if let error = error as NSError? {
				fatalError("❌ Could not load Tracker DataBase: \(error), \(error.userInfo)")
			}
		}
		return container
	}()

	func saveContext() {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				fatalError("❌ Could not save context \(nserror), \(nserror.userInfo)")
			}
		}
	}
}
