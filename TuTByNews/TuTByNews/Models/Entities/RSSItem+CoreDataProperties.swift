//
//  RSSItem+CoreDataProperties.swift
//  TuTByNews
//
//  Created by Neestackich on 10/30/20.
//
//

import Foundation
import CoreData


extension RSSItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RSSItem> {
        return NSFetchRequest<RSSItem>(entityName: "RSSItem")
    }

    @NSManaged public var itemTitle: String?
    @NSManaged public var itemDescription: String?
    @NSManaged public var itemPubDate: String?
    @NSManaged public var titleImage: Data?
    @NSManaged public var imageUrl: String?

}

extension RSSItem : Identifiable {

}
