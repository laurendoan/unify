//
//  ChangeEventViewController.swift
//  unify
//
//  Created by David Do on 4/23/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class ChangeEventViewController: UIViewController {
    /* Initialized Variables */
    var contentHolder: EventContent! = nil
    let formatter = DateFormatter()
    var ref: DatabaseReference! // Database reference.
    let center = UNUserNotificationCenter.current() // Notification center.
    var calendarUpdates = UserDefaults.standard.bool(forKey: "Calendar Updates")
    
    /* Initialized textfields */
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var start: UITextField!
    @IBOutlet weak var end: UITextField!
    
    @IBOutlet weak var save: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        setup()// Do any additional setup after loading the view.
        save.layer.cornerRadius = 25
        save.layer.borderWidth = 1
        save.layer.borderColor = JDColor.appAccent.color.cgColor
        // Style text fields
        addBottomTextBorder(textField: name)
        addBottomTextBorder(textField: location)
        addBottomTextBorder(textField: date)
        addBottomTextBorder(textField: start)
        addBottomTextBorder(textField: end)
    }
    
    func addBottomTextBorder(textField:UITextField) {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = JDColor.appAccent.color.cgColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width: textField.frame.size.width, height: textField.frame.size.height)
        
        border.borderWidth = width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.view.backgroundColor = JDColor.appViewBackground.color
        
        name.attributedPlaceholder = NSAttributedString(string: "ex: CS439 Exam 1", attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        name.textColor = JDColor.appText.color
        
        location.attributedPlaceholder = NSAttributedString(string: "ex: UTC: 2.102A", attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        location.textColor = JDColor.appText.color
        
        date.attributedPlaceholder = NSAttributedString(string: "mm/dd/yyyy", attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        date.textColor = JDColor.appText.color
        
        start.attributedPlaceholder = NSAttributedString(string: "HH:MMam/pm (ex: 01:00am)", attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        start.textColor = JDColor.appText.color
        
        end.attributedPlaceholder = NSAttributedString(string: "HH:MMam/pm (ex: 01:00am)", attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        end.textColor = JDColor.appText.color
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
            //date.isUserInteractionEnabled = false
            print("Debugging - ChangeEventVC - ClassRef:", contentHolder.courseRef!)
            print("Debugging - ChangeEventVC - ParentIDRef:", contentHolder.parentRef!)
        }
    }
    
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
            let d = date.text!.replacingOccurrences(of: "/", with: "")
            let s = start.text!
            let e = end.text!
            
            // Deletes data on FireBase - conditioned specifically to help update the date
            self.ref.child("schedule").child(contentHolder.courseRef!).child(contentHolder.date!)
                .child(contentHolder.parentRef!).removeValue()
            
            // Update data onto Firebase - Recreates the event with its altered data
            self.ref.child("schedule").child(contentHolder.courseRef!).child(d)
                    .child(contentHolder.parentRef!).setValue([
                "date" : d,
                "location" : l,
                "name" : n,
                "start" : s,
                "end" : e
                ])
            
            if calendarUpdates {
                // Create notification.
                let notification = UNMutableNotificationContent()
                notification.title = contentHolder.course!
                notification.subtitle = n
                notification.body = "This event has been updated."
                notification.sound = UNNotificationSound.default
                
                // Trigger the notification after 5 seconds.
                let delay: TimeInterval = 5.0
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
                
                // Create request to submit notification.
                let request = UNNotificationRequest(identifier: "notification", content: notification, trigger: trigger)
                
                // Submit request.
                center.add(request) { error in
                    if let e = error {
                        print("Add request error: \(e)")
                    }
                }
            }
        }
        
        resetAndBack()
    }
    
    /* Helper function reset variables to dismiss the VC */
    func resetAndBack() {
        // Resets the variables back to nil
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
    
}
