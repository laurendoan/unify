//
//  MembersViewController.swift
//  unify
//
//  Created by Saarila Kenkare on 4/9/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit
import Firebase

class MembersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var membersLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    var className: String = ""
    var members: [String] = []
    var count = 0
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Members"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        ref = Database.database().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set panel background color
        self.view.backgroundColor = JDColor.appSubviewBackground.color
        
        members.removeAll()
        
        ref.child("courses").child(className).child("members").observe(DataEventType.value) { (snapshot) in
            if (snapshot.childrenCount > 0) {
                // Used to avoid duplications
                self.members.removeAll()
                
                // Iterates through the number of children
                for i in snapshot.children.allObjects as! [DataSnapshot] {
                    // Pulls data from each child and adds it to the member's array
                    let Object = i.value as? String
                    self.members.append(Object!)
                    self.tableView.reloadData()
                }
                
                // Set layout of members table view row.
                self.tableView.rowHeight = 40
                self.tableView.frame = CGRect(x: 0, y: 100, width: 276, height: Int(self.tableView.rowHeight) * self.members.count)
            }
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MembersTableViewCell = tableView.dequeueReusableCell(withIdentifier: "membersCellIdentifier", for: indexPath as IndexPath) as! MembersTableViewCell
        
        // Set member name text color.
        cell.memberName.text = members[indexPath.row]
        cell.memberName.textColor = JDColor.appText.color
        
        return cell
    }
}
