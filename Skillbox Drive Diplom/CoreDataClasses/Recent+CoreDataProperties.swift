//
//  Recent+CoreDataProperties.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 11.08.2022.
//
//

import Foundation
import CoreData


extension Recent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recent> {
        return NSFetchRequest<Recent>(entityName: "Recent")
    }
    
    @NSManaged public var media_type: String
    @NSManaged public var mime_type: String
    @NSManaged public var name: String
    @NSManaged public var preview: String
    @NSManaged public var path: String
    @NSManaged public var created: String
    @NSManaged public var type: String
    @NSManaged public var size: Int64

}

extension Recent : Identifiable {

}
