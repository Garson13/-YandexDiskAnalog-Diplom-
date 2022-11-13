//
//  AllFiles+CoreDataProperties.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 08.11.2022.
//
//

import Foundation
import CoreData


extension AllFiles {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AllFiles> {
        return NSFetchRequest<AllFiles>(entityName: "AllFiles")
    }

    @NSManaged public var name: String
    @NSManaged public var mime_type: String
    @NSManaged public var media_type: String
    @NSManaged public var type: String
    @NSManaged public var path: String
    @NSManaged public var size: Int64
    @NSManaged public var created: String
    @NSManaged public var preview: String?
    
}

extension AllFiles : Identifiable {

}
