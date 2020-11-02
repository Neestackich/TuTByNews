//
//  DatabaseManager.swift
//  TuTByNews
//
//  Created by Neestackich on 10/30/20.
//

import UIKit
import CoreData

class DatabaseManager: NSObject, NSFetchedResultsControllerDelegate {
    
    
    // MARK: -Properties
    
    static let shared = DatabaseManager()
    private var appDelegate: AppDelegate!
    private var context: NSManagedObjectContext!
    private(set) var fetchetResultController: NSFetchedResultsController<RSSItem>!
    
    
    // MARK: -Methods
    
    override init() {
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        context = self.appDelegate.persistentContainer.viewContext
    }
    
    func addItem(itemTitle: String, itemDescription: String, itemPubDate: String, imageUrl: String) {
        let entity = NSEntityDescription.entity(forEntityName: "RSSItem", in: context)
        
        if let entity = entity {
            let rssItem = NSManagedObject(entity: entity, insertInto: context) as! RSSItem
            rssItem.itemTitle = itemTitle
            rssItem.itemDescription = itemDescription
            rssItem.imageUrl = imageUrl
            rssItem.tagged = false
            
            let cleanedString = itemPubDate.replacingOccurrences(of: "\n\t\t", with: "")
            rssItem.itemPubDate = cleanedString

            do {
                try context.save()
                print("added")
            } catch {
                print("Save error")
            }
        }
    }
    
    func getItems() -> [RSSItem]? {
        print(fetchetResultController.fetchedObjects?.count)
        
        return fetchetResultController.fetchedObjects
    }
    
    func getFetchetResultController() {
        if fetchetResultController == nil {
            let sortByPubDate = NSSortDescriptor(key: "itemTitle", ascending: true)
            let fetchRequest: NSFetchRequest<RSSItem> = RSSItem.fetchRequest()
            fetchRequest.sortDescriptors = [sortByPubDate]
            fetchRequest.fetchBatchSize = 20
            
            fetchetResultController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: "itemTitle",
                cacheName: nil)
            fetchetResultController?.delegate = self
        }
        
        do {
            try fetchetResultController?.performFetch()
        } catch {
            print("Fetch error")
        }
        
        isDatabaseEmpty()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dataLoaded"), object: nil)
    }
    
    func cleanUpDatabase() {
        //работает через раз
//        if !isDatabaseEmpty() {
//            if let items = getItems() {
//                for item in (fetchetResultController?.fetchedObjects)! {
//                    do {
//                        try context.delete(item)
//
//                        saveContext()
//                    } catch {
//                        print("delete error")
//                    }
//                }
//
//                print("deleted")
//            }
//
//            fetchetResultController = nil
//        }
        
        let fetchRequest: NSFetchRequest<RSSItem> = RSSItem.fetchRequest()
        var items: [RSSItem] = []
        
        do {
            items = try context.fetch(fetchRequest)
        } catch {
            print("Fetch error")
        }
        
        do {
            for item in items {
                try context.delete(item)
            }
            
            saveContext()  
        } catch {
            print("Delete error")
        }
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error")
            }
        }
    }
    
    private func isDatabaseEmpty() -> Bool {
        if fetchetResultController == nil {
            getFetchetResultController()
        }
        
        if fetchetResultController.fetchedObjects?.count == 0 {
            print("EMPTY")
            
            return true
        } else {
            print("ELEMENTS QUANTITY: \(String(describing: fetchetResultController.fetchedObjects?.count))")
            
            return false
        }
    }
}
