//
//  ToDoListManager.swift
//  NewExample
//
//  Created by Parwate, Shardul on 09/12/20.
//  Copyright © 2020 Parwate, Shardul. All rights reserved.
//

import UIKit
import CoreData

protocol ToDoListManagerProtocol: AnyObject {
    var array: [NSManagedObject] { get set }
    var people: [NSManagedObject] { get set }
    func filterContentForSearchText(text searchText: String, category: ToDoList.Category?)
    func fetchCoreDataValues(withPredicate searchText:NSPredicate?)
    func save(nameToSave: String, withPriority priority:String)
}

class ToDoListManager: NSObject, ToDoListManagerProtocol {
    var array: [NSManagedObject] = []
    var people: [NSManagedObject] = []
    
    func filterContentForSearchText(text searchText: String, category: ToDoList.Category?) {

        var fetchedArray = [Task]()

        guard let array = people as? [Task] else { return }
        fetchedArray = array
        if category?.rawValue == "Date" {
            people = fetchedArray.sorted(by: { (initial, next) -> Bool in
                initial.date?.compare(next.date ?? Date.init()) == ComparisonResult.orderedDescending
            })
        } else if category?.rawValue == "Name" {
            people = fetchedArray.sorted(by: { (initial, next) -> Bool in
                guard let name = next.name else { return false }
                return initial.name?.compare(name) == ComparisonResult.orderedAscending
            })
        } else if category?.rawValue == "All" {
            people = fetchedArray
        }
    }
    
    func fetchCoreDataValues(withPredicate searchText:NSPredicate?) {
        
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local

        let dateFrom = calendar.startOfDay(for: Date())
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)

        let fromPredicate = NSPredicate(format: "date >= %@", dateFrom as NSDate)
        let toPredicate = NSPredicate(format: "date < %@", dateTo! as NSDate)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
        
        do {
            if searchText != nil {
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [ fromPredicate, toPredicate, searchText!])
                array = try managedContext.fetch(fetchRequest)
            } else {
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [ fromPredicate, toPredicate])
                people = try managedContext.fetch(fetchRequest) as! [Task]
            }
        } catch let error as NSError {
            print("Could not save \(error), Description: \(error.description), User Info: \(error.userInfo)")
        }
    }
    
    func save(nameToSave: String, withPriority priority:String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: managedContext) else { return }
        
        let name = NSManagedObject(entity: entity, insertInto: managedContext)
        name.setValue(nameToSave, forKeyPath: "name")
        name.setValue(Date.init(), forKeyPath: "date")
        name.setValue(priority, forKeyPath: "priority")
        name.setValue(true, forKeyPath: "complationStatus")
        do {
            try managedContext.save()
            people.append(name as! Task)
        } catch let error as NSError {
            print("Could not save \(error), Description: \(error.description), User Info: \(error.userInfo)")
        }
    }
    
}
