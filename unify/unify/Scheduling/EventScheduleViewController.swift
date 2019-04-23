//
//  EventScheduleViewController.swift
//  unify
//
//  Created by David Do on 4/9/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit
import Firebase

class EventScheduleViewController: UIViewController {
    /* Initialized Outlets */
    @IBOutlet weak var eventNameTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var startTF: UITextField!
    @IBOutlet weak var endTF: UITextField!
    
    
    @IBOutlet weak var button: UIButton!
    
    /* Initialized Variables */
    let formatter = DateFormatter()
    var ref: DatabaseReference!
    var classRef = "ERROR - NO CLASSREF"
    
    /* Used to send event data back to Database under userID -> schedule */
    @IBAction func submitButton(_ sender: Any) {
        /* Checks for completed conditions: completed textfields
           and correct formts for date, start, and end times */
        if ((eventNameTF.text?.isEmpty)! || (locationTF.text?.isEmpty)! ||
            (dateTF.text?.isEmpty)! || (startTF.text?.isEmpty)! || (endTF.text?.isEmpty)!) {
            alertErrorHelper(text: "ERROR: Incompleted information. Please complete all five textfields.")
        } else if (formatChecker(condition: "MM/dd/yyyy", text: dateTF.text!) == false
                    || dateTF.text!.count != 10) {
            alertErrorHelper(text: "Incorrect format for Date. (MM/DD/YYYY)")
        } else if (formatChecker(condition: "HH:mma", text: startTF.text!) == false
                    || startTF.text!.count != 7) {
            alertErrorHelper(text: "Incorrect format for Start Time. (EX: 01:30am)")
        } else if (formatChecker(condition: "HH:mma", text: endTF.text!) == false
                    || endTF.text!.count != 7) {
            alertErrorHelper(text: "Incorrect format for End Time. (EX: 01:30pm)")
        } else {
            // Readys the textfields for usage
            let e = eventNameTF.text!
            let l = locationTF.text!
            let d = (dateTF.text!).replacingOccurrences(of: "/", with: "")
            let sT = startTF.text!
            let eT = endTF.text!
            
            // Adds data onto Firebase
            self.ref.child("schedule").child(classRef).child(d).childByAutoId().setValue([
                "date" : d,
                "location" : l,
                "name" : e,
                "start" : sT,
                "end" : eT
                ])
            
            // Dismisses the EventScheduleVC back to sidePanel
            dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.layer.cornerRadius = 25
        UIColourScheme.instance.set(for:self)
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
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
