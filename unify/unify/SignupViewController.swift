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
    
    let accent = UIColor(red: 227/255, green: 142/255, blue: 128/255, alpha: 1)
    var ref: DatabaseReference!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Database reference.
        ref = Database.database().reference()
        
        // Style "Sign Up" button.
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = accent.cgColor
        button.setTitleColor(accent, for: .normal)
        
        // Style text fields
        addBottomTextBorder(textField: emailTextField)
        addBottomTextBorder(textField: passwordTextField)
        addBottomTextBorder(textField: retypePasswordTextField)
        addBottomTextBorder(textField: firstNameTextField)
        addBottomTextBorder(textField: lastNameTextField)
    }
    
    // Shows the navigation bar when the view appears.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.view.backgroundColor = JDColor.appSubviewBackground.color
        emailTextField.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        emailTextField.textColor = JDColor.appText.color
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        passwordTextField.textColor = JDColor.appText.color
        
        retypePasswordTextField.attributedPlaceholder = NSAttributedString(string: "confirm password", attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        retypePasswordTextField.textColor = JDColor.appText.color
        
        firstNameTextField.attributedPlaceholder = NSAttributedString(string: "first name", attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        firstNameTextField.textColor = JDColor.appText.color
        
        lastNameTextField.attributedPlaceholder = NSAttributedString(string: "last name", attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        lastNameTextField.textColor = JDColor.appText.color
        
        navigationController?.navigationBar.barTintColor = JDColor.appTabBarBackground.color
        navigationController?.navigationBar.tintColor = JDColor.appSubText.color
    }

    func addBottomTextBorder(textField:UITextField) {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = accent.cgColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width: textField.frame.size.width, height: textField.frame.size.height)
        
        border.borderWidth = width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
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
