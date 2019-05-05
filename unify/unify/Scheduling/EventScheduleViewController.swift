//
//  EventScheduleViewController.swift
//  unify
//
//  Created by David Do on 4/9/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

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
    let center = UNUserNotificationCenter.current() // Notification center.
    var classRef = "ERROR - NO CLASSREF"
    var courseName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.layer.cornerRadius = 25
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = JDColor.appSubviewBackground.color
    }
    
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
            
            // Create notification.
            let notification = UNMutableNotificationContent()
            notification.title = courseName
            notification.subtitle = e
            notification.body = "A new event has been created."
            
            // Trigger the notification after 3 seconds.
            let delay: TimeInterval = 3.0
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
            
            // Create request to submit notification.
            let request = UNNotificationRequest(identifier: "notification", content: notification, trigger: trigger)
            
            // Submit request.
            center.add(request) { error in
                if let e = error {
                    print("Add request error: \(e)")
                }
            }
            
            // Dismisses the EventScheduleVC back to sidePanel
            dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
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
}
