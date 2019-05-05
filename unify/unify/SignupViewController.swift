//
//  SignupViewController.swift
//  unify
//
//  Created by Priya Patel on 3/24/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignupViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var button: UIButton!
    
    var ref: DatabaseReference!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Database reference.
        ref = Database.database().reference()
        
        // Style "Sign Up" button.
        button.layer.cornerRadius = 25
    }
    
    // Shows the navigation bar when the view appears.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.view.backgroundColor = JDColor.appSubviewBackground.color
    }

    // Signs up a user.
    @IBAction func signupButton(_ sender: Any) {
        // Check if the passwords match.
        if passwordTextField.text != retypePasswordTextField.text {
            let alertController = UIAlertController(title: "Password does not match", message: "Please re-type password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            // Create a new user.
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!){ (user, error) in
                if error == nil {
                    // Store display name for user.
                    Auth.auth().currentUser?.sendEmailVerification { (error) in
                        let name = self.firstNameTextField.text! + " " + self.lastNameTextField.text!
                        let user = Auth.auth().currentUser
                        self.ref.child("users").child((user?.uid)!).setValue(["displayName": name])
                        
                        // Take the user directly to the HomeVC after signing up.
                        self.performSegue(withIdentifier: "signupToHomeSegueIdentifier", sender: self)
                    }
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    // Dismisses keyboard when user clicks on background.
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
