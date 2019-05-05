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
        self.view.backgroundColor = JDColor.appSubviewBackground.color
    }
    
    // allows saving to user photo gallery
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        UIImageWriteToSavedPhotosAlbum(newImage!, nil, nil, nil);
    }
    
}
