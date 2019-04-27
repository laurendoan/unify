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
    var color = UIColor(red: 229/255, green: 243/255, blue: 255/255, alpha: 1)
    
    // Sets the background color.
    func set(for viewController: UIViewController) {
        viewController.view.backgroundColor = color
    }
    
    func switchColor () {
        if color == (UIColor(red: 229/255, green: 243/255, blue: 255/255, alpha: 1)) {
            color = UIColor(red: 51/255, green: 65/255, blue: 76/255, alpha: 1)
        }
        else {
            color = UIColor(red: 229/255, green: 243/255, blue: 255/255, alpha: 1)
        }
    }
    
}

extension UIColor {
    static let primaryColor = UIColor(red: 228/255, green: 142/255, blue: 129/255, alpha: 1)
}
