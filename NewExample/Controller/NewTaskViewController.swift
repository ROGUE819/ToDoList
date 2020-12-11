//
//  NewTaskViewController.swift
//  NewExample
//
//  Created by Parwate, Shardul on 11/12/20.
//  Copyright © 2020 Parwate, Shardul. All rights reserved.
//

import UIKit

class NewTaskViewController: UIViewController, UITextFieldDelegate {
    var priority: String = ""

//    weak var delegate: ViewController?
    
    @IBOutlet weak var prioritySegmentOutlet: UISegmentedControl!
    let toDoListProtocol = ToDoListManager()
//    let viewController = ViewController()
    
    @IBOutlet weak var newTaskTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        priority = "High"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveTask(_ sender: UIBarButtonItem) {
        if newTaskTextField.text != nil {
            toDoListProtocol.save(nameToSave: newTaskTextField.text!, withPriority: priority)
            self.navigationController?.popViewController(animated: true)
           
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        let notificationNme = NSNotification.Name("NotificationIdf")
        NotificationCenter.default.post(name: notificationNme, object: nil)
    }
    
    @IBAction func segmentSwitch(_ sender: UISegmentedControl) {        
        if sender.selectedSegmentIndex == 0  {
            priority = "High"
        } else if sender.selectedSegmentIndex == 1 {
            priority = "Medium"
        } else if sender.selectedSegmentIndex == 2 {
            priority = "Low"
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
          if textField == self.newTaskTextField {
              //if you dont want the users to se the keyboard type:

              textField.endEditing(true)
          }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
