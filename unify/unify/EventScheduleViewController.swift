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
    @IBOutlet weak var timeTF: UITextField!
    
    /* Initialized Variables */
    var ref: DatabaseReference!
    var classRef = "ERROR - NO CLASSREF"
    
    /* Used to send event data back to Database under userID -> schedule */
    @IBAction func submitButton(_ sender: Any) {
        // Checks for all completed textfields
        if ((eventNameTF.text?.isEmpty)! || (locationTF.text?.isEmpty)! ||
            (dateTF.text?.isEmpty)! || (timeTF.text?.isEmpty)!) {
            let alertController = UIAlertController(title: "Error", message:
                "Incompleted information. Please complete all four textfields.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            // Gets user UID from firebase
            // let userID = Auth.auth().currentUser?.uid
            
            // Readys the textfields for usage
            let e = eventNameTF.text!
            let l = locationTF.text!
            let d = (dateTF.text!).replacingOccurrences(of: "/", with: "")
            let t = timeTF.text!
            
            // Adds data onto Firebase
            self.ref.child("schedule").child(classRef).child(d).childByAutoId().setValue([
                "date" : d,
                "location" : l,
                "name" : e,
                "time" : t
                ])
            
            // Dismisses the EventScheduleVC back to sidePanel
            dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIColourScheme.instance.set(for:self)
        ref = Database.database().reference()
        
        print(classRef)
        // Do any additional setup after loading the view.
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
