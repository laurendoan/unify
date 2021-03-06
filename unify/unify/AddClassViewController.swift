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
    
    var ref: DatabaseReference! // Database reference.
    let cur = Auth.auth().currentUser! // Current user.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        // Customize login button.
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = JDColor.appAccent.color.cgColor
        
        // Customize text fields.
        addBottomTextBorder(textField: courseNumTextField)
        addBottomTextBorder(textField: instructorTextField)
    }
    
    // Helper func to add a line under text field (for UI).
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
        
        // Show navigation bar when view appears.
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Set background color.
        self.view.backgroundColor = JDColor.appViewBackground.color
        
        // Customize text in textfields.
        customizeTextFieldText(textField: courseNumTextField, placeHolderText: "ex: CS 371L")
        customizeTextFieldText(textField: instructorTextField, placeHolderText: "ex: BULKO W")
        
        // Customize navigation bar.
        navigationController?.navigationBar.barTintColor = JDColor.appTabBarBackground.color
        navigationController?.navigationBar.tintColor = JDColor.appSubText.color
    }
    
    // Helper func to change text field text and placeholder text color.
    func customizeTextFieldText(textField: UITextField, placeHolderText: String) {
        textField.attributedPlaceholder = NSAttributedString(string: placeHolderText, attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        textField.textColor = JDColor.appText.color
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
                // Remove spaces and ignore commas or periods for course key.
                let course = (self.courseNumTextField.text!.replacingOccurrences(of: " ", with: "") + self.instructorTextField.text!.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ",", with: "").replacingOccurrences(of: ".", with: "")).uppercased()
                
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
                            
                            // Adds user into the member's list under courses
                            let databaseRef = Constants.refs.databaseCourses.child("\(course)/members/\((self.cur.uid))")
                            databaseRef.setValue(displayName)
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
