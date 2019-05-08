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
        /*
        // print("Class: ",className)
        ref.child("courses").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let classValues = value![self.className]! as? NSDictionary
            //print(classValues)
            if let val = classValues!["members"]{
                // now val is not nil and the Optional has been unwrapped, so use it
                print(val)
                let mems = val as! [String]
                self.count = mems.count
                self.members = mems
                self.tableView.rowHeight = 40
                self.tableView.frame = CGRect(x: 0, y: 100, width: 276, height: Int(self.tableView.rowHeight) * self.members.count)
                self.tableView.reloadData() //Without this, the tableView won't have the correct data. Since this is an async call, it needs this to tell the TableView that data has been added.
            }
            
        })
        */
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = JDColor.appSubviewBackground.color
        
        members.removeAll()
        
        ref.child("courses").child(className).child("members").observeSingleEvent(of: DataEventType.value) { (snapshot) in
            if (snapshot.childrenCount > 0) {
                self.members.removeAll()
                
                // Iterates through the number of children
                for i in snapshot.children.allObjects as! [DataSnapshot] {
                    // Pulls data from each child (name of course, course id, and the instructor)
                    let Object = i.value as? String
                    self.members.append(Object!)
                    self.tableView.reloadData()
                }
                self.tableView.rowHeight = 40
                self.tableView.frame = CGRect(x: 0, y: 100, width: 276, height: Int(self.tableView.rowHeight) * self.members.count)
            }
        }
        
    }
    
    /*override func viewDidAppear(_ animated: Bool) {
        
    }*/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:MembersTableViewCell = tableView.dequeueReusableCell(withIdentifier: "membersCellIdentifier", for: indexPath as IndexPath) as! MembersTableViewCell
        
        cell.memberName.text = members[indexPath.row]
        cell.memberName.textColor = JDColor.appText.color
//        print("Name: ", cell.memberName.text)
        return cell
    }
}
