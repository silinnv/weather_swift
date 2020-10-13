//
//  CoreDataStack.swift
//  wether_001
//
//  Created by Fredia Wiley on 9/29/20.
//  Copyright © 2020 Nikita Silin. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    private let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error) \(error.userInfo)")
            }
        }
        return container
    }()
    
    lazy var managedContex: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    func saveContext() {
        guard managedContex.hasChanges else {
            return
        }
        
        do {
            try managedContex.save()
        } catch let error as NSError {
            print("Unresolved error \(error) \(error.userInfo)")
        }
    }
}
