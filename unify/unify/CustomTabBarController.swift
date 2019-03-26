//
//  CustomTabBarController.swift
//  unify
//
//  Created by Lauren Doan on 3/26/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the default VC to index 1 of the tab bar.
        selectedIndex = 1
    }
}
