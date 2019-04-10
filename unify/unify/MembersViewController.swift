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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        var ref = Database.database().reference()
        print("Class: ",className)
        ref.child("courses").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let classValues = value![self.className]! as? NSDictionary
            //print(classValues)
            if let val = classValues!["members"]{
                // now val is not nil and the Optional has been unwrapped, so use it
                var mems = val as! [String]
                //print("val: ", val)
                print(mems.count)
                self.count = mems.count
                self.members = mems
                self.tableView.reloadData() //Without this, the tableView won't have the correct data. Since this is an async call, it needs this to tell the TableView that data has been added.
            }
            
        })
        // Do any additional setup after loading the view.
    }
    
    /*override func viewDidAppear(_ animated: Bool) {
        
    }*/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:MembersTableViewCell = tableView.dequeueReusableCell(withIdentifier: "membersCellIdentifier", for: indexPath as IndexPath) as! MembersTableViewCell
        
        cell.memberName.text = members[indexPath.row]
        print("Name: ", cell.memberName.text)
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
