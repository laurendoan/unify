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
    
    /* Array variables to store courses and its unique IDs */
    var courses: [String] = []
    var courseTitles: [String] = []
    
    /* Variables to be sent to MessageViewController */
    var classClicked: String = ""
    var classClickedID: String = ""
    
    let textCellIdentifier = "textCellIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        /*
        // Add courses from database into courses array
        ref = Database.database().reference()
        ref.child("users").child(user!.uid).observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let courses = value?["courses"] as? Array ?? []
            self.courses = courses as! [String]
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
        */
        
        ref = Database.database().reference()
        ref.child("users").child(user!.uid).child("courses").observe(.value, with: { (snapshot) in
            for i in snapshot.children.allObjects as! [DataSnapshot] {
                let identifier = i.value as? String
                self.courses.append(identifier!)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        let row = indexPath.row
        
        cell.textLabel?.text = courseTitles[row]
        return cell
    }
    
    //this is the function that is called onclick of a class cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        
        /* Sets variable to be sent to via segue */
        classClicked = courses[row]
        classClickedID = courseTitles[row]
        
        self.performSegue(withIdentifier: "homeToMessagesSegueIdentifier", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeToMessagesSegueIdentifier",
            let destination = segue.destination as? MessagesViewController {
            destination.className = classClicked
            destination.classID = classClickedID
        }
    }
    
}
