//
//  SettingsTableViewController.swift
//  unify
//
//  Created by Lauren Doan on 4/6/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsTableViewController: UITableViewController {
    var rowsPerSection:[Int] = [2, 1, 1, 1] // Number of rows per section.
    
    let editAccountSegueIdentifier = "editAccountSegueIdentifier"
    let signOutSegueIdentifier = "signOutSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the background color.
        UIColourScheme.instance.set(for:self)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }

    // Returns the number of sections in the table view.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return rowsPerSection.count
    }

    // Returns the number of rows in the given section.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsPerSection[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Account section.
        if indexPath.section == 2 {
            performSegue(withIdentifier: editAccountSegueIdentifier, sender: self)
        } else if indexPath.section == 3 {
            // Sign out section.
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
}
