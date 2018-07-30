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
    
    public static let shared = Model()
    public let context:NSManagedObjectContext
    
    private init() {
        context = Model.appDelegate.persistentContainer.viewContext
    }
    
    private static let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
    
    public static func find(_ value: String, for key:String = "name") -> [Contact] {
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
