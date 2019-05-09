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

protocol NotesDelegate {
    func notesPressed()
}

protocol LeaveClassProtocol {
    // Removes the given class from the user's class list.
    func leaveClass(className: String)
}

class PanelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: MembersDelegate?
    var notesDelegate: NotesDelegate?
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show navigation bar.
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Set background color.
        self.view.backgroundColor = JDColor.appSubviewBackground.color
        
        // Customize navigation bar.
        navigationController?.navigationBar.barTintColor = JDColor.appTabBarBackground.color
        navigationController?.navigationBar.tintColor = JDColor.appSubText.color
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:JDColor.appAccent.color]

    }
    
    // Returns the number of rows in side panel.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell:MuteTableViewCell = tableView.dequeueReusableCell(withIdentifier: "muteCellIdentifier", for: indexPath as IndexPath) as! MuteTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.configure(courseName: className)
            return cell
        }
        if indexPath.row == 1 {
            let cell:MembersPanelTableViewCell = tableView.dequeueReusableCell(withIdentifier: "membersCellIdentifier", for: indexPath as IndexPath) as! MembersPanelTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.configure()
            return cell
        }
        if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notesCellIdentifier", for: indexPath as IndexPath) as! NotesTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.configure()
            return cell
        }
        if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCellIdentifier", for: indexPath as IndexPath) as! ScheduleTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.configure()
            return cell
        }
        if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "leaveClassCellIdentifier", for: indexPath as IndexPath)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        if row == 1 {
            delegate?.membersPressed()
        } else if row == 3 {
            eventVC.classRef = classNameRef
        } else if row == 4 {
            // Leave class.
            leaveClassDelegate?.leaveClass(className: className)
        }
    }
    
    // Prepares for segue to MessagesVC.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scheduleToEventSegue",
            let destination = segue.destination as? EventScheduleViewController {
            self.navigationController!.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            destination.classRef = classNameRef
            destination.courseName = classId
        } else if segue.identifier == notesSegueIdentifier,
            let destination = segue.destination as? NotesViewController {
            destination.className = classNameRef
            destination.classId = classId
        }
    }
}
