//
//  EditAccountViewController.swift
//  unify
//
//  Created by Lauren Doan on 4/6/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class EditAccountViewController: UIViewController {
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var button: UIButton!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // rounded button.
        button.layer.cornerRadius = 25
        
        // Database reference.
        ref = Database.database().reference()
        
        // set initial values of text fields to empty strings
        displayNameTextField.text! = ""
        emailTextField.text! = ""
        passwordTextField.text! = ""
        confirmPasswordTextField.text! = ""
    }
    
    // Shows the navigation bar when the view appears.
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // Dismisses the keyboard when user clicks on background.
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // function to update all information before alert and segue
    func updateInfo (completion: @escaping (_ message: String) -> Void) {
        if displayNameTextField.text != "" {
            // display name has been changed.
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = displayNameTextField.text
            changeRequest?.commitChanges { (error) in
                if error != nil {
                    // alert if error.
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                else {
                    // update in database too, if successful.
                    let user = Auth.auth().currentUser
                    self.ref.child("users/\(user!.uid)/displayName").setValue(self.displayNameTextField.text)
                    
                }
            }
        }
        if emailTextField.text != "" {
            // email has been changed.
            Auth.auth().currentUser?.updateEmail(to: emailTextField.text!) { (error) in
                Auth.auth().currentUser?.sendEmailVerification { (error) in
                    if error != nil {
                        // alert if error.
                        let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        if passwordTextField.text != "" {
            // password has been changed
            if passwordTextField.text != confirmPasswordTextField.text {
                // make sure password and confirm password fields match. alert if not.
                let alertController = UIAlertController(title: "Password does not match", message: "Please re-type password.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                Auth.auth().currentUser?.updatePassword(to: passwordTextField.text!) { (error) in
                    if error != nil {
                        // alert if error.
                        let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        // message to indicated completed
        completion("finished")
    }

    @IBAction func saveButton(_ sender: Any) {
        // save button has been pressed
        if passwordTextField.text == "" && emailTextField.text == "" && displayNameTextField.text == "" {
            // alert, all fields are empty.
            let alertController = UIAlertController(title: "Nothing to update", message: "Please enter updated information.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            if self.passwordTextField.text != "" || self.emailTextField.text != "" {
                var email = UITextField()
                var pass = UITextField()
                
                // alert to get email
                let alert = UIAlertController(title: "Re-authenticate your account", message: "Enter your email", preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.text = ""
                }
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                    email = alert.textFields![0]
                    
                    //alert to get password
                    let alert2 = UIAlertController(title: "Re-authenticate your account", message: "Enter your password", preferredStyle: .alert)
                    alert2.addTextField { (textField) in
                        textField.text = ""
                        textField.isSecureTextEntry = true
                    }
                    alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                        pass = alert2.textFields![0]
                        
                        // reauthenticate user based off email and password input in alerts.
                        let user = Auth.auth().currentUser
                        var credential: AuthCredential
                        credential = EmailAuthProvider.credential(withEmail: email.text!, password: pass.text!);
                        user?.reauthenticateAndRetrieveData(with: credential, completion: {(authResult, error) in
                            if let error = error {
                                // alert if error.
                                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                alertController.addAction(defaultAction)
                                self.present(alertController, animated: true, completion: nil)
                            } else {
                                
                                // update users info in firebase.
                                self.updateInfo(completion: { message in
                                    print(message)
                                    
                                    // alert profile has been updated
                                    let alert = UIAlertController(title: "Profile successfully updated!", message: "", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                                        
                                        // go back to settings page
                                        if let navController = self.navigationController {
                                            navController.popViewController(animated: true)
                                        }}))
                                    self.present(alert, animated: true, completion: nil)
                                })
                            }
                        })
                    }))
                    self.present(alert2, animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                // update users info in firebase.
                self.updateInfo(completion: { message in
                    print(message)
                    
                    // alert profile has been updated
                    let alert = UIAlertController(title: "Profile successfully updated!", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                        
                        // go back to settings page
                        if let navController = self.navigationController {
                            navController.popViewController(animated: true)
                        }}))
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
}
