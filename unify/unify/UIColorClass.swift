//
//  UIColorClass.swift
//  unify
//
//  Created by Priya Patel on 5/4/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

// This code was taken from a tutorial.

import Foundation
import UIKit

@objcMembers

class JDColorHelper: NSObject {
    class func getColor(dhColor: JDColor) -> UIColor {
        return dhColor.color
    }
}

struct ThemeColor {
    let light: UInt32 // Light mode.
    let dark: UInt32 // Dark mode.
}

@objc enum JDColor : Int {
    case appText  = 1 // Text.
    case appSubText = 2 // Subtext.
    case appTabBarBackground = 3 // Tab bar background.
    case appTabSwipeBackground = 4 // Tab swipe background.
    case appViewBackground = 5 // View background.
    case appSubviewBackground = 6 // Side panel background.
    
    // Add more colors below if necessary.
    case appCalendarText = 7 // Calendar text.
    case appAccent = 8 // Blue accent color.
}

extension JDColor {
    private var themeColor: ThemeColor {
        switch self {
            case .appText:
                return ThemeColor(light: 0x181818, dark: 0xE3E3E3)
            case .appSubText:
                return ThemeColor(light: 0xA0A0A0, dark: 0xA0A0A0)
            case .appTabBarBackground:
                return ThemeColor(light: 0xF7F7F7, dark: 0x333333)
            case .appTabSwipeBackground:
                return ThemeColor(light: 0xF7F7F7, dark: 0x505050)
            case .appViewBackground:
                return ThemeColor(light: 0xeaeaef, dark: 0x2B2B2B)
            case .appSubviewBackground:
                return ThemeColor(light: 0xFFFFFF, dark: 0x4e4e4e)
            case .appCalendarText:
                return ThemeColor(light: 0xFFFFFF, dark: 0x2B2B2B)
            case .appAccent:
                return ThemeColor(light: 0x00CBFF, dark: 0x00CBFF)
            // Add more colors here.
        }
    }
    
    var color: UIColor {
        return UIColor(hex6: ThemeManager.sharedThemeManager.isNightMode() ? themeColor.dark : themeColor.light)
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hexString: String = (hexString as NSString).trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString as String)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    /**
     Creates an UIColor Object based on provided RGB value in integer
     - parameter red:   Red Value in integer
     - parameter green: Green Value in integer
     - parameter blue:  Blue Value in integer
     - returns: UIColor with specified RGB
     */
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
}

extension UIColor {
    public convenience init(hex6: UInt32, alpha: CGFloat = 1) {
        let divisor = CGFloat(255)
        let red     = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
        let green   = CGFloat((hex6 & 0x00FF00) >>  8) / divisor
        let blue    = CGFloat( hex6 & 0x0000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
