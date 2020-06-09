//
//  NetworkManager.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 19.02.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseUI

class NetworkManager {
    
    //MARK: - Системные переменные
    static let shared = NetworkManager()
    let db = Firestore.firestore()
    
    
    ///
    //MARK: - Crud
    ///
    
    //MARK: - Prepare product description for setup in Firebase
    func setupProductDescription(productName: String, productPrice: Int, productDescription: String, productCategory: String, stock: Bool, searchArray: [String], success: @escaping() -> Void) {
        let ref = db.collection(NavigationCases.FirstCollectionRow.productInfo.rawValue).document(),
        dataModel = DatabaseManager.ProductInfo(productName: productName, productPrice: productPrice, productDescription: productDescription, productCategory: productCategory, stock: stock, productID: ref.documentID, searchArray: searchArray, voteCount: 0, voteAmount: 0)
            ref.setData(dataModel.dictionary)
        success()
    }
    
    //MARK: - Setup new product in Firebase
    func setupProduct(image: UIImageView, productName: String, progressIndicator: UIProgressView, success: @escaping() -> Void, failure: @escaping(Error) -> Void) {
        progressIndicator.isHidden = false
        guard AuthenticationManager.shared.uidAdmin == AuthenticationManager.shared.currentUser?.uid, let imageData = image.image?.jpegData(compressionQuality: 0.75) else {return}
        let uploadRef = Storage.storage().reference(withPath: "\(NavigationCases.FirstCollectionRow.imageCollection.rawValue)/\(productName)"),
        uploadMetadata = StorageMetadata.init()
        
        uploadMetadata.contentType = "image/jpg"
        
        let taskRef = uploadRef.putData(imageData, metadata: uploadMetadata) { (downloadMetadata, error) in
            if let error = error {
                print("Oh no! \(error.localizedDescription)")
                return
            }
        }
        
        taskRef.observe(.progress){ (snapshot) in
            guard let pctThere = snapshot.progress?.fractionCompleted else {return}
            progressIndicator.progress = Float(pctThere)
        }
        
        taskRef.observe(.success) { i in
            if let error = i.error {
                failure(error)
            }else{
                progressIndicator.isHidden = true
                success()
            }
        }
        
    }
    
    //MARK: - New Employee
    
    func createNewEmpoyee(dataModel: DatabaseManager.EmployeeDataStruct, uid: String) {
        db.collection(NavigationCases.FirstCollectionRow.employee.rawValue).document(uid).setData(dataModel.dictionary)
    }
    
    //MARK: - Archive order
    func archiveOrder(dataModel: DatabaseManager.Order, orderKey: String){
        db.collection(NavigationCases.FirstCollectionRow.archivedOrder.rawValue).addDocument(data: dataModel.dictionary)
        archiveOrderAddition(orderID: orderKey)
    }
    
    //MARK: Archive order addition
    func archiveOrderAddition(orderID: String) {
        var addition = [DatabaseManager.OrderAddition](),
        jsonArray: [[String: Any]] = []
        
        let docRef = db.collection(NavigationCases.FirstCollectionRow.order.rawValue).document(orderID)
        docRef.collection(NavigationCases.OrderCases.orderDescription.rawValue).getDocuments(completion: {
            (querySnapshot, _) in
            addition = querySnapshot!.documents.compactMap{DatabaseManager.OrderAddition(dictionary: $0.data())}
            for i in addition {
                jsonArray.append(i.dictionary)
            }
            
            for _ in jsonArray {
                self.db.collection(NavigationCases.FirstCollectionRow.archivedOrderDescription.rawValue).addDocument(data: jsonArray.remove(at: 0))
            }
        })
        
        db.collection(NavigationCases.FirstCollectionRow.order.rawValue).document(orderID).delete()
        deleteOrderAddition(collection: docRef.collection(NavigationCases.OrderCases.orderDescription.rawValue))
    }
    
    //MARK: - New chat message
    func newChatMessage(name: String, content: String, position: String) {
        let newMessage = DatabaseManager.ChatMessages(name: name, content: content, position: position, uid: AuthenticationManager.shared.currentUser!.uid, timeStamp: Date())
        var ref: DocumentReference? = nil
        
        ref = db.collection(NavigationCases.FirstCollectionRow.employeeMessages.rawValue).addDocument(data: newMessage.dictionary) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }else{
                print("It's ok. Doc ID: \(ref!.documentID)")
            }
        }
    }
    
    
    ///
    //MARK: - cRud
    ///
    
    //MARK: - Down load data for catolog
    func downloadFilteringDict(success: @escaping(DatabaseManager.CategoryDescription) -> Void, failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.searchProduct.rawValue).document(NavigationCases.ProductCases.mainDictionaries.rawValue).getDocument { (documentSnapshot, error) in
            if let error = error {
                failure(error)
            }else{
                guard let data = DatabaseManager.CategoryDescription(dictionary: documentSnapshot!.data()!) else {return}
                success(data)
            }
        }
    }
    
    func downloadProductInfo(success: @escaping([DatabaseManager.ProductInfo]) -> Void, failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.productInfo.rawValue).getDocuments(completion: {
            (querySnapshot, _) in
            let productInfo = querySnapshot!.documents.compactMap{DatabaseManager.ProductInfo(dictionary: $0.data())}
            success(productInfo)
        })
    }
    
    func downloadProductWithStock(success: @escaping([DatabaseManager.ProductInfo]) -> Void, failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.productInfo.rawValue).whereField(NavigationCases.ProductCases.stock.rawValue, isEqualTo: true).getDocuments(completion: {
            (querySnapshot, _) in
            let productInfo = querySnapshot!.documents.compactMap{DatabaseManager.ProductInfo(dictionary: $0.data())}
            success(productInfo)
        })
    }
    
    func downloadByCategory(category: String, success: @escaping(_ productInfo: [DatabaseManager.ProductInfo]) -> Void, failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.productInfo.rawValue).whereField(NavigationCases.ProductCases.productCategory.rawValue, isEqualTo: category).getDocuments(completion: {
            (querySnapshot, error) in
            if let error = error {
                failure(error)
            }else{
                let productInfo = querySnapshot!.documents.compactMap{DatabaseManager.ProductInfo(dictionary: $0.data())}
                success(productInfo)
            }
        })
    }
    
    func downloadBySubCategory(category: String, subCategory: String, success: @escaping([DatabaseManager.ProductInfo]) -> Void, failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.productInfo.rawValue).whereField(NavigationCases.ProductCases.productCategory.rawValue, isEqualTo: category).whereField(NavigationCases.ProductCases.productSubCategory.rawValue, isEqualTo: subCategory).getDocuments(completion: {
            (querySnapshot, error) in
            if let error = error {
                failure(error)
            }else{
                let productInfo = querySnapshot!.documents.compactMap{DatabaseManager.ProductInfo(dictionary: $0.data())}
                success(productInfo)
            }
        })
    }
    
    //MARK: - Fetch employee data
    func fetchEmployeeData(success: @escaping([DatabaseManager.EmployeeDataStruct]) -> Void, failure: @escaping(Error) -> Void) {
        
        db.collection(NavigationCases.FirstCollectionRow.employee.rawValue).getDocuments { (querySnapshot, error) in
            if let error = error {
                failure(error)
            }else{
                let employeeData = querySnapshot!.documents.compactMap{DatabaseManager.EmployeeDataStruct(dictionary: $0.data())}
                success(employeeData)
            }
        }
    }
    
    //MARK: - Fetch employee data
    func fetchDataOfCertainEmployee(uid: String, success: @escaping([DatabaseManager.EmployeeDataStruct]) -> Void, failure: @escaping(Error) -> Void) {
        if uid == "" {
            let error = NetworkManagerError.employeeUIDDoesNotExist
            failure(error)
        }else{
            db.collection(NavigationCases.FirstCollectionRow.employee.rawValue).document(uid).getDocument { (documentSnapshot, _) in
                guard let employeeData = DatabaseManager.EmployeeDataStruct(dictionary: documentSnapshot!.data()!) else {return}
                success([employeeData])
            }
        }
    }
    
    //MARK: - Fetch archive main data
    func fetchArchivedOrders(time: Date, success: @escaping(_ receipts: [DatabaseManager.Order],_ additions: [DatabaseManager.OrderAddition], _ deleted: [DatabaseManager.Order]) -> Void, failure: @escaping(Error) -> Void) {
        //  - first fetch
        db.collection(NavigationCases.FirstCollectionRow.archivedOrder.rawValue).getDocuments {
            (querySnapshot, error) in
            if let error = error {
                failure(error)
            }else{
                let receiptsData = querySnapshot!.documents.compactMap{DatabaseManager.Order(dictionary: $0.data())}
                // - second fetch
                self.db.collection(NavigationCases.FirstCollectionRow.archivedOrderDescription.rawValue).getDocuments {
                    (querySnapshot, error) in
                    if let error = error {
                        failure(error)
                    }else{
                        let additionsData = querySnapshot!.documents.compactMap{DatabaseManager.OrderAddition(dictionary: $0.data())}
                        //third fetch
                        self.db.collection(NavigationCases.FirstCollectionRow.deletedOrder.rawValue).getDocuments { (querySnapshot, error) in
                            if let error = error {
                                failure(error)
                            }else{
                                let deletedData = querySnapshot!.documents.compactMap{DatabaseManager.Order(dictionary: $0.data())}
                                success(receiptsData, additionsData, deletedData)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Fetch archive data for statistics by regular sutomers
    func fetchRegularCustomers(currentDeviceID: String, success: @escaping([DatabaseManager.Order]) -> Void) {
        self.db.collection(NavigationCases.FirstCollectionRow.archivedOrder.rawValue).whereField(NavigationCases.OrderCases.currentDeviceID.rawValue, isEqualTo: currentDeviceID).getDocuments{
            (querySnapshot, _) in
            let reguralCustomersData = querySnapshot!.documents.compactMap{DatabaseManager.Order(dictionary: $0.data())}
            success(reguralCustomersData)
        }
    }
    
    //MARK: - Fetch archive data for statistics by category
    func fetchArchivedOrdersByCategory(success: @escaping(_ bouquets: [DatabaseManager.OrderAddition],_ apiece: [DatabaseManager.OrderAddition], _ gifts: [DatabaseManager.OrderAddition], _ stocks: [DatabaseManager.OrderAddition]) -> Void, failure: @escaping(Error) -> Void) {
        //  - first fetch
        db.collection(NavigationCases.FirstCollectionRow.archivedOrderDescription.rawValue).whereField(NavigationCases.ProductCases.productCategory.rawValue, isEqualTo: NavigationCases.ProductCategoriesCases.bouquet.rawValue).getDocuments { (querySnapshot, _) in
            let bouquetsData = querySnapshot!.documents.compactMap{DatabaseManager.OrderAddition(dictionary: $0.data())}
            //  - second fetch
            self.db.collection(NavigationCases.FirstCollectionRow.archivedOrderDescription.rawValue).whereField(NavigationCases.ProductCases.productCategory.rawValue, isEqualTo: NavigationCases.ProductCategoriesCases.flower.rawValue).getDocuments { (querySnapshot, _) in
                let apieceData = querySnapshot!.documents.compactMap{DatabaseManager.OrderAddition(dictionary: $0.data())}
                //  - third fetch
                self.db.collection(NavigationCases.FirstCollectionRow.archivedOrderDescription.rawValue).whereField(NavigationCases.ProductCases.productCategory.rawValue, isEqualTo: NavigationCases.ProductCategoriesCases.gift.rawValue).getDocuments { (querySnapshot, _) in
                    let giftsData = querySnapshot!.documents.compactMap{DatabaseManager.OrderAddition(dictionary: $0.data())}
                    
                    //  - fourth fetch
                    self.db.collection(NavigationCases.FirstCollectionRow.archivedOrderDescription.rawValue).whereField(NavigationCases.ProductCases.stock.rawValue, isEqualTo: true).getDocuments { (querySnapshot, _) in
                        let stocksData = querySnapshot!.documents.compactMap{DatabaseManager.OrderAddition(dictionary: $0.data())}
                        
                        success(bouquetsData, apieceData, giftsData, stocksData)
                    }
                }
            }
        }
    }
    
    //MARK: - Fetch archive data for statistics by receipts
    func fetchArchivedOrdersByReceipts(overThan: Int, lessThan: Int, success: @escaping(_ bigger: [DatabaseManager.Order], _ smaller: [DatabaseManager.Order]) -> Void, failure: @escaping(Error) -> Void) {
        //  - first fetch
        db.collection(NavigationCases.FirstCollectionRow.archivedOrder.rawValue).whereField(NavigationCases.OrderCases.totalPrice.rawValue, isGreaterThan: overThan).getDocuments {
            (querySnapshot, _) in
            let biggerReceiptsData = querySnapshot!.documents.compactMap{DatabaseManager.Order(dictionary: $0.data())}
            
            // - second fetch
            self.db.collection(NavigationCases.FirstCollectionRow.archivedOrder.rawValue).whereField(NavigationCases.OrderCases.totalPrice.rawValue, isLessThan: lessThan).getDocuments {
                (querySnapshot, _) in
                let smallerReceiptsData = querySnapshot!.documents.compactMap{DatabaseManager.Order(dictionary: $0.data())}
                
                success(biggerReceiptsData, smallerReceiptsData)
            }
        }
    }
    
    //MARK: - Download image by URL
    func downloadImageByURL(url: String, success: @escaping(UIImage) -> Void) {
        if let url = URL(string: url){
            do {
                let data = try Data(contentsOf: url)
                guard let image = UIImage(data: data) else {return}
                success(image)
            }catch let error{
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: - Download order
    func fetchOrders(success: @escaping([DatabaseManager.Order]) -> Void, failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.order.rawValue).getDocuments(completion: {
            (querySnapshot, _) in
            let orders = querySnapshot!.documents.compactMap{DatabaseManager.Order(dictionary: $0.data())}
            success(orders)
        })
    }
    
    //MARK: - Download order addition
    func fetchOrderAdditions(orderRef: String, success: @escaping([DatabaseManager.OrderAddition]) -> Void, failure: @escaping(Error) -> Void) {        
        let docRef = db.collection(NavigationCases.FirstCollectionRow.order.rawValue).document(orderRef)
        docRef.collection(NavigationCases.OrderCases.orderDescription.rawValue).getDocuments(completion: {
            (querySnapshot, _) in
            let addition = querySnapshot!.documents.compactMap{DatabaseManager.OrderAddition(dictionary: $0.data())}
            success(addition)
        })
    }
    
    //MARK: - Download employee's chat
    func fetchEmployeeChat(success: @escaping([DatabaseManager.ChatMessages]) -> Void, failure: @escaping(Error) -> Void) {
        if AuthenticationManager.shared.currentUser?.uid == nil {
            failure(NetworkManagerError.employeeNotSignedIn)
        }else{
            db.collection(NavigationCases.FirstCollectionRow.employeeMessages.rawValue).whereField(NavigationCases.MessagesCases.timeStamp.rawValue, isLessThan: Date()).getDocuments(completion: {
                (querySnapshot, _) in
                let messages = querySnapshot!.documents.compactMap{DatabaseManager.ChatMessages(dictionary: $0.data())}
                success(messages)
            })
        }
    }
    
    ///
    //MARK: - crUd
    ///
    //MARK: - Increase or decrease price for all product in a category
    func increaseDecreasePrice(for category: String, by price: Int, success: @escaping() -> Void, failure: @escaping(Error) -> Void) {
        let path = db.collection(NavigationCases.FirstCollectionRow.productInfo.rawValue).whereField(NavigationCases.ProductCases.productCategory.rawValue, isEqualTo: category)
        path.getDocuments { (querySnapshot, error) in
            if let error = error {
                failure(error)
            }else{
                let products = querySnapshot!.documents.compactMap{DatabaseManager.ProductInfo(dictionary: $0.data())}
                
                for i in products {
                    let ref = self.db.collection(NavigationCases.FirstCollectionRow
                        .productInfo.rawValue).document(i.productName)
                    
                    ref.updateData([NavigationCases.ProductCases.productPrice.rawValue : i.productPrice + price])
                }
                success()
            }
        }
    }
    
    //MARK: - Edit product price
    func editProductPrice(name: String, newPrice: Int) {
        let path = db.collection(NavigationCases.FirstCollectionRow.productInfo.rawValue).document(name)
        path.updateData([NavigationCases.ProductCases.productPrice.rawValue : newPrice])
    }
    
    //MARK: - Edit stock condition
    func editStockCondition(name: String, stock: Bool) {
        let path = db.collection(NavigationCases.FirstCollectionRow.productInfo.rawValue).document(name)
        path.updateData([NavigationCases.ProductCases.stock.rawValue : stock])
    }
    
    //MARK: - Set delivery person
    func editDeliveryMan(orderID: String, deliveryPerson: String) {
        let path = db.collection(NavigationCases.FirstCollectionRow.order.rawValue).document(orderID)
        path.updateData([NavigationCases.OrderCases.deliveryPerson.rawValue : deliveryPerson])
    }
    
    //MARK: - Chat listener
    func updateChat(success: @escaping(DatabaseManager.ChatMessages) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.employeeMessages.rawValue).whereField(NavigationCases.MessagesCases.timeStamp.rawValue, isGreaterThan: Date()).addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {return}
            
            snapshot.documentChanges.forEach { diff in
                if diff.type == .added {
                    guard let newMessage = DatabaseManager.ChatMessages(dictionary: diff.document.data()) else {return}
                    success(newMessage)
                }
            }
        }
    }
    
    //MARK: - Orders listener
    func updateOrders(success: @escaping(DatabaseManager.Order) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.order.rawValue).whereField(NavigationCases.MessagesCases.timeStamp.rawValue, isGreaterThan: Date()).addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {return}
            
            snapshot.documentChanges.forEach { diff in
                if diff.type == .added {
                    guard let newOrder = DatabaseManager.Order(dictionary: diff.document.data()) else {return}
                    success(newOrder)
                }
            }
        }
    }
    
    ///
    //MARK: - cruD
    ///
    
    //MARK: - Delete product from Firebase
    func deleteProduct(name: String){
        db.collection(NavigationCases.FirstCollectionRow.productInfo.rawValue).document(name).delete() { err in
            if let err = err {
                print("Error removing document: \(err.localizedDescription)")
            } else {
                let imageRef = Storage.storage().reference().child("\(NavigationCases.FirstCollectionRow.imageCollection.rawValue)/\(name)")
                imageRef.delete { error in
                    if let error = error {
                        print("error ocured: \(error.localizedDescription)")
                    } else {
                        print("Delete succeed")
                    }
                }
            }
        }
    }
    
    //MARK: - Delete order addition
    func deleteOrderAddition(collection: CollectionReference, batchSize: Int = 100) {
        collection.limit(to: batchSize).getDocuments { (docs, error) in
            let docs = docs,
            batch = collection.firestore.batch()
            
            docs?.documents.forEach { batch.deleteDocument($0.reference) }
            
            batch.commit { _ in
                self.deleteOrderAddition(collection: collection, batchSize: batchSize)
            }
        }
    }
    
    //MARK: - Delete order
    func deleteOrder(dataModel: DatabaseManager.Order, orderID: String) {
        
        var docRef: DocumentReference?
        
        docRef = db.collection(NavigationCases.FirstCollectionRow.order.rawValue).document(orderID)
        docRef?.delete { (error) in
            if let error = error {
                print(error.localizedDescription)
            }else{
                self.db.collection(NavigationCases.FirstCollectionRow.deletedOrder.rawValue).addDocument(data: dataModel.dictionary)
                self.deleteOrderAddition(collection: docRef!.collection(NavigationCases.OrderCases.orderDescription.rawValue))
            }
        }
    }
    
    //MARK: - Delete Employee Data
    func deleteEmployeeData(uid: String, name: String, phone: String, position: String, successed: Int, fails: Int, _ success: @escaping() -> Void, _ failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.employee.rawValue).document(uid).delete { (error) in
            if let error = error{
                failure(error)
            }else{
                let deletedData: [String: Any] = ["uid": uid, "name": name, "phone": phone, "position": position, "success": successed, "failure": fails]
                self.db.collection("deletedEmployees").addDocument(data: deletedData)
                success()
            }
        }
    }
}

//MARK: - Extensions
extension NetworkManager {
    enum NetworkManagerError: Error {
        case employeeNotSignedIn
        case employeeUIDDoesNotExist
    }
}
