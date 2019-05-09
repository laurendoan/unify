//
//  ViewNoteViewController.swift
//  MessageKitTest
//
//  Created by Julian Ricky Moore on 4/6/19.
//  Copyright © 2019 JulianMoore. All rights reserved.
//

import UIKit

class ViewNoteViewController: UIViewController {
    
    // Instance variables.
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var newImage: UIImage? = UIImage()
    var backButtonSegueIdentifier = "backButtonSegueIdentifier"
    var className = ""
    var classId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Display image selected.
        imageView.image = newImage
        imageView.contentMode = .scaleAspectFit

        // Set title.
        self.navigationController?.isNavigationBarHidden = false
        title = "View Note"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show navigation bar when view appears.
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Set backgrounnd color.
        self.view.backgroundColor = JDColor.appViewBackground.color
        
        // Customize toolbar colors.
        self.toolbar.barTintColor = JDColor.appTabBarBackground.color
        self.toolbar.tintColor = JDColor.appAccent.color
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Want it 1/3 of the way across the screen so it's coming from the right.
        self.parent?.view.frame = CGRect(x: self.view.frame.width/3, y: 0, width: self.view.frame.width*2/3, height: self.view.frame.height)
    }
    
    // Allows saving to user photo gallery.
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        UIImageWriteToSavedPhotosAlbum(newImage!, nil, nil, nil);
    }
    
}
