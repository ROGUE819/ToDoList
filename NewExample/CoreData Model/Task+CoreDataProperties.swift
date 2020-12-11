//
//  Task+CoreDataProperties.swift
//  NewExample
//
//  Created by Parwate, Shardul on 09/12/20.
//  Copyright © 2020 Parwate, Shardul. All rights reserved.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var complationStatus: Bool
    @NSManaged public var date: Date?
    @NSManaged public var name: String?
    @NSManaged public var priority: String?

}
