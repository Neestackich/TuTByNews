//
//  RSSItem+CoreDataProperties.swift
//  
//
//  Created by Neestackich on 11/2/20.
//
//

import Foundation
import CoreData


extension RSSItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RSSItem> {
        return NSFetchRequest<RSSItem>(entityName: "RSSItem")
    }

    @NSManaged public var imageUrl: String?
    @NSManaged public var itemDescription: String?
    @NSManaged public var itemPubDate: String?
    @NSManaged public var itemTitle: String?
    @NSManaged public var tagged: Bool
    @NSManaged public var titleImage: Data?

}
