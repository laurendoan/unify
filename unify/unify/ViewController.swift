//
//  ViewController.swift
//  unify
//
//  Created by Priya Patel on 3/24/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    @IBOutlet weak var infImage: UIImageView!
    
    let yesUserSegueIdentifier = "yesUserSegueIdentifier"
    let noUserSegueIdentifier = "noUserSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Animate infinity sign.
        UIView.animate(
            withDuration: 3.5,
            delay: 0.0,
            options: .repeat, animations: {
                // Rotate 180 degrees.
                self.infImage.transform = self.infImage.transform.rotated(
                    by: CGFloat(Double.pi))
            }
        )
        
        // "Loading."
        DispatchQueue.main.asyncAfter(deadline:.now() + 5.0, execute: {
            // Check if there is a user currently signed in.
            if Auth.auth().currentUser != nil {
                // User is signed in. Segue to HomeVC.
                self.performSegue(withIdentifier: "yesUserSegueIdentifier", sender: self)
            } else {
                // No user is signed in. Segue to LoginVC.
                self.performSegue(withIdentifier: "noUserSegueIdentifier", sender: self)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide  navigation bar when  view appears.
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Set background color.
        self.view.backgroundColor = JDColor.appViewBackground.color
    }
}
