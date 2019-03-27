//
//  HomeViewController.swift
//  unify
//
//  Created by Priya Patel on 3/24/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource,  UITableViewDelegate {
    var ref: DatabaseReference!
    let user = Auth.auth().currentUser
    @IBOutlet weak var tableView: UITableView!
    
    var courses: [String] = [] // User's list of courses.
    var courseTitles: [String] = [] // Used to display in table view.
    
    var classClicked: String = "" // Name of class clicked.
    var classClickedID: String = "" // ID of class clicked.
    
    let textCellIdentifier = "textCellIdentifier"
    let homeToMessagesSegueIdentifier = "homeToMessagesSegueIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // Sets the background color.
        UIColourScheme.instance.set(for:self)
        
        // Database reference.
        ref = Database.database().reference()
        
        // Retrieve courses from database, store in courses & courseTitles array.
        ref.child("users").child(user!.uid).child("courses").observe(.value, with: { (snapshot) in
            for i in snapshot.children.allObjects as! [DataSnapshot] {
                // Add to courses array.
                let identifier = i.value as? String
                self.courses.append(identifier!)
                
                // Add to courseTitles array. Update table view.
                self.ref.child("courses").child(identifier!).child("classTitle").observeSingleEvent(of: .value, with: { (snap) in
                    let title = snap.value as? String
                    self.courseTitles.append(title!)
                    self.tableView.reloadData()
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // Hides the navigation bar when the view appears.
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // Returns the number of courses.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseTitles.count
    }
    
    // Returns a cell at a given index.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        
        let row = indexPath.row
        cell.textLabel?.text = courseTitles[row]
        
        return cell
    }
    
    // Segues to the selected course's chat room.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get the course title of the selected cell.
        let row = indexPath.row
        classClicked = courses[row]
        classClickedID = courseTitles[row]
        
        // Segue to corresponding chat room.
        self.performSegue(withIdentifier: homeToMessagesSegueIdentifier, sender: self)
    }
    
    // Prepares for segue to MessagesVC.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == homeToMessagesSegueIdentifier,
            let destination = segue.destination as? MessagesViewController {
            destination.className = classClicked
            destination.classID = classClickedID
        }
    }
}
