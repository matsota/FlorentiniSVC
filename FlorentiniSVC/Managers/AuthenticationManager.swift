//
//  AuthenticationManager.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 12.04.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import Foundation
import FirebaseAuth

class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    
    let currentUser = Auth.auth().currentUser,
    uidAdmin = "Q0Lh49RsIrMU8itoNgNJHN3bjmD2"
    
}




///
//MARK: - Crud
///
extension AuthenticationManager {
    
    //MARK: - For EMPLOYEE & EMPLOYER
    func signUp(name: String, email: String, phone: String, position: String, failure: @escaping(Error) -> Void) {
        Auth.auth().createUser(withEmail: email, password: "123456") { (result, error) in
            if let error = error {
                failure(error)
            }else{
                guard let uid = result?.user.uid else {return}
                let dataModel =  DatabaseManager.EmployeeDataStruct(name: name, phone: phone, position: position, uid: uid, success: 0, failure: 0)
                NetworkManager.shared.createNewEmpoyee(dataModel: dataModel, uid: uid)
            }
        }
    }
    
}

///
//MARK: - cRud
///
extension AuthenticationManager {
    
    //MARK: - For EMPLOYEE & EMPLOYER
    func signIn(email: String, password: String, success: @escaping(AuthDataResult) -> Void, failure: @escaping(Error) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                failure(error)
            }else{
                guard let result = result else {return}
                success(result)
            }
        }
    }
    
}

///
//MARK: - crUd
///
extension AuthenticationManager {
    
    //MARK: - For EMPLOYEE & EMPLOYER
    func updatePassword(_ password: String, _ success: @escaping() -> Void) {
        Auth.auth().currentUser?.updatePassword(to: password, completion: nil)
        success()
    }
    
}


///
//MARK: - cruD
///
extension AuthenticationManager {
    
    //MARK: - For EMPLOYEE & EMPLOYER
    func signOut(success: @escaping() -> Void, failure: @escaping(Error) -> Void) {
        do {
            try Auth.auth().signOut()
            success()
        }catch{
            failure(error)
        }
    }
    
}
