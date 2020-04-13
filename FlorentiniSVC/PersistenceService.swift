//
//  PersistenceService.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 20.03.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import Foundation
import CoreData

class PersistenceService {
    //MARK: CoreData stack
    private init() {}
    
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FlorentiniModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo). IN: static var persistentContainer")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo). IN: static func saveContext")
            }
        }
    }
}
