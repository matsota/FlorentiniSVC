//
//  CoreDataManager.swift
//  FlorentiniSVC
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
    
    //MARK: - Fetch all employee data
    @objc func fetchEmployeeData(success: @escaping([EmployeeData]) -> (Void), failure: @escaping(NSError) -> Void) {
        let fetchRequest: NSFetchRequest<EmployeeData> = EmployeeData.fetchRequest()
        
        do {
            let result = try PersistenceService.context.fetch(fetchRequest)
            success(result)
        }catch let error as NSError{
            failure(error)
        }
    }
    
    //MARK: - Fetch employee name
    func fetchEmployeeName(failure: @escaping(NSError) -> Void) -> String{
        var name: String?
        
        fetchEmployeeData(success: { (data) -> (Void) in
            name = data.map({$0.name!}).first
        }) { (error) in
            failure(error)
        }
        return name ?? ""
    }
    
    //MARK: - Fetch employee position
    func fetchEmployeePosition(failure: @escaping(NSError) -> Void) -> String{
        var position: String?
        
        fetchEmployeeData(success: { (data) -> (Void) in
            position = data.map({$0.position!}).first
        }) { (error) in
            failure(error)
        }
        return position ?? ""
    }
    
    //MARK: - Fetch employee email
    func fetchEmployeeEmail(failure: @escaping(NSError) -> Void) -> String{
        var email: String?
        
        fetchEmployeeData(success: { (data) -> (Void) in
            email = data.map({$0.email!}).first
        }) { (error) in
            failure(error)
        }
        return email ?? ""
    }
    
    //MARK: - Fetch employee uid
    func fetchEmployeeUID(failure: @escaping(NSError) -> Void) -> String{
        var uid: String?
        
        fetchEmployeeData(success: { (data) -> (Void) in
            uid = data.map({$0.uid!}).first
        }) { (error) in
            failure(error)
        }
        return uid ?? ""
    }
    
    ///
    // - cruD
    ///
    
    //MARK: - Delete by entity name
    func deleteAllData(for entity: String, success: @escaping() -> Void, failure: @escaping(NSError) -> Void) {
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
