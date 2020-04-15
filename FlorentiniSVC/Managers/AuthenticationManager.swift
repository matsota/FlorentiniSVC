//
//  File.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 12.04.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import Foundation
import FirebaseAuth

struct AuthenticationManager {
    
    //MARK: - Implementation
    static var shared = AuthenticationManager()
    let currentUser = Auth.auth().currentUser,
    uidAdmin = "Q0Lh49RsIrMU8itoNgNJHN3bjmD2"
    
    //MARK: - SignIn
    func signIn(email: String, password: String, success: @escaping(AuthDataResult) -> Void, failure: @escaping(Error) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                failure(error!)
            }
            else{
                guard let result = result else {return}
                success(result)
            }
        }
    }

    //MARK: - SignOut
    func signOut(success: @escaping() -> Void, failure: @escaping(Error) -> Void) {
         do {
            try Auth.auth().signOut()
            success()
         }catch{
            failure(error)
        }
    }
    
    //MARK: - Метод смены пароля:
    func passChange(password: String) {
        Auth.auth().currentUser?.updatePassword(to: password, completion: nil)
    }
    
}
