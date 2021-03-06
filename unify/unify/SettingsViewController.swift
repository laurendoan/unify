//
//  SettingsViewController.swift
//  unify
//
//  Created by Lauren Doan on 3/26/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    let signOutSegueIdentifier = "signOutSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hides the navigation bar when the view appears.
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Set background color.
        self.view.backgroundColor = JDColor.appViewBackground.color
    }
    
    // Signs out the current user.
    @IBAction func signOutButtonClicked(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            performSegue(withIdentifier: signOutSegueIdentifier, sender: self)
        } catch let signOutError as NSError {
            let alert = UIAlertController(title: "Failed to logout", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            print("Error signing out: %@", signOutError)
        }
    }
}
