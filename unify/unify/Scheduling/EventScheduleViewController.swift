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
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    /* Initialized Variables */
    let formatter = DateFormatter()
    var ref: DatabaseReference!
    let center = UNUserNotificationCenter.current() // Notification center.
    var calendarUpdates = UserDefaults.standard.bool(forKey: "Calendar Updates")
    var classRef = "ERROR - NO CLASSREF"
    var courseName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        // Do any additional setup after loading the view.
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = JDColor.appAccent.color.cgColor
        
        // Style text fields
        addBottomTextBorder(textField: eventNameTF)
        addBottomTextBorder(textField: locationTF)
        addBottomTextBorder(textField: dateTF)
        addBottomTextBorder(textField: startTF)
        addBottomTextBorder(textField: endTF)
        
        // Used to dismiss keyboard on scroll view
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.touch))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(recognizer)
    }
    
    // Helper function to dismiss keyboard
    @objc func touch() {
        self.view.endEditing(true)
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
        
        eventNameTF.attributedPlaceholder = NSAttributedString(string: "ex: CS439 Exam 1", attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        eventNameTF.textColor = JDColor.appText.color
        
        locationTF.attributedPlaceholder = NSAttributedString(string: "ex: UTC: 2.102A", attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        locationTF.textColor = JDColor.appText.color
        
        dateTF.attributedPlaceholder = NSAttributedString(string: "mm/dd/yyyy", attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        dateTF.textColor = JDColor.appText.color
        
        startTF.attributedPlaceholder = NSAttributedString(string: "HH:MMam/pm (ex: 01:00am)", attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        startTF.textColor = JDColor.appText.color
        
        endTF.attributedPlaceholder = NSAttributedString(string: "HH:MMam/pm (ex: 01:00am)", attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        endTF.textColor = JDColor.appText.color
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.parent?.view.frame = CGRect(x: self.view.frame.width/3, y: 0, width: self.view.frame.width*2/3, height: self.view.frame.height) //want it 1/3 of the way across the screen so it's coming from the right
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
            
            if calendarUpdates {
                // Create notification.
                let notification = UNMutableNotificationContent()
                notification.title = courseName
                notification.subtitle = e
                notification.body = "A new event has been created."
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
