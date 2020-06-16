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
    static let shared = NetworkManager()
    let db = Firestore.firestore()
}




///
//MARK: - Crud
///
extension NetworkManager {
    
    //MARK: - For ORDERS
    func archiveOrder(dataModel: DatabaseManager.Order, orderKey: String){
        db.collection(NavigationCases.FirstCollectionRow.archivedOrder.rawValue).addDocument(data: dataModel.dictionary)
        archiveOrderAddition(orderID: orderKey)
    }
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
    
    //MARK: - For PRODUCTS 
    func uploadProductDescriptionToBackEnd(name: String, price: Int, description: String, category: String, subCategory: String, stock: Bool, searchArray: [String],
                                           success: @escaping(String) -> Void) {
        let ref = db.collection(NavigationCases.FirstCollectionRow.productInfo.rawValue).document(),
        dataModel = DatabaseManager.ProductInfo(productName: name,
                                                productPrice: price,
                                                productDescription: description,
                                                productCategory: category,
                                                productSubCategory: subCategory,
                                                stock: stock,
                                                productID: ref.documentID,
                                                searchArray: searchArray,
                                                voteCount: 0,
                                                voteAmount: 0)
        
        ref.setData(dataModel.dictionary)
        success(ref.documentID)
    }
    
    func uploadProductToBackEnd(image: UIImageView, productID: String, progressIndicator: UIProgressView,
                                failure: @escaping(Error) -> Void) {
        progressIndicator.isHidden = false
        guard AuthenticationManager.shared.uidAdmin == AuthenticationManager.shared.currentUser?.uid,
            let imageData = image.image?.jpegData(compressionQuality: 0.75) else {return}
        
        let uploadRef = Storage.storage().reference(withPath: "\(NavigationCases.FirstCollectionRow.productImages.rawValue)/\(productID)"),
        uploadMetadata = StorageMetadata.init()
        
        uploadMetadata.contentType = "image/jpg"
        
        let taskRef = uploadRef.putData(imageData, metadata: uploadMetadata) { (_, error) in
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
                progressIndicator.isHidden = true
            }else{
                progressIndicator.isHidden = true
            }
        }
        
    }
    
    //MARK: - For EMPLOYEE & EMPLOYER
    func createNewEmpoyee(dataModel: DatabaseManager.EmployeeDataStruct, uid: String) {
        db.collection(NavigationCases.FirstCollectionRow.employee.rawValue)
            .document(uid)
            .setData(dataModel.dictionary)
    }
    func newChatMessage(name: String, content: String, position: String) {
        let newMessage = DatabaseManager.ChatMessages(name: name,
                                                      content: content,
                                                      position: position,
                                                      uid: AuthenticationManager.shared.currentUser!.uid,
                                                      timeStamp: Date())
        var ref: DocumentReference? = nil
        
        ref = db.collection(NavigationCases.FirstCollectionRow.employeeMessages.rawValue).addDocument(data: newMessage.dictionary) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }else{
                print("It's ok. Doc ID: \(ref!.documentID)")
            }
        }
    }
    
}



///
//MARK: - cRud
///
extension NetworkManager {
    
    //MARK: - For ORDERS
    func downloadOrders(success: @escaping([DatabaseManager.Order]) -> Void,
                        failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.order.rawValue)
            .getDocuments(completion: {
                (querySnapshot, _) in
                let orders = querySnapshot!.documents.compactMap{DatabaseManager.Order(dictionary: $0.data())}
                success(orders)
            })
    }
    
    func downloadOrderAdditions(orderRef: String, success: @escaping([DatabaseManager.OrderAddition]) -> Void,
                                failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.order.rawValue)
            .document(orderRef)
            .collection(NavigationCases.OrderCases.orderDescription.rawValue).getDocuments(completion: {
                (querySnapshot, _) in
                let addition = querySnapshot!.documents.compactMap{DatabaseManager.OrderAddition(dictionary: $0.data())}
                success(addition)
            })
    }
    
    //MARK: - For PRODUCTS
    func downloadProducts(success: @escaping([DatabaseManager.ProductInfo]) -> Void,
                          failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.productInfo.rawValue)
            .getDocuments(completion: {
                (querySnapshot, _) in
                let productInfo = querySnapshot!.documents.compactMap{DatabaseManager.ProductInfo(dictionary: $0.data())}
                success(productInfo)
            })
    }
    func downloadProductsWithStock(success: @escaping([DatabaseManager.ProductInfo]) -> Void,
                                   failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.productInfo.rawValue)
            .whereField(NavigationCases.ProductCases.stock.rawValue, isEqualTo: true)
            .getDocuments(completion: {
                (querySnapshot, _) in
                let productInfo = querySnapshot!.documents.compactMap{DatabaseManager.ProductInfo(dictionary: $0.data())}
                success(productInfo)
            })
    }
    func downloadProductsByCategory(category: String,
                                    success: @escaping([DatabaseManager.ProductInfo]) -> Void,
                                    failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.productInfo.rawValue)
            .whereField(NavigationCases.ProductCases.productCategory.rawValue, isEqualTo: category)
            .getDocuments(completion: {
                (querySnapshot, error) in
                if let error = error {
                    failure(error)
                }else{
                    let productInfo = querySnapshot!.documents.compactMap{DatabaseManager.ProductInfo(dictionary: $0.data())}
                    success(productInfo)
                }
            })
    }
    func downloadProductsBySubCategory(subCategory: String,
                                       success: @escaping([DatabaseManager.ProductInfo]) -> Void,
                                       failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.productInfo.rawValue)
            .whereField(NavigationCases.ProductCases.productSubCategory.rawValue, isEqualTo: subCategory)
            .getDocuments(completion: {
                (querySnapshot, error) in
                if let error = error {
                    failure(error)
                }else{
                    let productInfo = querySnapshot!.documents.compactMap{DatabaseManager.ProductInfo(dictionary: $0.data())}
                    success(productInfo)
                }
            })
    }
    func downloadCertainProduct(id: String,
                                success: @escaping(DatabaseManager.ProductInfo) -> Void,
                                failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.productInfo.rawValue)
            .whereField(NavigationCases.ProductCases.productID.rawValue, isEqualTo: id)
            .getDocuments(completion: { (querySnapshot, error)in
                if let error = error {
                    failure(error)
                }else{
                    if let productInfo = querySnapshot!.documents.compactMap({DatabaseManager.ProductInfo(dictionary: $0.data())}).first {
                        success(productInfo)
                    }else{
                        failure(NetworkManagerError.productUIDDoesNotExist)
                    }
                }
            })
    }
    func downloadCategoriesDict(success: @escaping(DatabaseManager.CategoriesDataStruct) -> Void,
                                failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.searchProduct.rawValue)
            .document(NavigationCases.ProductCases.productCategory.rawValue)
            .getDocument { (documentSnapshot, error) in
                if let error = error {
                    failure(error)
                }else{
                    guard let data = DatabaseManager.CategoriesDataStruct(dictionary: documentSnapshot!.data()!) else {return}
                    success(data)
                }
        }
    }
    func downloadSubCategoriesDict(success: @escaping(DatabaseManager.SubCategoriesDataStruct) -> Void,
                                   failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.searchProduct.rawValue)
            .document(NavigationCases.ProductCases.productSubCategory.rawValue)
            .getDocument { (documentSnapshot, error) in
                if let error = error {
                    failure(error)
                }else{
                    guard let data = DatabaseManager.SubCategoriesDataStruct(dictionary: documentSnapshot!.data()!) else {return}
                    success(data)
                }
        }
    }
    
    //MARK: - For EMPLOYEE & EMPLOYER
    func downloadEmployeeData(success: @escaping([DatabaseManager.EmployeeDataStruct]) -> Void,
                              failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.employee.rawValue)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    failure(error)
                }else{
                    let employeeData = querySnapshot!.documents.compactMap{DatabaseManager.EmployeeDataStruct(dictionary: $0.data())}
                    success(employeeData)
                }
        }
    }
    func downloadDataOfCertainEmployee(uid: String,
                                       success: @escaping([DatabaseManager.EmployeeDataStruct]) -> Void,
                                       failure: @escaping(Error) -> Void) {
        if uid == "" {
            let error = NetworkManagerError.employeeUIDDoesNotExist
            failure(error)
        }else{
            db.collection(NavigationCases.FirstCollectionRow.employee.rawValue)
                .document(uid)
                .getDocument { (documentSnapshot, _) in
                    guard let employeeData = DatabaseManager.EmployeeDataStruct(dictionary: documentSnapshot!.data()!) else {return}
                    success([employeeData])
            }
        }
    }
    func downloadEmployeeChat(success: @escaping([DatabaseManager.ChatMessages]) -> Void,
                              failure: @escaping(Error) -> Void) {
        if AuthenticationManager.shared.currentUser?.uid == nil {
            failure(NetworkManagerError.employeeNotSignedIn)
        }else{
            db.collection(NavigationCases.FirstCollectionRow.employeeMessages.rawValue)
                .whereField(NavigationCases.MessagesCases.timeStamp.rawValue, isLessThan: Date())
                .getDocuments(completion: {
                    (querySnapshot, _) in
                    let messages = querySnapshot!.documents.compactMap{DatabaseManager.ChatMessages(dictionary: $0.data())}
                    success(messages)
                })
        }
    }
    
    //MARK: - For STATISTICS
    func downloadArchivedOrders(time: Date,
                                success: @escaping(_ receipts: [DatabaseManager.Order], _ additions: [DatabaseManager.OrderAddition],
        _ deleted: [DatabaseManager.Order]) -> Void,
                                failure: @escaping(Error) -> Void) {
        //  - first fetch
        db.collection(NavigationCases.FirstCollectionRow.archivedOrder.rawValue)
            .getDocuments {
                (querySnapshot, error) in
                if let error = error {
                    failure(error)
                }else{
                    let receiptsData = querySnapshot!.documents.compactMap{DatabaseManager.Order(dictionary: $0.data())}
                    // - second fetch
                    self.db.collection(NavigationCases.FirstCollectionRow.archivedOrderDescription.rawValue)
                        .getDocuments {
                            (querySnapshot, error) in
                            if let error = error {
                                failure(error)
                            }else{
                                let additionsData = querySnapshot!.documents.compactMap{DatabaseManager.OrderAddition(dictionary: $0.data())}
                                //third fetch
                                self.db.collection(NavigationCases.FirstCollectionRow.deletedOrder.rawValue)
                                    .getDocuments { (querySnapshot, error) in
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
    func downloadArchivedOrdersByCategory(success: @escaping(_ bouquets: [DatabaseManager.OrderAddition], _ apiece: [DatabaseManager.OrderAddition],
        _ gifts: [DatabaseManager.OrderAddition], _ stocks: [DatabaseManager.OrderAddition]) -> Void,
                                          failure: @escaping(Error) -> Void) {
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
    func downloadArchivedOrdersByReceipts(overThan: Int, lessThan: Int,
                                          success: @escaping(_ bigger: [DatabaseManager.Order],_ smaller: [DatabaseManager.Order]) -> Void,
                                          failure: @escaping(Error) -> Void) {
        //  - first fetch
        db.collection(NavigationCases.FirstCollectionRow.archivedOrder.rawValue)
            .whereField(NavigationCases.OrderCases.totalPrice.rawValue, isGreaterThan: overThan)
            .getDocuments {
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
    
    //MARK: - For PRODUCT CUSTOMIZE
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
    
}

///
//MARK: - crUd
///
extension NetworkManager {
    
    //MARK: - For ORDERS
    func orderListener(success: @escaping(DatabaseManager.Order) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.order.rawValue)
            .whereField(NavigationCases.MessagesCases.timeStamp.rawValue, isGreaterThan: Date())
            .addSnapshotListener { (querySnapshot, error) in
                guard let snapshot = querySnapshot else {return}
                
                snapshot.documentChanges.forEach { diff in
                    if diff.type == .added {
                        guard let newOrder = DatabaseManager.Order(dictionary: diff.document.data()) else {return}
                        success(newOrder)
                    }
                }
        }
    }
    
    //MARK: - For PRODUCTS
    func updateAllPricesByCategory(for category: String, by price: Int, success: @escaping() -> Void, failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.productInfo.rawValue)
            .whereField(NavigationCases.ProductCases.productCategory.rawValue, isEqualTo: category)
            .getDocuments { (querySnapshot, error) in
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
    func updatePriceOfCertainProduct(name: String, newPrice: Int) {
        db.collection(NavigationCases.FirstCollectionRow.productInfo.rawValue)
            .document(name)
            .updateData([NavigationCases.ProductCases.productPrice.rawValue : newPrice])
    }
    func updateStockCondition(name: String, stock: Bool) {
        db.collection(NavigationCases.FirstCollectionRow.productInfo.rawValue)
            .document(name)
            .updateData([NavigationCases.ProductCases.stock.rawValue : stock])
    }
    func updateDeliveryPerson(orderID: String, deliveryPerson: String) {
        db.collection(NavigationCases.FirstCollectionRow.order.rawValue)
            .document(orderID)
            .updateData([NavigationCases.OrderCases.deliveryPerson.rawValue : deliveryPerson])
    }
    func updateSubCategory(category: String, subCategory: [String]) {
        db.collection(NavigationCases.FirstCollectionRow.searchProduct.rawValue)
            .document(NavigationCases.ProductCases.productSubCategory.rawValue)
            .updateData([category : subCategory], completion: nil)
    }
    func updateAllProductProperties(docID: String, name: String, price: Int, category:String,
                                    subCategory: String, description: String, searchArray: [String], stock: Bool,
                                    success: @escaping() -> Void,
                                    failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.productInfo.rawValue)
            .document(docID)
            .updateData([NavigationCases.ProductCases.productName.rawValue : name,
            NavigationCases.ProductCases.productPrice.rawValue : price,
            NavigationCases.ProductCases.productCategory.rawValue : category,
            NavigationCases.ProductCases.productSubCategory.rawValue : subCategory,
            NavigationCases.ProductCases.productDescription.rawValue : description,
            NavigationCases.ProductCases.searchArray.rawValue : searchArray,
            NavigationCases.ProductCases.stock.rawValue : stock]) { (error) in
                if let error = error {
                    failure(error)
                }else{
                    success()
                }
        }
    }
    
    //MARK: - For EMPLOYEE & EMPLOYER
    func chatListener(success: @escaping(DatabaseManager.ChatMessages) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.employeeMessages.rawValue)
            .whereField(NavigationCases.MessagesCases.timeStamp.rawValue, isGreaterThan: Date())
            .addSnapshotListener { (querySnapshot, error) in
                guard let snapshot = querySnapshot else {return}
                
                snapshot.documentChanges.forEach { diff in
                    if diff.type == .added {
                        guard let newMessage = DatabaseManager.ChatMessages(dictionary: diff.document.data()) else {return}
                        success(newMessage)
                    }
                }
        }
    }
    
}

///
//MARK: - cruD
///
extension NetworkManager {
    
    //MARK: - For ORDERS
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
    func deleteOrderAddition(collection: CollectionReference, batchSize: Int = 100) {
        collection.limit(to: batchSize)
            .getDocuments { (docs, error) in
                let docs = docs,
                batch = collection.firestore.batch()
                
                docs?.documents.forEach { batch.deleteDocument($0.reference) }
                
                batch.commit { _ in
                    self.deleteOrderAddition(collection: collection, batchSize: batchSize)
                }
        }
    }
    
    //MARK: - For PRODUCTS
    func deleteProduct(productID: String, name: String){
        db.collection(NavigationCases.FirstCollectionRow.productInfo.rawValue)
            .document(productID)
            .delete() { err in
                if let err = err {
                    print("Error removing document: \(err.localizedDescription)")
                } else {
                    let imageRef = Storage.storage().reference().child("\(NavigationCases.FirstCollectionRow.productImages.rawValue)/\(name)")
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
    
    //MARK: - For EMPLOYEE & EMPLOYER
    func deleteEmployeeData(uid: String, name: String, phone: String, position: String, successed: Int, fails: Int,
                            _ success: @escaping() -> Void,
                            _ failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.FirstCollectionRow.employee.rawValue)
            .document(uid)
            .delete { (error) in
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

//MARK: - Error Enum
extension NetworkManager {
    
    enum NetworkManagerError: Error {
        case employeeNotSignedIn
        case employeeUIDDoesNotExist
        case productUIDDoesNotExist
    }
    
}
