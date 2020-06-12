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
    
}




///
//MARK: - Crud
///
extension CoreDataManager {
    
    //MARK: - For EMPLOYEE & EMPLOYER
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
    
}

///
//MARK: - cRud
///
extension CoreDataManager {
    
    //MARK: - For EMPLOYEE & EMPLOYER
    func fetchEmployeeData(success: @escaping([EmployeeData]) -> (Void), failure: @escaping(NSError) -> Void) {
        let fetchRequest: NSFetchRequest<EmployeeData> = EmployeeData.fetchRequest()
        
        do {
            let result = try PersistenceService.context.fetch(fetchRequest)
            success(result)
        }catch let error as NSError{
            failure(error)
        }
    }
    func fetchEmployeeName(failure: @escaping(NSError) -> Void) -> String{
        var name: String?
        fetchEmployeeData(success: { (data) -> (Void) in
            name = data.map({$0.name!}).first
        }) { (error) in
            failure(error)
        }
        return name ?? ""
    }
    func fetchEmployeePosition() -> String{
        //failure: @escaping(NSError) -> Void
        var position: String?
        fetchEmployeeData(success: { (data) -> (Void) in
            position = data.map({$0.position!}).first
        }) { (error) in
//            failure(error)
        }
        return position ?? ""
    }
    func fetchEmployeeEmail(failure: @escaping(NSError) -> Void) -> String{
        var email: String?
        
        fetchEmployeeData(success: { (data) -> (Void) in
            email = data.map({$0.email!}).first
        }) { (error) in
            failure(error)
        }
        return email ?? ""
    }
    func fetchEmployeeUID() -> String{
        //failure: @escaping(NSError) -> Void
        var uid: String?
        fetchEmployeeData(success: { (data) -> (Void) in
            uid = data.map({$0.uid!}).first
        }) { (error) in
//            failure(error)
        }
        return uid ?? ""
    }
    
}

///
//MARK: - cruD
///
extension CoreDataManager {
    
    //MARK: - COMMON
    func deleteCertainEntity(for entity: String, success: @escaping() -> Void, failure: @escaping(NSError) -> Void) {
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
