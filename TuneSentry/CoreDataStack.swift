//
//  CoreDataStack.swift
//  TuneSentry
//
//  Created by Chris Garvey on 4/12/17.
//  Copyright © 2017 Chris Garvey. All rights reserved.
//

import Foundation
import CoreData

typealias CoreDataCallComplete = (_ success: Bool) -> Void

class CoreDataStack {
    
    // MARK: Properties
    
    fileprivate let modelName: String
    
    lazy var mainContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    lazy var storeContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: self.modelName)
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    
    // MARK: Initializer
    
    init(modelName: String) {
        self.modelName = modelName
    }
}


// MARK: Internal

extension CoreDataStack {
    
    func saveContext(completion: CoreDataCallComplete) {
        
        guard mainContext.hasChanges else {
            
            completion(true)
            return
        }
        
        do {
            try mainContext.save()
            completion(true)
        } catch _ as NSError {
            completion(false)
        }
    }
}
