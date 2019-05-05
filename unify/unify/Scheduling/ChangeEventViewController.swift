//
//  ChangeEventViewController.swift
//  unify
//
//  Created by David Do on 4/23/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit
import Firebase

class ChangeEventViewController: UIViewController {
    /* Initialized Variables */
    var contentHolder: EventContent! = nil
    let formatter = DateFormatter()
    var ref: DatabaseReference!
    
    /* Initialized textfields */
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var start: UITextField!
    @IBOutlet weak var end: UITextField!
    
    /* Initialized Action Buttons */
    @IBAction func saveButton(_ sender: Any) {
        /* Checks for completed conditions: completed textfields
         and correct formts for name, location, date, start, and end times */
        if ((name.text?.isEmpty)! || (location.text?.isEmpty)! ||
            (date.text?.isEmpty)! || (start.text?.isEmpty)! || (end.text?.isEmpty)!) {
            alertErrorHelper(text: "ERROR: Incompleted information. Please complete all five textfields.")
        } else if (formatChecker(condition: "MM/dd/yyyy", text: date.text!) == false
            || date.text!.count != 10) {
            alertErrorHelper(text: "ERROR: Incorrect format for Date. (MM/DD/YYYY)")
        } else if (formatChecker(condition: "HH:mma", text: start.text!) == false
            || start.text!.count != 7) {
            alertErrorHelper(text: "ERROR: Incorrect format for Start Time. (EX: 01:30am)")
        } else if (formatChecker(condition: "HH:mma", text: end.text!) == false
            || end.text!.count != 7) {
            alertErrorHelper(text: "ERROR: Incorrect format for End Time. (EX: 01:30pm)")
        } else {
            // Readys the textfields for usage
            let n = name.text!
            let l = location.text!
            let d = contentHolder.date!
            let s = start.text!
            let e = end.text!
            
            // Update data onto Firebase
            self.ref.child("schedule").child(contentHolder.courseRef!).child(d)
                    .child(contentHolder.parentRef!).setValue([
                "date" : d,
                "location" : l,
                "name" : n,
                "start" : s,
                "end" : e
                ])
        }
        resetAndBack()
    }
    
    /* Deletes the event using the parentIDRef*/
    @IBAction func deleteButton(_ sender: Any) {
        self.ref.child("schedule").child(contentHolder.courseRef!).child(contentHolder.date!)
            .child(contentHolder.parentRef!).removeValue()
        resetAndBack()
    }
    
    /* Does nothing, no changes are made. Pops back to previous view controller */
    @IBAction func cancelButton(_ sender: Any) {
        resetAndBack()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ref = Database.database().reference()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.view.backgroundColor = JDColor.appSubviewBackground.color
    }
    
    /* Helper functioin to setup the variables and textfields */
    func setup() {
        // Error checking. Otherwise, adapt changes from variables to textfields */
        if (contentHolder == nil) {
            alertErrorHelper(text: "ERROR: ContentHolder is nil")
        } else {
            /* Formats the date to be displayed onto the textfield*/
            var str = contentHolder.date!
            var index = str.index(str.startIndex, offsetBy: 2)
            str.insert(contentsOf: "/", at: index)
            index = str.index(str.startIndex, offsetBy: 5)
            str.insert(contentsOf: "/", at: index)
            
            /* Sets the event's data onto the textfields for users to make adjustments */
            name.text = contentHolder.name
            location.text = contentHolder.location
            date.text = str
            start.text = contentHolder.start
            end.text = contentHolder.end
            
            /* Disable date textfield as changes are meant to only adjust time/location/name */
            date.isUserInteractionEnabled = false
            print("Debugging - ChangeEventVC - ClassRef:", contentHolder.courseRef!)
            print("Debugging - ChangeEventVC - ParentIDRef:", contentHolder.parentRef!)
        }
    }
    
    /* Helper function reset variables to dismiss the VC */
    func resetAndBack() {
        // Resets the variables back to ni
        contentHolder = nil
        
        // Dismisses the ChangeEventVC back to CalendarVC
        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    /* Helper function to check formats of dates or times */
    func formatChecker(condition: String, text: String) -> Bool {
        formatter.dateFormat = condition
        if formatter.date(from: text) != nil {
            return true
        } else {
            return false
        }
    }
    
    /* Helper function to send errors */
    func alertErrorHelper(text: String) {
        let alertController = UIAlertController(title: "Error", message:
            text, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
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
