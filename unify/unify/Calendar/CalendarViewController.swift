//
//  CalendarViewController.swift
//  unify
//
//  Created by Lauren Doan on 3/26/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Firebase

class CalendarViewController: UIViewController {
    /* Initialized Outlets*/
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabelTF: UILabel!
    @IBOutlet weak var sun: UILabel!
    @IBOutlet weak var mon: UILabel!
    @IBOutlet weak var tue: UILabel!
    @IBOutlet weak var wed: UILabel!
    @IBOutlet weak var thu: UILabel!
    @IBOutlet weak var fri: UILabel!
    @IBOutlet weak var sat: UILabel!
    
    /* Initialized variables */
    let changeEventIdentifier = "changeEventSegue"
    let formatter = DateFormatter()
    var ref: DatabaseReference!
    var userID: String!
    var courses: [String] = [] // User's list of courses.
    var courseTitles: [String] = [] // Used to display in table view.
    var clickedDateContent = [EventContent]()
    var selectedContent: EventContent!
    var clickedDate = ""
    
    /* Default Colors */
    var monthTextColor = JDColor.appText.color
    var nonMonthTextColor = JDColor.appSubText.color
    var selectedDateColor = JDColor.appAccent.color
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        
        // Database reference
        ref = Database.database().reference()
        userID = Auth.auth().currentUser?.uid
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hides the navigation bar when the view appears.
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Set background color.
        self.view.backgroundColor = JDColor.appViewBackground.color
        
        /// Customize Tab Bar colors.
        self.tabBarController?.tabBar.barTintColor = JDColor.appTabBarBackground.color
        self.tabBarController?.tabBar.tintColor = JDColor.appAccent.color
        self.tabBarController?.tabBar.unselectedItemTintColor = JDColor.appSubText.color
        
        // Sets up the text colors
        monthTextColor = JDColor.appText.color
        nonMonthTextColor = JDColor.appSubText.color
        month.textColor = JDColor.appAccent.color
        year.textColor = JDColor.appAccent.color
        dateLabelTF.textColor = JDColor.appText.color
        sun.textColor = JDColor.appText.color
        mon.textColor = JDColor.appText.color
        tue.textColor = JDColor.appText.color
        wed.textColor = JDColor.appText.color
        thu.textColor = JDColor.appText.color
        fri.textColor = JDColor.appText.color
        sat.textColor = JDColor.appText.color
        
        // Resets the VC for a fresh start
        courses.removeAll()
        courseTitles.removeAll()
        clickedDateContent.removeAll()
        
        // Retrieve courses from database, store in courses & courseTitles array.
        ref.child("users").child(userID!).child("courses").observeSingleEvent(of: .value, with: { (snapshot) in
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
        self.tableView.reloadData()
        self.calendarView.reloadData()
        
        // Sets up the calendar
        setupCalendarView()
        
        // Immediately scrolls to current date and selects it
        let currentDate = Date()
        calendarView.scrollToDate(currentDate)
        calendarView.selectDates([currentDate])
    }
    
    /* Additional aid in structuring the Calendar */
    func setupCalendarView() {
        // Sets up calendar spacing
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        // Sets up Label
        calendarView.visibleDates{ (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
    }
    
    /* Selection handles for dates */
    func handleCellSelected (view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CustomCell else { return }
        
        if cellState.isSelected {
            validCell.selectedView.isHidden = false
        } else {
            validCell.selectedView.isHidden = true
        }
    }
    
    /* Coloring handles for dates */
    func handleCellTextColor (view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CustomCell else { return }
        
        // Configures colors between selected, month dates, and non-month dates
        if cellState.isSelected {
            validCell.dataLabel.textColor = selectedDateColor
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                validCell.dataLabel.textColor = monthTextColor
            } else {
                validCell.dataLabel.textColor = nonMonthTextColor
            }
        }
    }
    
    /* Helper function to setup the Months and Years */
    func setupViewsOfCalendar (from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        
        formatter.dateFormat = "yyyy"
        year.text = formatter.string(from: date)
        
        formatter.dateFormat = "MMMM"
        month.text = formatter.string(from: date)
    }
    
    // Prepares for segue to MessagesVC.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == changeEventIdentifier,
            let destination = segue.destination as? ChangeEventViewController {
            destination.contentHolder = selectedContent
        }
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    /* Sets the Calendar range */
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        // Formats the formatter's structures and specific data
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        // Sets the startDate and endDate range
        let startDate = formatter.date(from: "2019 01 01")!
        let endDate = formatter.date(from: "2019 12 31")!
        
        // Configures the dates and returns the Calendar's range
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let myCustomCell = calendar.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        self.calendar(calendar, willDisplay: myCustomCell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        
        return myCustomCell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        sharedFunctionToConfigureCell(myCustomCell: cell as! CustomCell, cellState: cellState, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView,
                  didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        
        // Reformats current date for usage in Database
        formatter.dateFormat = "MM-dd-yyyy"
        let currentDate = formatter.string(from: date)
        clickedDate = currentDate.replacingOccurrences(of: "-", with: "")
        
        // Reformats current date for usage by dateLabelTF
        formatter.dateFormat = "EEEE, MMMM dd"
        let labelDate = formatter.string(from: date)
        dateLabelTF.text = labelDate
        
        // Empties array for usage
        self.clickedDateContent.removeAll()
        
        // Checks if there's any content for that date
        for index in 0 ..< courses.count {
            ref.child("schedule").child(courses[index]).observeSingleEvent(of: .value, with: {
                (snapshot1) in
                if snapshot1.hasChild(self.clickedDate) {
                    // Observes all children under specific date
                    self.ref.child("schedule").child(self.courses[index]).child(self.clickedDate).observeSingleEvent(of: DataEventType.value) { (snapshot2) in
                        // Iterates through the number of children
                        for i in snapshot2.children.allObjects as! [DataSnapshot] {
                            // Pulls data from each child (name of course, course id, the instructor, etc)
                            let Object = i.value as? [String: AnyObject]
                            let name = Object?["name"]
                            let location = Object?["location"]
                            let date = Object?["date"]
                            let start = Object?["start"]
                            let end = Object?["end"]
                            
                            // Adds classes to the array of 'courses'
                            let c = EventContent(name: name as? String,
                                                 location: location as? String,
                                                 date: date as? String,
                                                 start: start as? String,
                                                 end: end as? String,
                                                 course: self.courseTitles[index],
                                                 courseRef: self.courses[index],
                                                 parentRef: i.key)
                            self.clickedDateContent.append(c)
                            self.tableView.reloadData()
                        }
                    }
                } else {
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView,
                  didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView,
                  didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
    
    /* Helper function to configurate cells */
    func sharedFunctionToConfigureCell(myCustomCell: CustomCell, cellState: CellState, date: Date) {
        myCustomCell.dataLabel.text = cellState.text
        handleCellSelected (view: myCustomCell, cellState: cellState)
        handleCellTextColor (view: myCustomCell, cellState: cellState)
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clickedDateContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CalendarTableViewCell = tableView.dequeueReusableCell(withIdentifier: "calendarTableViewIdentifier", for: indexPath as IndexPath) as! CalendarTableViewCell
        
        // Sets up the variables for usage
        let row = indexPath.row
        let n = String(clickedDateContent[row].name!)
        let l = String(clickedDateContent[row].location!)
        let sT = String(clickedDateContent[row].start!)
        let eT = String(clickedDateContent[row].end!)
        let title = String(clickedDateContent[row].course!)
        
        // Sets the labels to the assign variables
        cell.eventNameLabel.text = "\(n) (\(sT) - \(eT))"
        cell.descriptionLabel.text = "Location: \(l)"
        cell.titleLabel.text = "\(title)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        selectedContent = clickedDateContent[row]
        self.performSegue(withIdentifier: changeEventIdentifier, sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            let row = indexPath.row
            selectedContent = clickedDateContent[row]
            self.ref.child("schedule").child(selectedContent.courseRef!).child(selectedContent.date!)
                .child(selectedContent.parentRef!).removeValue()
            clickedDateContent.remove(at: row)
            self.tableView.reloadData()
            self.calendarView.reloadData()
        }
    }
}
