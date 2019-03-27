//
//  UIColorScheme.swift
//  unify
//
//  Created by David Do on 3/26/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import Foundation

class UIColourScheme {
    static let instance = UIColourScheme()
    
    // Sets the background color.
    func set(for viewController: UIViewController) {
        viewController.view.backgroundColor =
            UIColor(red: 230/255, green: 241/255, blue: 253/255, alpha: 1)
    }
}
