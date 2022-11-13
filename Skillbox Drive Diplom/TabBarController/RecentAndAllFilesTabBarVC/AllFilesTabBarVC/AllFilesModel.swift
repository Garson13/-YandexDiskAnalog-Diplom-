//
//  AllFilesModel.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 05.11.2022.
//

import Foundation
import CoreData

struct AllFilesModel: Decodable {
    var _embedded: Embedded
    var name: String
    var created: String
    var public_url: String?
    var path: String
    var type: String
}

struct Embedded: Decodable {
    var path: String
    var items: [ItemList]
}

class AllFilesCoreDataModel {
    
    let container = NSPersistentContainer(name: "Skillbox_Drive_Diplom")
    
    lazy var resultController: NSFetchedResultsController <AllFiles> = {
        let request = AllFiles.fetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: false)
        request.sortDescriptors = [sort]
        let resultController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return resultController
    }()
    
    init() {
        container.loadPersistentStores { persistentStoreDescription, error in
            if let error = error {
                print("Error: \(error)")
            } else {
                do {
                    try self.resultController.performFetch()
                } catch {
                    print(error)
                }
            }
        }
    }
}
