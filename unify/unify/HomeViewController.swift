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
    var courses: [String] = [] // User's registered classes
    var courseTitles: [String] = []
    var courseClicked = ""
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
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        let row = indexPath.row
        
        ref.child("courses").child(String(courses[row])).child("classTitle").observeSingleEvent(of: .value, with: { (snapshot) in
            let title = snapshot.value as? String
            self.courseClicked = title!
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
        
        cell.textLabel?.text = courseTitles[row]
        return cell
    }
    
}
