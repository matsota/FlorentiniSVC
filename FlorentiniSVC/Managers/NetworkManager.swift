//
//  NetworkManager.swift
//  Florentini
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
    func setupProductDescription(name: String, price: Int, description: String, category: String, stock: Bool) {
        
        let imageTemplate = DatabaseManager.ProductInfo(productName: name, productPrice: price, productDescription: description, productCategory: category, stock: stock)
        
        db.collection(NavigationCases.ProductCases.imageCollection.rawValue).document(name).setData(imageTemplate.dictionary)
    }
    
    //MARK: - Setup new product in Firebase
    func setupProduct(image: UIImageView, name: String, price: Int, description: String, category: String, stock: Bool, progressIndicator: UIProgressView) {
        guard AuthenticationManager.shared.uidAdmin == AuthenticationManager.shared.currentUser?.uid else {return}
        
        progressIndicator.isHidden = false
        
        let uploadRef = Storage.storage().reference(withPath: "\(NavigationCases.ProductCases.imageCollection.rawValue)/\(name)")
        
        guard let imageData = image.image?.jpegData(compressionQuality: 0.75) else {return}
        
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpg"
        
        let taskRef = uploadRef.putData(imageData, metadata: uploadMetadata) { (downloadMetadata, error) in
            if let error = error {
                print("Oh no! \(error.localizedDescription)")
                return
            }
            self.setupProductDescription(name: name, price: price, description: description, category: category, stock: stock)
        }
        
        taskRef.observe(.progress){ (snapshot) in
            guard let pctThere = snapshot.progress?.fractionCompleted else {return}
            progressIndicator.progress = Float(pctThere)
        }
        taskRef.observe(.success) {_ in
            progressIndicator.isHidden = true
        }
    }
    
    //MARK: - Archive order
    func archiveOrder(totalPrice: Int64, name: String, adress: String, cellphone: String, feedbackOption: String, mark: String, timeStamp: Date, orderKey: String, deliveryPerson: String){
        
        let data =  DatabaseManager.Order(totalPrice: totalPrice, name: name, adress: adress, cellphone: cellphone, feedbackOption: feedbackOption, mark: mark, timeStamp: timeStamp, orderID: orderKey, deliveryPerson: deliveryPerson)
        
        db.collection(NavigationCases.ArchiveCases.archivedOrders.rawValue).addDocument(data: data.dictionary)
        archiveOrderAddition(orderKey: orderKey)
    }
    
    //MARK: Archive order addition
    func archiveOrderAddition(orderKey: String) {
        var addition = [DatabaseManager.OrderAddition](),
        jsonArray: [[String: Any]] = []
        
        let docRef = db.collection(NavigationCases.OrderCases.order.rawValue).document(orderKey)
        docRef.collection(orderKey).getDocuments(completion: {
            (querySnapshot, _) in
            addition = querySnapshot!.documents.compactMap{DatabaseManager.OrderAddition(dictionary: $0.data())}
            for i in addition {
                jsonArray.append(i.dictionary)
            }
            
            for _ in jsonArray {
                self.db.collection(NavigationCases.ArchiveCases.archivedOrderAdditions.rawValue).addDocument(data: jsonArray.remove(at: 0))
            }
        })
        db.collection(NavigationCases.OrderCases.order.rawValue).document(orderKey).delete()
        deleteOrderAddition(collection: docRef.collection(orderKey))
    }
    
    //MARK: - New chat message
    func newChatMessage(name: String, content: String) {
        let newMessage = DatabaseManager.ChatMessages(name: name, content: content, uid: AuthenticationManager.shared.currentUser!.uid, timeStamp: Date())
        var ref: DocumentReference? = nil
        
        ref = db.collection(NavigationCases.MessagesCases.employeeMessages.rawValue).addDocument(data: newMessage.dictionary) {
            error in
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
    
    //MARK: - Fetch employee data
    func fetchEmployeeData(success: @escaping([DatabaseManager.EmployeeData]) -> Void, failure: @escaping(Error) -> Void) {
        
        db.collection(NavigationCases.MessagesCases.workers.rawValue).getDocuments { (querySnapshot, error) in
            if let error = error {
                failure(error)
            }else{
                let employeeData = querySnapshot!.documents.compactMap{DatabaseManager.EmployeeData(dictionary: $0.data())}
                success(employeeData)
            }
        }
    }
    
    //MARK: - Fetch employee data
    func fetchCertainDataOfEmployee(uid: String, success: @escaping([DatabaseManager.EmployeeData]) -> Void, failure: @escaping(Error) -> Void) {
        if uid == "" {
            let error = NetworkManagerError.employeeUIDDoesNotExist
            failure(error)
        }else{
            db.collection(NavigationCases.MessagesCases.workers.rawValue).document(uid).getDocument { (documentSnapshot, _) in
                guard let employeeData = DatabaseManager.EmployeeData(dictionary: documentSnapshot!.data()!) else {return}
                success([employeeData])
            }
        }
    }
    
    //MARK: - Fetch archive main data
    func fetchArchivedOrders(time: Date, success: @escaping(_ receipts: [DatabaseManager.Order],_ additions: [DatabaseManager.OrderAddition], _ deleted: [DatabaseManager.Order]) -> Void, failure: @escaping(Error) -> Void) {
        //  - first fetch
        db.collection(NavigationCases.ArchiveCases.archivedOrders.rawValue).getDocuments {
            (querySnapshot, error) in
            if let error = error {
                failure(error)
            }else{
                let receiptsData = querySnapshot!.documents.compactMap{DatabaseManager.Order(dictionary: $0.data())}
                // - second fetch
                self.db.collection(NavigationCases.ArchiveCases.archivedOrderAdditions.rawValue).getDocuments {
                    (querySnapshot, error) in
                    if let error = error {
                        failure(error)
                    }else{
                        let additionsData = querySnapshot!.documents.compactMap{DatabaseManager.OrderAddition(dictionary: $0.data())}
                        //third fetch
                        self.db.collection(NavigationCases.ArchiveCases.deletedOrders.rawValue).getDocuments { (querySnapshot, error) in
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
        self.db.collection(NavigationCases.ArchiveCases.archivedOrders.rawValue).whereField(NavigationCases.OrderCases.currentDeviceID.rawValue, isEqualTo: currentDeviceID).getDocuments{
            (querySnapshot, _) in
            let reguralCustomersData = querySnapshot!.documents.compactMap{DatabaseManager.Order(dictionary: $0.data())}
            success(reguralCustomersData)
        }
    }
    
    //MARK: - Fetch archive data for statistics by category
    func fetchArchivedOrdersByCategory(success: @escaping(_ bouquets: [DatabaseManager.OrderAddition],_ apiece: [DatabaseManager.OrderAddition], _ gifts: [DatabaseManager.OrderAddition], _ stocks: [DatabaseManager.OrderAddition]) -> Void, failure: @escaping(Error) -> Void) {
        //  - first fetch
        db.collection(NavigationCases.ArchiveCases.archivedOrderAdditions.rawValue).whereField(NavigationCases.ProductCases.productCategory.rawValue, isEqualTo: NavigationCases.ProductCategoriesCases.bouquet.rawValue).getDocuments { (querySnapshot, _) in
            let bouquetsData = querySnapshot!.documents.compactMap{DatabaseManager.OrderAddition(dictionary: $0.data())}
            //  - second fetch
            self.db.collection(NavigationCases.ArchiveCases.archivedOrderAdditions.rawValue).whereField(NavigationCases.ProductCases.productCategory.rawValue, isEqualTo: NavigationCases.ProductCategoriesCases.apiece.rawValue).getDocuments { (querySnapshot, _) in
                let apieceData = querySnapshot!.documents.compactMap{DatabaseManager.OrderAddition(dictionary: $0.data())}
                //  - third fetch
                self.db.collection(NavigationCases.ArchiveCases.archivedOrderAdditions.rawValue).whereField(NavigationCases.ProductCases.productCategory.rawValue, isEqualTo: NavigationCases.ProductCategoriesCases.gift.rawValue).getDocuments { (querySnapshot, _) in
                    let giftsData = querySnapshot!.documents.compactMap{DatabaseManager.OrderAddition(dictionary: $0.data())}
                    
                    //  - fourth fetch
                    self.db.collection(NavigationCases.ArchiveCases.archivedOrderAdditions.rawValue).whereField(NavigationCases.ProductCases.stock.rawValue, isEqualTo: true).getDocuments { (querySnapshot, _) in
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
        db.collection(NavigationCases.ArchiveCases.archivedOrders.rawValue).whereField(NavigationCases.OrderCases.totalPrice.rawValue, isGreaterThan: overThan).getDocuments {
            (querySnapshot, _) in
            let biggerReceiptsData = querySnapshot!.documents.compactMap{DatabaseManager.Order(dictionary: $0.data())}
            
            // - second fetch
            self.db.collection(NavigationCases.ArchiveCases.archivedOrders.rawValue).whereField(NavigationCases.OrderCases.totalPrice.rawValue, isLessThan: lessThan).getDocuments {
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
        db.collection(NavigationCases.OrderCases.order.rawValue).getDocuments(completion: {
            (querySnapshot, _) in
            let orders = querySnapshot!.documents.compactMap{DatabaseManager.Order(dictionary: $0.data())}
            success(orders)
        })
    }
    
    //MARK: - Download order addition
    func fetchOrderAdditions(key: String, success: @escaping([DatabaseManager.OrderAddition]) -> Void, failure: @escaping(Error) -> Void) {        
        let docRef = db.collection(NavigationCases.OrderCases.order.rawValue).document(key)
        docRef.collection(key).getDocuments(completion: {
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
            db.collection(NavigationCases.MessagesCases.employeeMessages.rawValue).whereField(NavigationCases.MessagesCases.timeStamp.rawValue, isLessThan: Date()).getDocuments(completion: {
                (querySnapshot, _) in
                let messages = querySnapshot!.documents.compactMap{DatabaseManager.ChatMessages(dictionary: $0.data())}
                success(messages)
            })
        }
    }
    
    //MARK: - Download products
    func downloadProducts(success: @escaping([DatabaseManager.ProductInfo]) -> Void, failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.ProductCases.imageCollection.rawValue).getDocuments(completion: {
            (querySnapshot, _) in
            let productInfo = querySnapshot!.documents.compactMap{DatabaseManager.ProductInfo(dictionary: $0.data())}
            success(productInfo)
        })
    }
    
    //MARK: - Download bouquets products
    func downloadBouquets(success: @escaping([DatabaseManager.ProductInfo]) -> Void, failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.ProductCases.imageCollection.rawValue).whereField(NavigationCases.ProductCases.productCategory.rawValue, isEqualTo: NavigationCases.ProductCategoriesCases.bouquet.rawValue).whereField(NavigationCases.ProductCases.stock.rawValue, isEqualTo: false).getDocuments(completion: {
            (querySnapshot, _) in
            let productInfo = querySnapshot!.documents.compactMap{DatabaseManager.ProductInfo(dictionary: $0.data())}
            success(productInfo)
        })
    }
    
    //MARK: - Download apiece products
    func downloadApieces(success: @escaping([DatabaseManager.ProductInfo]) -> Void, failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.ProductCases.imageCollection.rawValue).whereField(NavigationCases.ProductCases.productCategory.rawValue, isEqualTo: NavigationCases.ProductCategoriesCases.apiece.rawValue).whereField(NavigationCases.ProductCases.stock.rawValue, isEqualTo: false).getDocuments(completion: {
            (querySnapshot, _) in
            let productInfo = querySnapshot!.documents.compactMap{DatabaseManager.ProductInfo(dictionary: $0.data())}
            success(productInfo)
        })
    }
    
    //MARK: - Download gift products
    func downloadGifts(success: @escaping([DatabaseManager.ProductInfo]) -> Void, failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.ProductCases.imageCollection.rawValue).whereField(NavigationCases.ProductCases.productCategory.rawValue, isEqualTo: NavigationCases.ProductCategoriesCases.gift.rawValue).whereField(NavigationCases.ProductCases.stock.rawValue, isEqualTo: false).getDocuments(completion: {
            (querySnapshot, _) in
            let productInfo = querySnapshot!.documents.compactMap{DatabaseManager.ProductInfo(dictionary: $0.data())}
            success(productInfo)
        })
    }
    
    //MARK: - Download stock products
    func downloadStocks(success: @escaping([DatabaseManager.ProductInfo]) -> Void, failure: @escaping(Error) -> Void) {
        db.collection(NavigationCases.ProductCases.imageCollection.rawValue).whereField(NavigationCases.ProductCases.stock.rawValue, isEqualTo: true).getDocuments(completion: {
            (querySnapshot, _) in
            let productInfo = querySnapshot!.documents.compactMap{DatabaseManager.ProductInfo(dictionary: $0.data())}
            success(productInfo)
        })
    }
    
    ///
    //MARK: - crUd
    ///
    
    func increaseDecreasePrice(for category: String, by price: Int, success: @escaping() -> Void, failure: @escaping(Error) -> Void) {
        let path = db.collection(NavigationCases.ProductCases.imageCollection.rawValue).whereField(NavigationCases.ProductCases.productCategory.rawValue, isEqualTo: category)
        path.getDocuments { (querySnapshot, error) in
            if let error = error {
                failure(error)
            }else{
                let products = querySnapshot!.documents.compactMap{DatabaseManager.ProductInfo(dictionary: $0.data())}
                
                for i in products {
                    let ref = self.db.collection(NavigationCases.ProductCases.imageCollection.rawValue).document(i.productName)
                    
                    ref.updateData([NavigationCases.ProductCases.productPrice.rawValue : i.productPrice + price])
                }
                success()
            }
        }
    }
    
    //MARK: - Edit product price
    func editProductPrice(name: String, newPrice: Int) {
        let path = db.collection(NavigationCases.ProductCases.imageCollection.rawValue).document(name)
        path.updateData([NavigationCases.ProductCases.productPrice.rawValue : newPrice])
    }
    
    //MARK: - Edit stock condition
    func editStockCondition(name: String, stock: Bool) {
        let path = db.collection(NavigationCases.ProductCases.imageCollection.rawValue).document(name)
        path.updateData([NavigationCases.ProductCases.stock.rawValue : stock])
    }
    
    //MARK: - Set delivery person
    func editDeliveryMan(orderID: String, deliveryPerson: String) {
        let path = db.collection(NavigationCases.OrderCases.order.rawValue).document(orderID)
        path.updateData([NavigationCases.OrderCases.deliveryPerson.rawValue : deliveryPerson])
    }
    
    //MARK: - Chat listener
    func updateChat(success: @escaping(DatabaseManager.ChatMessages) -> Void) {
        db.collection(NavigationCases.MessagesCases.employeeMessages.rawValue).whereField(NavigationCases.MessagesCases.timeStamp.rawValue, isGreaterThan: Date()).addSnapshotListener { (querySnapshot, error) in
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
        db.collection(NavigationCases.OrderCases.order.rawValue).whereField(NavigationCases.MessagesCases.timeStamp.rawValue, isGreaterThan: Date()).addSnapshotListener { (querySnapshot, error) in
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
        db.collection(NavigationCases.ProductCases.imageCollection.rawValue).document(name).delete() { err in
            if let err = err {
                print("Error removing document: \(err.localizedDescription)")
            } else {
                let imageRef = Storage.storage().reference().child("\(NavigationCases.ProductCases.imageCollection.rawValue)/\(name)")
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
    func deleteOrder(totalPrice: Int64, name: String, adress: String, cellphone: String, feedbackOption: String, mark: String, timeStamp: Date, orderKey: String, deliveryPerson: String) {
        db.collection(NavigationCases.OrderCases.order.rawValue).document(orderKey).delete { (error) in
            if let error = error {
                print(error.localizedDescription)
            }else{
                let data =  DatabaseManager.Order(totalPrice: totalPrice, name: name, adress: adress, cellphone: cellphone, feedbackOption: feedbackOption, mark: mark, timeStamp: timeStamp, orderID: orderKey, deliveryPerson: deliveryPerson),
                docRef = self.db.collection(NavigationCases.OrderCases.order.rawValue).document(orderKey)
                
                self.db.collection(NavigationCases.ArchiveCases.deletedOrders.rawValue).addDocument(data: data.dictionary)
                self.deleteOrderAddition(collection: docRef.collection(orderKey))
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
