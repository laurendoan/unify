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
   
    @IBOutlet var membersTableView: UITableView!
    
    var className: String = ""
    var members: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        membersTableView.dataSource = self
        membersTableView.delegate = self
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var ref = Database.database().reference()
        var members:[String] = []
        print(className)
        ref.child("courses").child(className).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? [String: String]
            members = value?["members"] as? Array ?? []
            print(members.count)
            //ref.child("courses/\(self.className)/members").setValue(members)
        })
        print(members.count)
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //return MembersTableViewCell
        /*let cell:MembersTableViewCell = membersTableView.dequeueReusableCell(withIdentifier: "membersTableViewCell", for: indexPath as IndexPath) as! MembersTableViewCell
        
        let row = indexPath.row
        cell.memberName?.text = members[row]
        
        
        return cell*/
        return MembersTableViewCell()
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
