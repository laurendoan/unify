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
    
    var ref: DatabaseReference! // Database reference.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        // Set initial values of text fields to empty strings.
        displayNameTextField.text! = ""
        emailTextField.text! = ""
        passwordTextField.text! = ""
        confirmPasswordTextField.text! = ""
        
        // Customize button.
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = JDColor.appAccent.color.cgColor

        // Customize text fields.
        addBottomTextBorder(textField: displayNameTextField)
        addBottomTextBorder(textField: emailTextField)
        addBottomTextBorder(textField: passwordTextField)
        addBottomTextBorder(textField: confirmPasswordTextField)
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
        
        // Show navigation bar when view appears.
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Customize navigation bar.
        navigationController?.navigationBar.barTintColor = JDColor.appTabBarBackground.color
        navigationController?.navigationBar.tintColor = JDColor.appSubText.color
        
        // Customize background color.
        self.view.backgroundColor = JDColor.appViewBackground.color
        
        // Customize text in text fields.
        displayNameTextField.attributedPlaceholder = NSAttributedString(string: "display name", attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        displayNameTextField.textColor = JDColor.appText.color
        emailTextField.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        emailTextField.textColor = JDColor.appText.color
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        passwordTextField.textColor = JDColor.appText.color
        confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: "confirm password", attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        confirmPasswordTextField.textColor = JDColor.appText.color
    }
    
    // Updates all user information before presenting alert and segueing.
    func updateInfo (completion: @escaping (_ message: String) -> Void) {
        if displayNameTextField.text != "" {
            // Display name has been changed.
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = displayNameTextField.text
            changeRequest?.commitChanges { (error) in
                if error != nil {
                    // Alert if error.
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    // Update in database too, if successful.
                    let user = Auth.auth().currentUser
                    self.ref.child("users/\(user!.uid)/displayName").setValue(self.displayNameTextField.text)
                    self.ref.child("users").child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        let value = snapshot.value as? NSDictionary
                        let courses = value?["courses"] as? Array ?? []
                        for course in courses {
                            let childUpdates = ["/courses/\(course)/members/\(user!.uid)/": self.displayNameTextField.text]
                            self.ref.updateChildValues(childUpdates as [AnyHashable : Any])
                        }
                        
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
        if emailTextField.text != "" {
            // Email has been changed.
            Auth.auth().currentUser?.updateEmail(to: emailTextField.text!) { (error) in
                Auth.auth().currentUser?.sendEmailVerification { (error) in
                    if error != nil {
                        // Alert if error.
                        let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        
        if passwordTextField.text != "" {
            // Password has been changed.
            if passwordTextField.text != confirmPasswordTextField.text {
                // Make sure password and confirm password fields match. Alert if not.
                let alertController = UIAlertController(title: "Password does not match", message: "Please re-type password.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                Auth.auth().currentUser?.updatePassword(to: passwordTextField.text!) { (error) in
                    if error != nil {
                        // Alert if error.
                        let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        
        // Message to indicate completed.
        completion("finished")
    }

    // Saves user info if updated.
    @IBAction func saveButton(_ sender: Any) {
        if passwordTextField.text == "" && emailTextField.text == "" && displayNameTextField.text == "" {
            // Alert if all fields are empty.
            let alertController = UIAlertController(title: "Nothing to update", message: "Please enter updated information.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            if self.passwordTextField.text != "" || self.emailTextField.text != "" {
                var email = UITextField()
                var pass = UITextField()
                
                // Alert to get email.
                let alert = UIAlertController(title: "Re-authenticate your account", message: "Enter your email", preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.text = ""
                }
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                    email = alert.textFields![0]
                    
                    // Alert to get password.
                    let alert2 = UIAlertController(title: "Re-authenticate your account", message: "Enter your password", preferredStyle: .alert)
                    alert2.addTextField { (textField) in
                        textField.text = ""
                        textField.isSecureTextEntry = true
                    }
                    
                    alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                        pass = alert2.textFields![0]
                        
                        // Re-authenticate user based on email and password input in alerts.
                        let user = Auth.auth().currentUser
                        var credential: AuthCredential
                        credential = EmailAuthProvider.credential(withEmail: email.text!, password: pass.text!)
                        
                        user?.reauthenticateAndRetrieveData(with: credential, completion: {(authResult, error) in
                            if let error = error {
                                // Alert if error.
                                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                alertController.addAction(defaultAction)
                                self.present(alertController, animated: true, completion: nil)
                            } else {
                                // Update user's info in Firebase.
                                self.updateInfo(completion: { message in
                                    print(message)
                                    
                                    // Alert profile has been updated.
                                    let alert = UIAlertController(title: "Profile successfully updated!", message: "", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                                        // Go back to settings page.
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
                // Update user's info in Firebase.
                self.updateInfo(completion: { message in
                    print(message)
                    
                    // Alert profile has been updated.
                    let alert = UIAlertController(title: "Profile successfully updated!", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                        
                        // Go back to settings page.
                        if let navController = self.navigationController {
                            navController.popViewController(animated: true)
                        }}))
                    self.present(alert, animated: true, completion: nil)
                })
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
