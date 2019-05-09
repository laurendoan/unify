//
//  LoginViewController.swift
//  unify
//
//  Created by Priya Patel on 3/24/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var suButton: UIButton!
    
    @IBOutlet weak var newUserLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Style "Login" button.
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = JDColor.appAccent.color.cgColor
        
        // Style "Sign Up" button.
        suButton.layer.cornerRadius = 10
        
        // Style text fields
        addBottomTextBorder(textField: emailTextField)
        addBottomTextBorder(textField: passwordTextField)
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
        
        // Hides the navigation bar when the view appears.
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Set background color.
        self.view.backgroundColor = JDColor.appViewBackground.color
        
        // Customize text fields text and placeholder text colors.
        customizeTextFieldText(textField: emailTextField, placeHolderText: "email")
        customizeTextFieldText(textField: passwordTextField, placeHolderText: "password")
        
        // Set "new user" label color
        newUserLabel.textColor = JDColor.appText.color
    }
    
    // Helper func to change text field text and placeholder text color.
    func customizeTextFieldText(textField: UITextField, placeHolderText: String) {
        textField.attributedPlaceholder = NSAttributedString(string: placeHolderText, attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        textField.textColor = JDColor.appText.color
    }
    
    // Logs the user in.
    @IBAction func loginButton(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if error == nil {
                self.performSegue(withIdentifier: "loginToHomeSegueIdentifier", sender: self)
            }
            else {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
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
