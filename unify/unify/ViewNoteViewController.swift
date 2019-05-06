//
//  ViewNoteViewController.swift
//  MessageKitTest
//
//  Created by Julian Ricky Moore on 4/6/19.
//  Copyright © 2019 JulianMoore. All rights reserved.
//

import UIKit

class ViewNoteViewController: UIViewController {
    
    // instance variables
    @IBOutlet weak var imageView: UIImageView!
    var newImage: UIImage? = UIImage()
    var backButtonSegueIdentifier = "backButtonSegueIdentifier"
    var className = ""
    var classId = ""
    
    // sets up initial view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // display image selected
        imageView.image = newImage
        imageView.contentMode = .scaleAspectFit

        // Set title
        self.navigationController?.isNavigationBarHidden = false
        title = "View Note"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.view.backgroundColor = JDColor.appViewBackground.color
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.parent?.view.frame = CGRect(x: self.view.frame.width/3, y: 0, width: self.view.frame.width*2/3, height: self.view.frame.height) //want it 1/3 of the way across the screen so it's coming from the right
    }
    
    // allows saving to user photo gallery
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        UIImageWriteToSavedPhotosAlbum(newImage!, nil, nil, nil);
    }
    
}
