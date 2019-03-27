//
//  AddClassViewController.swift
//  unify
//
//  Created by Priya Patel on 3/25/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit
import Firebase

class AddClassViewController: UIViewController {

    var ref: DatabaseReference!
    
    @IBOutlet weak var courseNumTextField: UITextField!
    @IBOutlet weak var instructorTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIColourScheme.instance.set(for:self)
        
        // Database reference.
        ref = Database.database().reference()
    }
    
    // Shows the navigation bar.
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // Adds a class to the user's course list.
    @IBAction func addButton(_ sender: Any) {
        let userID = Auth.auth().currentUser?.uid
        
        // Check if the user gave input.
        if courseNumTextField.text == "" && instructorTextField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please insert the course number and the instructor name.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return
        } else {
            // Get the user's course list from the database.
            ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                var courses = value?["courses"] as? Array ?? []
                let course = (self.courseNumTextField.text! + self.instructorTextField.text!.replacingOccurrences(of: " ", with: "")).uppercased()
                print(course)
                guard !courses.contains(where: { (element) -> Bool in
                    element as! String == course
                }) else {
                    let alertController = UIAlertController(title: "Error", message: "Class already exists", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                self.ref.child("courses").observeSingleEvent(of: .value, with: { (snapshot) in
                    // Check if given course exists.
                    if snapshot.hasChild(course) {
                        courses.append(course)
                        self.ref.child("users/\(userID!)/courses").setValue(courses)
                        self.performSegue(withIdentifier: "addClassSegueIdentifier", sender: self)
                    } else {
                        // User did not insert a valid course.
                        let alertController = UIAlertController(title: "Error", message: "Class does not exist. Please try again.", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }) { (error) in
                    print(error.localizedDescription)
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
}
