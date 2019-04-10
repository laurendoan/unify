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

final class MessageViewController: MessagesViewController, MembersDelegate, LeaveClassProtocol {

   // sets style for status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // instance variables for side panel
    var panelView = PanelViewController()
    var membersView = MembersViewController()
    var panelOut = false
    var panelState = -1 //-1: inside, 0: standard, 1: members
    
    // instance variables for messages
    var messageList: [Message] = []
    let refreshControl = UIRefreshControl()
    var className: String = ""
    var classID: String = ""
    var senderDisplayName: String?
    var sender : Sender? = nil
    
    // Database reference.
    var ref = Database.database().reference()
    let user = Auth.auth().currentUser // Current user.
    let leaveClassSegueIdentifier = "leaveClassSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title of chatroom.
        self.navigationController?.isNavigationBarHidden = false
        title = "\(classID)"
        
        // disable avatars next to messages
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
        }
        
        configureMessageCollectionView()
        configureMessageInputBar()
        loadMessages()
        
    }
    
    // sets up side panel and enables nav bar
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        setupPanel()
    }
    
    // sets up the side panel functionality
    func setupPanel() {
        //Currently, two things can be viewed in panel view: the standard panel class info page, and the members page.
        //At the start, these are both instantiated and placed with their left edges to the far right of the screen.
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "=", style: .plain, target: self, action: #selector(togglePanel)) //first create a button for the panel
        
        self.navigationItem.rightBarButtonItem?.image = UIImage(named: "icons8-menu-26.png")
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        panelView = storyboard.instantiateViewController(withIdentifier: "PanelViewController") as! PanelViewController
    
        addChild(panelView)
        panelView.view.frame = CGRect(x: self.view.frame.width/3, y: 0, width: self.view.frame.width*2/3, height: self.view.frame.height) //want it 1/3 of the way across the screen so it's coming from the right
        
        panelView.tableView.rowHeight = 40
        panelView.tableView.frame = CGRect(x: 0, y: 100, width: 276, height: panelView.tableView.rowHeight * 5)
        
        self.view.insertSubview(panelView.view, at: 0)
        self.view.bringSubviewToFront(panelView.view)
        
        panelView.delegate = self
        panelOut = false
        panelView.view.isHidden = true; //don't show it initially
        panelView.view.frame = CGRect(x: self.view.frame.width, y: panelView.view.frame.minY, width: panelView.view.frame.width, height: panelView.view.frame.height)
        panelView.didMove(toParent: self)
        
        membersView = storyboard.instantiateViewController(withIdentifier: "MembersViewController") as! MembersViewController
        membersView.view.frame = CGRect(x: self.view.frame.width/3, y: 50, width: self.view.frame.width*2/3, height: self.view.frame.height) //want it 1/3 of the way across the screen so it's coming from the right
        
        self.view.insertSubview(membersView.view, at: 0)
        self.view.bringSubviewToFront(panelView.view)
        membersView.view.frame = CGRect(x: self.view.frame.width, y: membersView.view.frame.minY, width: membersView.view.frame.width, height: membersView.view.frame.height)
        //Arrange its components as well: the label and the tableView
        membersView.membersLabel.frame = CGRect(x: panelView.view.frame.width/2 - membersView.membersLabel.frame.width/2, y: 50, width: membersView.membersLabel.frame.width, height: membersView.membersLabel.frame.height)
        membersView.tableView.frame = CGRect(x: 0, y: 100, width: 276, height:  membersView.tableView.frame.height)
        membersView.className = self.className

        panelView.classNameRef = self.className
        panelView.classId = self.classID
        
        panelView.leaveClassDelegate = self
        panelView.className = className // Pass in class name.
    }
    
    @objc func togglePanel() {
        if(panelOut == false) {
            if(panelState == -1) { //just pull up the normal class info
                panelView.view.isHidden = false
                panelOut = true
                panelState = 0
                UIView.animate(withDuration: 0.3, animations: {
                    self.panelView.view.frame = CGRect(x: self.view.frame.width/3, y: self.panelView.view.frame.minY, width: self.panelView.view.frame.width, height: self.panelView.view.frame.height)
                }, completion:  nil)
            }
        }
        else {
            if(panelState == 0) { //normal panel is out, slide it back
                self.membersView.view.frame = CGRect(x: self.view.frame.width, y: self.membersView.view.frame.minY, width: self.membersView.view.frame.width, height: self.membersView.view.frame.height) //move panel back even though it's invisible
                UIView.animate(withDuration: 0.3, animations: {
                    self.panelView.view.frame = CGRect(x: self.view.frame.width, y: self.panelView.view.frame.minY, width: self.panelView.view.frame.width, height: self.panelView.view.frame.height)
                    
                }, completion:  {
                    (value: Bool) in
                    self.panelView.view.isHidden = true
                    self.panelOut = false
                    self.panelState = -1
                })
            }
            else if(panelState == 1){ //members view is out, slide it back but hide panel as well and move it back
                self.panelView.view.frame = CGRect(x: self.view.frame.width, y: self.panelView.view.frame.minY, width: self.panelView.view.frame.width, height: self.panelView.view.frame.height) //move panel back even though it's invisible
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
        }
        
    }

    func membersPressed() { //when the members button is pressed in the side panel
        panelView.view.isHidden = true
        membersView.view.isHidden = false //show correct view
        self.membersView.view.frame = CGRect(x: self.view.frame.width/3, y: self.membersView.view.frame.minY, width: self.membersView.view.frame.width, height: self.membersView.view.frame.height)
        self.view.bringSubviewToFront(membersView.view) //bring it to front
        panelState = 1 //update state so we know it's out
    }
    
    // Removes the user from the given class.
    func leaveClass(className: String) {
        print("Leaving a class...")
        ref.child("users").child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            var courses = value?["courses"] as? Array ?? []
            
            print("Before: \(courses)")
            
            var index = 0
            for course in courses {
                let courseName = course as? String
                if courseName == className {
                    courses.remove(at: index)
                    break
                }
                index += 1
            }
            
            self.ref.child("users").child(self.user!.uid).setValue(["courses": courses])
            print("Removed: \(courses)")
            
            // Return to the home page once the class is removed.
            self.performSegue(withIdentifier: self.leaveClassSegueIdentifier, sender: nil)
            
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
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.sendButton.tintColor = .primaryColor
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
            let query = databaseClass.queryLimited(toLast: 20)
            
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
        return isFromCurrentSender(message: message) ? .primaryColor : UIColor(red: 230/255, green: 241/255, blue: 253/255, alpha: 1)
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
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    // sets date and date style below message
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let date = message.sentDate
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let dateString: String = "\(hour):\(minutes)"
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
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
            }
        }
        // refreshes message bar
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
}

