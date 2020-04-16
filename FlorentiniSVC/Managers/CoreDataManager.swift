//
//  CoreDataManager.swift
//  Florentini
//
//  Created by Andrew Matsota on 17.03.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    ///
    // - Crud
    ///
    //MARK: - Save employee's enter
    func saveEmployee(name: String, position: String, email: String, password: String, uid: String, success: @escaping() -> Void) {
        let employee = EmployeeData(context: PersistenceService.context)
        
        employee.name = name
        employee.position = position
        employee.email = email
        employee.password = password
        employee.uid = uid
        PersistenceService.saveContext()
        success()
    }
    
    ///
    // - cRud
    ///
    
    //MARK: - Fetch Employee Data
    @objc func fetchEmployeeData(success: @escaping([EmployeeData]) -> (Void), failure: @escaping(NSError) -> Void) {
        let fetchRequest: NSFetchRequest<EmployeeData> = EmployeeData.fetchRequest()
        
        do {
            let result = try PersistenceService.context.fetch(fetchRequest)
            success(result)
        }catch let error as NSError{
            failure(error)
        }
    }
    
    ///
    // - cruD
    ///
    
    //MARK: - Delete by entity name
    func deleteAllData(entity: String, success: @escaping() -> Void, failure: @escaping(NSError) -> Void) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try PersistenceService.context.fetch(fetchRequest)
            for managedObject in results {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                PersistenceService.context.delete(managedObjectData)
                PersistenceService.saveContext()
            }
            success()
        }catch let error as NSError{
            print(error.localizedDescription)
            failure(error)
        }
    }
}
