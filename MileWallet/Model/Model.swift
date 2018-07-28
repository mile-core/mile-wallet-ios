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
    
    public static func contains(_ name: String ) -> [Contact] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ContactEntityName)
        request.returnsObjectsAsFaults = false
        
        // Add Sort Descriptor
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        // Add Predicate
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", name)
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


//public class Contact: NSManagedObject, Decodable {
//    @NSManaged var name: String
//    @NSManaged var photo: Data
//    @NSManaged var publicKey: String
//    @NSManaged var createdAt: Date
//
//    enum CodingKeys: String, CodingKey {
//        case name
//        case photo
//        case publicKey
//        case createdAt
//    }
//
//    public required convenience init(from decoder: Decoder) throws {
//
//        guard let entity = NSEntityDescription.entity(forEntityName: ContactEntityName,
//                                                      in: Model.shared.context) else {
//                fatalError("Failed to decode Person!")
//        }
//
//        self.init(entity: entity, insertInto: nil)
//
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        name = try values.decode(String.self, forKey: .name)
//        photo = try values.decode(Data.self, forKey: .photo)
//        publicKey = try values.decode(String.self, forKey: .publicKey)
//        createdAt = try values.decode(Date.self, forKey: .createdAt)
//    }
//}
//
//extension Contact: Encodable {
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(name, forKey: .name)
//        try container.encode(photo, forKey: .photo)
//        try container.encode(publicKey, forKey: .publicKey)
//        try container.encode(createdAt, forKey: .createdAt)
//    }
//}
//
