//
//  Model.swift
//  MileWallet
//
//  Created by denn on 28.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import CoreData

public let ContactEntityName = "Contact"

public class Model {
    
    public typealias Token = (NSCoding & NSCopying & NSObjectProtocol)
    
    public static let kDidLoadErrorNotification = Notification.Name("WalletStoreDidLoadError")

    public static let shared = Model()
    
    public var context:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
   
    private init() {
                
        persistentContainer = {
          
            let container = NSPersistentContainer(name: "Model")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
               
                    NotificationCenter.default.post(name: Model.kDidLoadErrorNotification,
                                                    object: error, userInfo: nil)
                }
            })
            return container
        }()
    }
    
    // MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer
}

extension Contact {
    public convenience init() {
        guard let entity = NSEntityDescription.entity(forEntityName: ContactEntityName, in: Model.shared.context) else {
            fatalError("Failed to decode Contact!")
        }
        self.init(entity: entity, insertInto: Model.shared.context)
    }
    
    public static var list:[Contact] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ContactEntityName)

        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]

        request.returnsObjectsAsFaults = false
        do {
            let result = try Model.shared.context.fetch(request)
            return result as! [Contact]
        } catch {
            print("Failed list...")
        }
        return []
    }
    
    public static func contains(_ value: String, for key:String = "name") -> [Contact] {
        return Contact.find(value, for: key, predicate: NSPredicate(format: key+" LIKE[c] %@", value))
    }
    
    public static func find(_ value: String, for key:String) -> [Contact] {
        return Contact.find(value,for: key, predicate: NSPredicate(format: key+" ==[c] %@", value))
    }
    
    public static func find(_ value: String, for key:String , predicate: NSPredicate) -> [Contact] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ContactEntityName)
        request.returnsObjectsAsFaults = false
        
        // Add Sort Descriptor
        let sortDescriptor = NSSortDescriptor(key: key, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        request.predicate = predicate
        
        do {
            let result = try Model.shared.context.fetch(request)
            return result as! [Contact]
        } catch {
            print("Failed list...")
        }
        return []
    }
    
    public func save() throws {
        try Model.shared.context.save()
    }
}
