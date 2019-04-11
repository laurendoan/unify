//
//  PanelViewController.swift
//  unify
//
//  Created by Saarila Kenkare on 4/7/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit

protocol MembersDelegate {
    func membersPressed()
}

protocol LeaveClassProtocol {
    // Removes the given class from the user's class list.
    func leaveClass(className: String)
}

class PanelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var muteLabel: UILabel!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var muteSwitch: UISwitch!
    
    var delegate: MembersDelegate?
    var classNameRef = "ERROR - INCORRECT CLASSNAMEREF"
    var classId = ""
    let notesSegueIdentifier = "notesSegueIdentifier"
    var eventVC = EventScheduleViewController()
    
    var leaveClassDelegate: LeaveClassProtocol?
    var className = "" // Name of the current class.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        //view1.frame = CGRect(x: view1.frame.minX, y: view1.frame.minY, width: view1.frame.width, height: 1.0)
        //divider1.frame = CGRect(x: divider1.frame.minX, y: divider1.frame.minY, width: divider1.frame.width, height: 1.0)
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(section)
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("in function", indexPath.row)
        if(indexPath.row == 0) {
            let cell:MuteTableViewCell = tableView.dequeueReusableCell(withIdentifier: "muteCellIdentifier", for: indexPath as IndexPath) as! MuteTableViewCell
            return cell
        }
        if(indexPath.row == 1) {
            let cell:MembersTableViewCell = tableView.dequeueReusableCell(withIdentifier: "membersCellIdentifier", for: indexPath as IndexPath) as! MembersTableViewCell
            return cell
        }
        //return UITableViewCell()
        if(indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notesCellIdentifier", for: indexPath as IndexPath)
            return cell
        }
        if(indexPath.row == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCellIdentifier", for: indexPath as IndexPath)
            return cell
        }
        if(indexPath.row == 4) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "leaveClassCellIdentifier", for: indexPath as IndexPath)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        if(row == 1) {
            //print("they clicked notes")
            delegate?.membersPressed()
        } else if (row == 3) {
            //self.performSegue(withIdentifier: "scheduleToEventSegue", sender: self)
            eventVC.classRef = classNameRef
        } else if indexPath.row == 4 {
            // Leave class.
            leaveClassDelegate?.leaveClass(className: className)
        }
    }
    
    // Prepares for segue to MessagesVC.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scheduleToEventSegue",
            let destination = segue.destination as? EventScheduleViewController {
            destination.classRef = classNameRef
        } else if segue.identifier == notesSegueIdentifier,
            let destination = segue.destination as? NotesViewController {
            destination.className = classNameRef
            destination.classId = classId
        }
    }
}
