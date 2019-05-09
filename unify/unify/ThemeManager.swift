//
//  ThemeManager.swift
//  unify
//
//  Created by Priya Patel on 5/4/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

// This code was taken from a tutorial.

import Foundation

class ThemeManager {
    
    static let sharedThemeManager = ThemeManager()
    
    // Toggles dark mode.
    func toggleTheme() {
        let def = UserDefaults.standard
        def.set(!isNightMode(), forKey: "Theme")
    }
    
    // Returns the dark mode key from user defaults.
    func isNightMode() -> Bool {
        let def = UserDefaults.standard
        return def.bool(forKey: "Theme")
    }
}
