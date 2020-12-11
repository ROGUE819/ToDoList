//
//  ViewController.swift
//  NewExample
//
//  Created by Parwate, Shardul on 09/12/20.
//  Copyright © 2020 Parwate, Shardul. All rights reserved.
//

import UIKit
import CoreData

//protocol ViewControllerDelegate {
//    func reloadTableView()
//}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let toDoListProtocol = ToDoListManager()
    let newTaskController = NewTaskViewController()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .white
        
        let notificationNme = NSNotification.Name("NotificationIdf")
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.reloadTableView), name: notificationNme, object: nil)
        super.viewDidLoad()

        configureNavigationBar()

        configureSearchController()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification,
                                       object: nil, queue: .main) { (notification) in
                                        self.handleKeyboard(notification: notification) }
        notificationCenter.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                       object: nil, queue: .main) { (notification) in
                                        self.handleKeyboard(notification: notification) }
        
        toDoListProtocol.fetchCoreDataValues(withPredicate: nil)
    }
    
    func configureNavigationBar () {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "To Do"
//        "\(Date().fullDate)"

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = .white

            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            //navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.barStyle = .default

        } else {
            // Fallback on earlier versions
            navigationController?.navigationBar.barTintColor = .purple
        }
    }
    
    func configureSearchController () {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search Task"
        navigationItem.searchController = searchController

        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = ToDoList.Category.allCases.map { $0.rawValue }
        searchController.searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
          tableView.deselectRow(at: indexPath, animated: true)
        }
        toDoListProtocol.fetchCoreDataValues(withPredicate: nil)
    }

    @IBAction func barButton(_ sender: UIBarButtonItem) {
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isSearchBarEmpty {
            return toDoListProtocol.array.count
        }
        return toDoListProtocol.people.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
        let person: NSManagedObject

        if !isSearchBarEmpty {
            person = toDoListProtocol.array[indexPath.row]
            
        } else {
            person = toDoListProtocol.people[indexPath.row]
        }
        cell.detailTextLabel?.numberOfLines = 2
        cell.textLabel?.text = person.value(forKeyPath: "name") as? String
        let subtitleText = person.value(forKeyPath: "priority") as? String
        
        cell.detailTextLabel?.text = subtitleText
        if subtitleText == "High" || subtitleText == "high"  {
            cell.backgroundColor = UIColor(red: 252/255, green: 92/255, blue: 156/255, alpha: 1)
        } else if subtitleText == "Medium" || subtitleText == "medium" {
            cell.backgroundColor = UIColor(red: 252/255, green: 205/255, blue: 226/255, alpha: 1)
        } else {
            cell.backgroundColor = UIColor(red: 252/255, green: 239/255, blue: 238/255, alpha: 1)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
        let action = swipeCompleteAction(withIndexPath: indexPath)
        let delete = swipeDeleteAction(withIndexPath: indexPath)
        
        return UISwipeActionsConfiguration(actions: [action, delete])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
}

extension ViewController: UISearchResultsUpdating  {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let category = ToDoList.Category(rawValue: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
        toDoListProtocol.filterContentForSearchText(text: searchBar.text!, category: category)
        tableView.reloadData()
    }
}

extension ViewController: UISearchBarDelegate, UISearchDisplayDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            var predicate: NSPredicate = NSPredicate()
            predicate = NSPredicate(format: "name contains[c] '\(searchText)'")

            toDoListProtocol.fetchCoreDataValues(withPredicate: predicate)
        }
        tableView.reloadData()
    }
        
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        toDoListProtocol.fetchCoreDataValues(withPredicate: nil)
        tableView.reloadData()
    }
}

extension ViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewTaskSegue" {
            if let newTaskController = segue.destination as? NewTaskViewController {
                present(newTaskController, animated: true, completion: nil)
            }
        }
    }
    
    func swipeDeleteAction(withIndexPath indexPath: IndexPath) -> UIContextualAction {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completion) in
            let commit = self?.toDoListProtocol.people[indexPath.row]
                  
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            appDelegate.persistentContainer.viewContext.delete(commit!)
            
            self?.toDoListProtocol.people.remove(at: indexPath.row)
            self?.tableView.deleteRows(at: [indexPath], with: .fade)
            appDelegate.saveContext()
            completion(true)
        }
        delete.backgroundColor = UIColor(red: 192/255, green: 53/255, blue: 70/255, alpha: 1)
              
        delete.image = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image { _ in
            UIImage(named: "trash--v1")?.draw(in: CGRect(x: 0, y: 0, width: 30, height: 30))
        }
        return delete
    }
    
    func swipeCompleteAction(withIndexPath indexPath: IndexPath) -> UIContextualAction  {
        var act = toDoListProtocol.people[indexPath.row] as? Task
        let status = act?.complationStatus ?? false ? false : true
        let title: String
        
        if status == true {
            title = "Not Completed"
        } else {
            title = "Completed"
        }
              
        let action = UIContextualAction(style: .normal, title: title) { (action, view, completion) in
                
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                let managedContext = appDelegate.persistentContainer.viewContext
                let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
                let predicate = NSPredicate(format: "(name = %@)", (act?.name)!)
                fetchRequest.predicate = predicate
                do {
                    let result = try managedContext.fetch(fetchRequest)
                    act = result[0] as NSManagedObject as? Task
                    act?.setValue(status, forKey: "complationStatus")
                do {
                    try managedContext.save()
                }catch  let error as NSError {
                    print("\(error)")
                }
            }catch let error as NSError {
                print("\(error)")
            }
            completion(true)
        }
        
        action.backgroundColor = UIColor(red: 44/255, green: 185/255, blue: 120/255, alpha: 1)
        
        return action
    }
    
    @objc func reloadTableView() {
        self.tableView.reloadData()
    }
    
    func handleKeyboard(notification: Notification) {
        guard notification.name == UIResponder.keyboardWillChangeFrameNotification else {
            view.layoutIfNeeded()
            return
        }

        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}
