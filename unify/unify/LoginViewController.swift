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
    
    let accent = UIColor(red: 227/255, green: 142/255, blue: 128/255, alpha: 1)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Style "Login" button.
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = accent.cgColor
        button.setTitleColor(accent, for: .normal)
        // Style "Sign Up" button.
        suButton.layer.cornerRadius = 10
        
        let border = CALayer()
        let border2 = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = accent.cgColor
        border.frame = CGRect(x: 0, y: emailTextField.frame.size.height - width, width: emailTextField.frame.size.width, height: emailTextField.frame.size.height)
        
        border.borderWidth = width
        emailTextField.layer.addSublayer(border)
        emailTextField.layer.masksToBounds = true
        border2.borderColor = accent.cgColor
        border2.frame = CGRect(x: 0, y: passwordTextField.frame.size.height - width, width: passwordTextField.frame.size.width, height: passwordTextField.frame.size.height)
        border2.borderWidth = width
        passwordTextField.layer.addSublayer(border2)
        passwordTextField.layer.masksToBounds = true
    }
    
    // Hides the navigation bar when the view appears.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.backgroundColor = JDColor.appSubviewBackground.color
        emailTextField.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        emailTextField.textColor = JDColor.appText.color
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
        passwordTextField.textColor = JDColor.appText.color
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
