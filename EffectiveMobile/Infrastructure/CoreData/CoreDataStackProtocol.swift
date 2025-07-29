//
//  CoreDataStackProtocol.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 29.07.2025.
//

import Foundation
import CoreData

protocol CoreDataStackProtocol: AnyObject {
	var context: NSManagedObjectContext { get }
	func saveContext()
}
