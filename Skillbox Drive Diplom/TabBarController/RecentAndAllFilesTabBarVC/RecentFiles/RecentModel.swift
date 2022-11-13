//
//  RecentModel.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 08.08.2022.
//

import Foundation
import CoreData


struct ItemList: Decodable, Hashable {
    var name: String
    var preview: String?
    var created: String
    var modified: String
    var media_type: String?
    var path: String
    var type: String
    var mime_type: String?
    var size: Int64?
}

struct MainList: Decodable {
    var items: [ItemList]
    var limit: Int64
}

class RecentCoreDataModel {
    
    let container = NSPersistentContainer(name: "Skillbox_Drive_Diplom")
    
    lazy var resultController: NSFetchedResultsController <Recent> = {
        let request = Recent.fetchRequest()
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
