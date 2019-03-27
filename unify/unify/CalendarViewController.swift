//
//  CalendarViewController.swift
//  unify
//
//  Created by Lauren Doan on 3/26/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the background color.
        UIColourScheme.instance.set(for:self)
    }
    
    // Hides the navigation bar when the view appears.
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
