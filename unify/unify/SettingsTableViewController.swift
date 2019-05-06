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
    @IBOutlet weak var chatAlertsSwitch: UISwitch!
    @IBOutlet weak var calendarUpdatesSwitch: UISwitch!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var chatAlertLabel: UILabel!
    @IBOutlet weak var calendarUpdateLabel: UILabel!
    @IBOutlet weak var darkModeLabel: UILabel!
    @IBOutlet weak var editInfoLabel: UILabel!
    
    var rowsPerSection:[Int] = [2, 1, 1, 1] // Number of rows per section.
    
    let editAccountSegueIdentifier = "editAccountSegueIdentifier"
    let signOutSegueIdentifier = "signOutSegueIdentifier"
    
    let userDefaults = UserDefaults.standard
    var chatAlerts = true
    var calendarUpdates = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatAlerts = userDefaults.bool(forKey: "Chat Alerts")
        chatAlertsSwitch.setOn(chatAlerts, animated: true)
        
        calendarUpdates = userDefaults.bool(forKey: "Calendar Updates")
        calendarUpdatesSwitch.setOn(calendarUpdates, animated: true)
        
        darkModeSwitch.setOn(ThemeManager.sharedThemeManager.isNightMode(), animated: false)
//        darkModeSwitch.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
    }
    
    // Hides the navigation bar when the view appears.
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        // Sets the background color.
        super.viewWillAppear(animated)
        
        updateTheme()
    }

    // Returns the number of sections in the table view.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return rowsPerSection.count
    }

    // Returns the number of rows in the given section.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsPerSection[section]
    }
    
    // Performs certain actions when a specific row is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Edit account section.
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
    
    @IBAction func chatAlertsToggled(_ sender: Any) {
        chatAlerts = chatAlertsSwitch.isOn
        userDefaults.set(chatAlerts, forKey: "Chat Alerts")
    }
    
    @IBAction func calendarUpdatesToggled(_ sender: Any) {
        calendarUpdates = calendarUpdatesSwitch.isOn
        userDefaults.set(calendarUpdates, forKey: "Calendar Updates")
    }
    
    @IBAction func darkModeToggled(_ sender: UISwitch) {
        ThemeManager.sharedThemeManager.toggleTheme()
        updateTheme()
    }
    
    func updateTheme() {
        self.view.backgroundColor = JDColor.appViewBackground.color
        chatAlertLabel.textColor = JDColor.appText.color
        calendarUpdateLabel.textColor = JDColor.appText.color
        darkModeLabel.textColor = JDColor.appText.color
        editInfoLabel.textColor = JDColor.appText.color
        self.tabBarController?.tabBar.barTintColor = JDColor.appTabBarBackground.color
        self.tabBarController?.tabBar.tintColor = JDColor.appAccent.color
        self.tabBarController?.tabBar.unselectedItemTintColor = JDColor.appSubText.color
    }
}
