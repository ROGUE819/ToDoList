//
//  ToDoList.swift
//  NewExample
//
//  Created by Parwate, Shardul on 09/12/20.
//  Copyright © 2020 Parwate, Shardul. All rights reserved.
//

import Foundation

struct ToDoList: Decodable {
    let name: String
    let category: Category
    let isCompleted: Bool
    
    enum Category: Decodable {
        case all
        case name
        case date
    }

}

extension ToDoList.Category: CaseIterable { }

extension ToDoList.Category: RawRepresentable {
    typealias RawValue = String
  
    init?(rawValue: RawValue) {
        switch rawValue {
        case "All": self = .all
        case "Name": self = .name
        case "Date": self = .date
        default: return nil
        }
    }
  
    var rawValue: RawValue {
        switch self {
        case .all: return "All"
        case .name: return "Name"
        case .date: return "Date"
        }
    }
}
