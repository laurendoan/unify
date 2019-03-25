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

        // Do any additional setup after loading the view.
        ref = Database.database().reference()
    }
    
    @IBAction func addButton(_ sender: Any) {
        let userID = Auth.auth().currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            var courses = value?["courses"] as? Array ?? []
            var checkClass = true
            let course = self.courseNumTextField.text! + self.instructorTextField.text!.replacingOccurrences(of: " ", with: "")
            self.ref.child("courses").observeSingleEvent(of: .value, with: { (snapshot) in
                // check if class is a valid course
                if !snapshot.hasChild(course) {
                    let alertController = UIAlertController(title: "Error", message: "try again", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    checkClass = false
                }

            }) { (error) in
                print(error.localizedDescription)
            }
            if checkClass {
                courses.append(course)
                self.ref.child("users/\(userID!)/courses").setValue(courses)
                self.performSegue(withIdentifier: "addClassSegueIdentifier", sender: self)
            }
        }) { (error) in
            print(error.localizedDescription)
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
