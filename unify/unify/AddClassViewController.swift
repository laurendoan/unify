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
    @IBOutlet weak var courseNumTextField: UITextField!
    @IBOutlet weak var instructorTextField: UITextField!
    @IBOutlet weak var button: UIButton!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Database reference.
        ref = Database.database().reference()
        
        // Style "Login" button.
        button.layer.cornerRadius = 25
    }
    
    // Shows the navigation bar when the view appears.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.view.backgroundColor = JDColor.appSubviewBackground.color
        
    }
    
    // Adds a class to the user's course list when the "add" button is pressed.
    @IBAction func addButton(_ sender: Any) {
        let userID = Auth.auth().currentUser?.uid
        
        // Check if the user gave input.
        if courseNumTextField.text == "" || instructorTextField.text == "" {
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
                let course = (self.courseNumTextField.text!.replacingOccurrences(of: " ", with: "") + self.instructorTextField.text!.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ",", with: "")).uppercased()
                
                // Check if the user is already a part of given course.
                guard !courses.contains(where: { (element) -> Bool in
                    element as! String == course
                }) else {
                    let alertController = UIAlertController(title: "Error", message: "Class already exists", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                
                // Check if given course exists in the database.
                self.ref.child("courses").observeSingleEvent(of: .value, with: { (snapshot) in
                    // If the course exists, add course to user's list.
                    if snapshot.hasChild(course) {
                        courses.append(course)
                        self.ref.child("users/\(userID!)/courses").setValue(courses)
                        
                        // Get user's display name.
                        self.ref.child("users/\(userID!)").observeSingleEvent(of: .value, with: { (snapshot) in
                            let value = snapshot.value as? NSDictionary
                            let displayName = value!["displayName"]
                            
                            // Add user to course's member list.
                            self.ref.child("courses").child(course).observeSingleEvent(of: .value, with: { (snapshot) in                            let value = snapshot.value as? NSDictionary
                                var members = value?["members"] as? Array ?? []
                                members.append(displayName!)
                                self.ref.child("courses/\(course)/members").setValue(members)
                            })
                        })
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
    
    // Dismisses the keyboard when user clicks on background.
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
