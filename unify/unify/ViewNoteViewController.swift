//
//  ViewNoteViewController.swift
//  MessageKitTest
//
//  Created by Julian Ricky Moore on 4/6/19.
//  Copyright © 2019 JulianMoore. All rights reserved.
//

import UIKit

class ViewNoteViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var newImage: UIImage? = UIImage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = newImage
        imageView.contentMode = .scaleAspectFit
        
        // Sets the background color.
        UIColourScheme.instance.set(for:self)
        // Set title of chatroom.
        self.navigationController?.isNavigationBarHidden = false
        title = "View Note"
    }
    
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        UIImageWriteToSavedPhotosAlbum(newImage!, nil, nil, nil);
    }
    
}
