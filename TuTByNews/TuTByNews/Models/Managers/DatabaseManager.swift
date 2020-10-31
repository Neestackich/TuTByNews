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
    private var fetchetResultController: NSFetchedResultsController<RSSItem>!
    
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
            rssItem.itemPubDate = itemPubDate
            rssItem.imageUrl = imageUrl
            
            let url = URL(string: imageUrl)
            
            if let url = url {
                let imageDownloadTask = URLSession.shared.dataTask(with: url) { [weak rssItem] data, response, error in
                    if let data = data {
                        rssItem?.titleImage = data
                    }
                }
                
                imageDownloadTask.resume()
            }

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
            print("error")
        }
    }
    
    func cleanUpDatabase() {
        if !isDatabaseEmpty() {
            if fetchetResultController == nil {
                getFetchetResultController()
            }
    
            if let items = getItems() {
                for item in items {
                    do {
                        try context.delete(item)
                        
                        saveContext()
                    } catch {
                        print("delete error")
                    }
                }
                
                print("deleted")
            }
            
            fetchetResultController = nil
        }
    }
    
    private func saveContext() {
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
            print("\n\nEMPTY\n\n")
            
            return true
        } else {
            print("\n\nELEMENTS QUANTITY: \(String(describing: fetchetResultController.fetchedObjects?.count))\n\n")
            
            return false
        }
    }
}
