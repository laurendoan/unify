//
//  AppDelegate.swift
//  MessageKitTest
//
//  Created by Julian Ricky Moore on 4/2/19.
//  Copyright © 2019 JulianMoore. All rights reserved.
//

import UIKit
import MapKit
import MessageKit
import MessageInputBar
import Firebase
import UserNotifications

final class MessageViewController: MessagesViewController, MembersDelegate, NotesDelegate, LeaveClassProtocol, UNUserNotificationCenterDelegate {
    // Database reference.
    var ref = Database.database().reference()
    let user = Auth.auth().currentUser // Current user.
    
    // Instance variables for messages.
    var messageList: [Message] = []
    let refreshControl = UIRefreshControl()
    var className: String = ""
    var classID: String = ""
    var senderDisplayName: String?
    var sender : Sender? = nil
    
    // Instance variables for side panel.
    var navController = UINavigationController()
    var panelView = PanelViewController()
    var membersView = MembersViewController()
    var notesView = NotesViewController()
    var panelOut = false
    var panelState = -1 //-1: inside, 0: standard, 1: members
    
    let center = UNUserNotificationCenter.current() // Notification center.
    let chatAlerts = UserDefaults.standard.bool(forKey: "Chat Alerts") // Chat alerts switch.
    var mute = true // Mute switch.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title of chatroom.
        title = "\(classID)"
        
        // Disable avatars next to messages.
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.emojiMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.emojiMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.locationMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.locationMessageSizeCalculator.incomingAvatarSize = .zero
            layout.videoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.videoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.collectionView!.backgroundColor = JDColor.appSubviewBackground.color
        }
        
        configureMessageCollectionView()
        configureMessageInputBar()
        loadMessages()
        setupPanel()
        center.delegate = self
        self.messagesCollectionView.scrollToBottom(animated: true)
    }

    // Sets up side panel.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barTintColor = JDColor.appTabBarBackground.color
        navigationController?.navigationBar.tintColor = JDColor.appSubText.color
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:JDColor.appAccent.color]
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.collectionView!.backgroundColor = JDColor.appViewBackground.color
        }
        messageInputBar.contentView.backgroundColor = JDColor.appTabBarBackground.color
        messageInputBar.backgroundView.backgroundColor = JDColor.appTabBarBackground.color
        messageInputBar.inputTextView.textColor = JDColor.appSubText.color
        self.messagesCollectionView.scrollToBottom(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // Sets up side panel.
    func setupPanel() {
        //Currently, two things can be viewed in panel view: the standard panel class info page, and the members page.
        //At the start, these are both instantiated and placed with their left edges to the far right of the screen.
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "=", style: .plain, target: self, action: #selector(togglePanel)) //first create a button for the panel
        
        self.navigationItem.rightBarButtonItem?.image = UIImage(named: "icons8-menu-26.png")
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        panelView = storyboard.instantiateViewController(withIdentifier: "PanelViewController") as! PanelViewController
    
        //addChild(panelView)
        panelView.view.frame = CGRect(x: self.view.frame.width/3, y: 0, width: self.view.frame.width*2/3, height: self.view.frame.height) //want it 1/3 of the way across the screen so it's coming from the right
        
        panelView.tableView.rowHeight = 40
        panelView.tableView.frame = CGRect(x: 0, y: 100, width: 276, height: panelView.tableView.rowHeight * 5)
        //panelView.classNameLabel.text = className
        //panelView.classNameLabel.textAlignment = .center
        //panelView.classNameLabel.frame = CGRect(x: 0, y: 100, width: 276, height: 20)
        
        //self.view.insertSubview(panelView.view, at: 0)
        //self.view.bringSubviewToFront(panelView.view)
        
        panelView.delegate = self
        panelView.notesDelegate = self
        panelView.classNameRef = className
        panelOut = false
        
        
        notesView = storyboard.instantiateViewController(withIdentifier: "NotesViewController") as! NotesViewController
        notesView.view.frame = CGRect(x: self.view.frame.width/3, y: 0, width: self.view.frame.width*2/3, height: self.view.frame.height) //want it 1/3 of the way across the screen so it's coming from the right
        notesView.className = className
        notesView.classId = classID
        
        
        membersView = storyboard.instantiateViewController(withIdentifier: "MembersViewController") as! MembersViewController
        membersView.view.frame = CGRect(x: self.view.frame.width/3, y: 0, width: self.view.frame.width*2/3, height: self.view.frame.height) //want it 1/3 of the way across the screen so it's coming from the right
        membersView.className = self.className
        
        navController = UINavigationController(rootViewController: panelView)
        navController.view.frame = CGRect(x: self.view.frame.width/3, y: 0, width: self.view.frame.width*2/3, height: self.view.frame.height) //want it 1/3 of the way across the screen so it's coming from the right
        navController.navigationItem.title = className
        navController.interactivePopGestureRecognizer?.isEnabled = false
        panelView.title = classID
        
        addChild(navController)
        self.view.insertSubview(navController.view, at: 0)
        self.view.bringSubviewToFront(navController.view)
        navController.view.isHidden = true; //don't show it initially
        navController.view.frame = CGRect(x: self.view.frame.width, y: navController.view.frame.minY, width: navController.view.frame.width, height: navController.view.frame.height)
        navController.didMove(toParent: self)

        
        //panelView.view.isHidden = true; //don't show it initially
        //panelView.view.frame = CGRect(x: self.view.frame.width, y: panelView.view.frame.minY, width: panelView.view.frame.width, height: panelView.view.frame.height)
        //panelView.didMove(toParent: self)
        
//        membersView = storyboard.instantiateViewController(withIdentifier: "MembersViewController") as! MembersViewController
//        membersView.view.frame = CGRect(x: self.view.frame.width/3, y: 0, width: self.view.frame.width*2/3, height: self.view.frame.height) //want it 1/3 of the way across the screen so it's coming from the right
//
//        self.view.insertSubview(membersView.view, at: 0)
//        self.view.bringSubviewToFront(panelView.view)
//        membersView.view.frame = CGRect(x: self.view.frame.width, y: membersView.view.frame.minY, width: membersView.view.frame.width, height: membersView.view.frame.height)
//        //Arrange its components as well: the label and the tableView
//        membersView.membersLabel.frame = CGRect(x: panelView.view.frame.width/2 - membersView.membersLabel.frame.width/2, y: 50, width: membersView.membersLabel.frame.width, height: membersView.membersLabel.frame.height)
//        membersView.tableView.frame = CGRect(x: 0, y: 100, width: 276, height:  membersView.tableView.frame.height)
//        addChild(membersView)
//        membersView.didMove(toParent: self)
//
//        panelView.notesDelegate = self
//        notesView = storyboard.instantiateViewController(withIdentifier: "NotesViewController") as! NotesViewController
//        notesView.view.frame = CGRect(x: self.view.frame.width/3, y: 0, width: self.view.frame.width*2/3, height: self.view.frame.height) //want it 1/3 of the way across the screen so it's coming from the right
//
//        self.view.insertSubview(notesView.view, at: 0)
//        self.view.bringSubviewToFront(panelView.view)
//        notesView.view.frame = CGRect(x: self.view.frame.width, y: notesView.view.frame.minY, width: notesView.view.frame.width, height: notesView.view.frame.height)
//
//        membersView.className = self.className
//
//        panelView.classNameRef = self.className
//        panelView.classId = self.classID
        
        panelView.leaveClassDelegate = self
        panelView.className = className  // Pass in class name.
    }
    

    @IBAction func swipeRight(_ sender: Any) {
        //print("Swiped Right")
        togglePanel()
    }
    
    @IBAction func swipeLeft(_ sender: Any) {
        togglePanel()
    }
    
    @objc func togglePanel() {
        if(panelOut == false) {
            navController.view.isHidden = false
            panelOut = true
            navigationController?.setNavigationBarHidden(true, animated: true)
            messageInputBar.isHidden = true
            UIView.animate(withDuration: 0.3, animations: {
                self.navController.view.frame = CGRect(x: self.view.frame.width/3, y: self.navController.view.frame.minY, width: self.navController.view.frame.width, height: self.navController.view.frame.height)
            })
        }
        else {
            navigationController?.setNavigationBarHidden(false, animated: true)
            messageInputBar.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.navController.view.frame = CGRect(x: self.view.frame.width, y: self.navController.view.frame.minY, width: self.panelView.view.frame.width, height: self.panelView.view.frame.height)
            }, completion: {
                (value: Bool) in
                self.panelOut = false
            })
        }
        
        /*if(panelOut == false) {
            if(panelState == -1) { //just pull up the normal class info
                panelView.view.isHidden = false
                panelOut = true
                panelState = 0
                navigationController?.setNavigationBarHidden(true, animated: true)
                messageInputBar.isHidden = true
                UIView.animate(withDuration: 0.3, animations: {
                    self.panelView.view.frame = CGRect(x: self.view.frame.width/3, y: self.panelView.view.frame.minY, width: self.panelView.view.frame.width, height: self.panelView.view.frame.height)
                }, completion:  nil)
            }
        } else {
            if(panelState == 0) { //normal panel is out, slide it back
                self.membersView.view.frame = CGRect(x: self.view.frame.width, y: self.membersView.view.frame.minY, width: self.membersView.view.frame.width, height: self.membersView.view.frame.height) //move panel back even though it's invisible
                self.notesView.view.frame = CGRect(x: self.view.frame.width, y: self.notesView.view.frame.minY, width: self.notesView.view.frame.width, height: self.notesView.view.frame.height) //move panel back even though it's invisible
                navigationController?.setNavigationBarHidden(false, animated: true)
                messageInputBar.isHidden = false
                UIView.animate(withDuration: 0.3, animations: {
                    self.panelView.view.frame = CGRect(x: self.view.frame.width, y: self.panelView.view.frame.minY, width: self.panelView.view.frame.width, height: self.panelView.view.frame.height)
                    
                }, completion:  {
                    (value: Bool) in
                    self.panelView.view.isHidden = true
                    self.panelOut = false
                    self.panelState = -1
                })
            }
            else if(panelState == 1) { //members view is out, slide it back but hide panel as well and move it back
                self.panelView.view.frame = CGRect(x: self.view.frame.width, y: self.panelView.view.frame.minY, width: self.panelView.view.frame.width, height: self.panelView.view.frame.height) //move panel back even though it's invisible
                self.notesView.view.frame = CGRect(x: self.view.frame.width, y: self.notesView.view.frame.minY, width: self.notesView.view.frame.width, height: self.notesView.view.frame.height) //move panel back even though it's invisible
                navigationController?.setNavigationBarHidden(false, animated: true)
                messageInputBar.isHidden = false
                UIView.animate(withDuration: 0.3, animations: { //only thing changing is the x value so it moves across the screen
                    //self.panelView.view.alpha = 0
                    self.membersView.view.frame = CGRect(x: self.view.frame.width, y: self.membersView.view.frame.minY, width: self.membersView.view.frame.width, height: self.membersView.view.frame.height)
                    
                }, completion:  {
                    (value: Bool) in
                    self.membersView.view.isHidden = true
                    self.panelOut = false
                    self.panelState = -1
                })
            }
            else if(panelState == 2) { //notes view is out, slide it back
                self.panelView.view.frame = CGRect(x: self.view.frame.width, y: self.panelView.view.frame.minY, width: self.panelView.view.frame.width, height: self.panelView.view.frame.height) //move panel back even though it's invisible
                self.membersView.view.frame = CGRect(x: self.view.frame.width, y: self.membersView.view.frame.minY, width: self.membersView.view.frame.width, height: self.membersView.view.frame.height) //move panel back even though it's invisible
                navigationController?.setNavigationBarHidden(false, animated: true)
                messageInputBar.isHidden = false
                UIView.animate(withDuration: 0.3, animations: { //only thing changing is the x value so it moves across the screen
                    //self.panelView.view.alpha = 0
                    self.notesView.view.frame = CGRect(x: self.view.frame.width, y: self.notesView.view.frame.minY, width: self.notesView.view.frame.width, height: self.notesView.view.frame.height)
                    
                }, completion:  {
                    (value: Bool) in
                    self.notesView.view.isHidden = true
                    self.panelOut = false
                    self.panelState = -1
                })
            }
        }*/
        
    }

    func membersPressed() { //when the members button is pressed in the side panel
        navController.pushViewController(membersView, animated: true)
        /*panelView.view.isHidden = true
        notesView.view.isHidden = true
        membersView.view.isHidden = false //show correct view
        self.membersView.view.frame = CGRect(x: self.view.frame.width/3, y: self.membersView.view.frame.minY, width: self.membersView.view.frame.width, height: self.membersView.view.frame.height)
        self.view.bringSubviewToFront(membersView.view) //bring it to front
        panelState = 1 //update state so we know it's out*/
    }
    
    func notesPressed() {
        notesView.className = className
        notesView.classId = classID
        navController.pushViewController(notesView, animated: true)
        /*panelView.view.isHidden = true
        membersView.view.isHidden = true
        notesView.view.isHidden = false
        self.notesView.view.frame = CGRect(x: self.view.frame.width/3, y: self.notesView.view.frame.minY, width: self.notesView.view.frame.width, height: self.notesView.view.frame.height)
        self.view.bringSubviewToFront(notesView.view) //bring it to front
        panelState = 2 //update state so we know it's out*/
        
    }
    
    // Removes the user from the given class.
    func leaveClass(className: String) {
        // Retrieve user's course list from the database.
        ref.child("users").child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            var courses = value?["courses"] as? Array ?? []
            
            // Find the class to leave.
            var index = 0
            for course in courses {
                let courseName = course as? String
                if courseName == className {
                    courses.remove(at: index)
                    break
                }
                index += 1
            }
            
            // Update user's course list in the database.
            self.ref.child("users/\(self.user!.uid)/courses").setValue(courses)
            
            // Go back to Home page.
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    /*func backPressed() {
        print("back pressed")
        notesView.view.isHidden = true
        panelView.view.isHidden = false
        self.panelView.view.frame = CGRect(x: self.view.frame.width/3, y: self.panelView.view.frame.minY, width: self.panelView.view.frame.width, height: self.panelView.view.frame.height)
        self.view.bringSubviewToFront(panelView.view)
        panelState = 0
        
    }*/
    
    // sets style for status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // sets up basic configurations for messages collection view
    func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    // initializes the input bar for messages
    func configureMessageInputBar() {
        messageInputBar.delegate = self
    }
    
    // loads messages for chat room
    func loadMessages() {
        // Chat room database reference.
        let databaseClass = Constants.refs.databaseChats.child(className)
        let senderId = Auth.auth().currentUser!.uid
        
        // Reads in messages from specific class and inserts them into messages list to be displayed.
        // Observer remains active to allow new messages from other users to display
        let ref = Constants.refs.databaseUsers
        ref.child(senderId).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.senderDisplayName = value?["displayName"] as? String ?? ""
            self.sender = Sender(id: senderId, displayName: self.senderDisplayName!)
            let query = databaseClass.queryLimited(toLast: 30)
            
            _ = query.observe(.childAdded, with: { [weak self] snapshot in
                
                if  let data        = snapshot.value as? [String: String],
                    let id          = data["sender_id"],
                    let name        = data["name"],
                    let text        = data["text"],
                    let messageId   = data["message_id"],
                    let interval    = data["date"],
                    !text.isEmpty
                {
                    let date = Date(timeIntervalSince1970: Double(interval)!)
                    let message = Message(text: text, sender: Sender(id: id, displayName: name), messageId: messageId, date: date)
                    self?.insertMessage(message)
                    self?.messagesCollectionView.scrollToBottom(animated: true)
                }
            })
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // TODO: Load more messages upon scrolling to the top of messages screen
    @objc
    func loadMoreMessages() {
        
    }
    
    // MARK: - Helpers
    
    // inserts message into list and updates view
    func insertMessage(_ message: Message) {
        messageList.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    // checks if last section is visible for scrolling to bottom
    func isLastSectionVisible() -> Bool {
        
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
}

// MARK: - MessagesDisplayDelegate

extension MessageViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    // selects text color depending on who sent message.
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    // sets message background color depending on who sent message
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? JDColor.appAccent.color : UIColor(red: 230/255, green: 241/255, blue: 253/255, alpha: 1)
    }
    
    // sets bubble tail direction depending on who sent message
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
}

// MARK: - MessagesLayoutDelegate

extension MessageViewController: MessagesLayoutDelegate {
    
    // hides extra height for avatars
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    // sets height above message for name
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    // sets height below message for time
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
}

extension MessageViewController: MessagesDataSource {
    // returns the current sender
    func currentSender() -> Sender {
        return sender!
    }
    
    // returns number of messages in chat
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    // returns message for given section
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    // sets display name style above message
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1), NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
    }
    
    // sets date and date style below message
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let date = message.sentDate
        let calendar = Calendar.current
        var hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        var minutesString = "00"
        if(minutes < 10)
        {
            minutesString = "0\(minutes)"
        }
        else
        {
            minutesString = "\(minutes)"
        }
        var hoursString = "00"
        if(hour < 12)
        {
            hoursString = "\(hour)"
            minutesString += " am"
        }
        else if (hour > 12)
        {
            hour -= 12
            hoursString = "\(hour)"
            minutesString += " pm"
        }
        else
        {
            hoursString = "\(hour)"
            minutesString += " pm"
        }
        let dateString = hoursString + ":" + minutesString
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2), NSAttributedString.Key.foregroundColor : JDColor.appSubText.color])
    }
}

extension MessageViewController: MessageInputBarDelegate {
    
    // handles message sending upon pressing send
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // generates message object and writes to database.
        for component in inputBar.inputTextView.components {
            let current = currentSender()
            if let str = component as? String {
                let message = Message(text: str, sender: current, messageId: UUID().uuidString, date: Date())
                let ref = Constants.refs.databaseChats.child(className).childByAutoId()
                let newMessage = ["sender_id": current.id, "name": current.displayName, "text": str, "message_id": message.messageId, "date": String(Date().timeIntervalSince1970)]
                ref.setValue(newMessage)
                
                mute = UserDefaults.standard.bool(forKey: "Mute \(className)")
                if chatAlerts && !mute {
                    // Create action for notification.
                    let replyAction = UNTextInputNotificationAction(
                        identifier: "reply",
                        title: "Reply",
                        options: [],
                        textInputButtonTitle: "Send",
                        textInputPlaceholder: "Message"
                    )
                    
                    // Create category for action.
                    let notificationCategory = UNNotificationCategory(
                        identifier: "notificationCategory",
                        actions: [replyAction],
                        intentIdentifiers: [],
                        options: []
                    )
                    
                    center.setNotificationCategories([notificationCategory])
                    
                    // Create notification.
                    let notification = UNMutableNotificationContent()
                    notification.title = classID
                    notification.subtitle = current.displayName
                    notification.body = str
                    notification.categoryIdentifier = "notificationCategory"
                    notification.sound = UNNotificationSound.default
                    
                    // Trigger the notification after 5 seconds.
                    let delay: TimeInterval = 5.0
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
                    
                    // Create request to submit notification.
                    let request = UNNotificationRequest(identifier: "notification", content: notification, trigger: trigger)
                    
                    // Submit request.
                    center.add(request) { error in
                        if let e = error {
                            print("Add request error: \(e)")
                        }
                    }
                }
            }
        }
        // refreshes message bar
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
    // Handles "reply" action in message notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.actionIdentifier
//        let request = response.notification.request
        
        if identifier == "reply" {
            let textResponse = response as! UNTextInputNotificationResponse
            let message = textResponse.userText
            
            // Add new message to database.
            let currentUser = currentSender()
            let databaseRef = Constants.refs.databaseChats.child(className).childByAutoId()
            let newMessage = ["sender_id": currentUser.id, "name": currentUser.displayName, "text": message, "message_id": UUID().uuidString, "date": String(Date().timeIntervalSince1970)]
            databaseRef.setValue(newMessage)
        }
        
        completionHandler()
    }
    
}

