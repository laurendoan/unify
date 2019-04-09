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
    
    /* Initialized variables */
    let formatter = DateFormatter()
    var ref: DatabaseReference!
    var courses: [String] = [] // User's list of courses.
    var courseTitles: [String] = [] // Used to display in table view.
    //var contents = [EventContent]()
    var clickedDateContent = [EventContent]()
    var clickedDate = ""
    
    /* Default Colors (Will clean up later) */
    let monthTextColor = UIColor(red: 63/255, green: 75/255, blue: 79/255, alpha: 1)
    let nonMonthTextColor = UIColor(red: 218/255, green: 235/255, blue: 237/255, alpha: 1)
    let outsideMonthColor = UIColor(red: 227/255, green: 240/255, blue: 255/255, alpha: 1)
    let calendarBGColor = UIColor(red: 165/255, green: 206/255, blue: 254/255, alpha: 1)
    let selectedDateColor = UIColor.black
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        
        // Database reference
        ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        
        // Sets the background color.
        UIColourScheme.instance.set(for:self)
        
        // Sets up the calendar
        setupCalendarView()
        
        // Immediately scrolls to current date and selects it
        let currentDate = Date()
        calendarView.scrollToDate(currentDate)
        calendarView.selectDates([currentDate])
        
        // Retrieve courses from database, store in courses & courseTitles array.
        ref.child("users").child(userID!).child("courses").observe(.value, with: { (snapshot) in
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
        
        // Darkens the current date. Otherwise, revert back to original color
        // JK. doesn't work yet
        let todaysDate = Date()
        formatter.dateFormat = "yyyy MM dd"
        let todaysDateString = formatter.string(from: todaysDate)
        let monthDateString = formatter.string(from: cellState.date)
        if todaysDateString == monthDateString {
            validCell.dataLabel.textColor = UIColor.blue
        } else {
            validCell.dataLabel.textColor = cellState.isSelected ?
                monthTextColor : nonMonthTextColor
        }
        
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
        
        // Reformats current date
        formatter.dateFormat = "MM-dd-yyyy"
        let currentDate = formatter.string(from: date)
        clickedDate = currentDate.replacingOccurrences(of: "-", with: "")
        
        print(clickedDate)
        
        // user UID
        self.clickedDateContent.removeAll()
        
        // Checks if there's any content for that date
        for index in 0 ..< courses.count {
            ref.child("schedule").child(courses[index]).observeSingleEvent(of: .value, with: {
                (snapshot) in
                if snapshot.hasChild(self.clickedDate) {
                    // Observes all children under specific date
                    self.ref.child("schedule").child(self.courses[index]).child(self.clickedDate)                    .observe(DataEventType.value) { (snapshot) in
                        // Iterates through the number of children
                        for i in snapshot.children.allObjects as! [DataSnapshot] {
                            // Pulls data from each child (name of course, course id, and the instructor)
                            let Object = i.value as? [String: AnyObject]
                            let name = Object?["name"]
                            let location = Object?["location"]
                            let date = Object?["date"]
                            let time = Object?["time"]
                            
                            // Adds classes to the array of 'courses'
                            let c = EventContent(name: name as? String,
                                                 location: location as? String,
                                                 date: date as? String,
                                                 time: time as? String,
                                                 course: self.courseTitles[index])
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
        
        let row = indexPath.row
        let n = String(clickedDateContent[row].name!)
        let l = String(clickedDateContent[row].location!)
        let t = String(clickedDateContent[row].time!)
        let title = String(clickedDateContent[row].course!)
        cell.eventNameLabel.text = "\(n) (\(t))"
        cell.descriptionLabel.text = "Location: \(l)"
        cell.titleLabel.text = "\(title)"
        
        return cell
    }
}
