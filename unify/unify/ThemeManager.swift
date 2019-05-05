//
//  ThemeManager.swift
//  unify
//
//  Created by Priya Patel on 5/4/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import Foundation

class ThemeManager {
    
    static let sharedThemeManager = ThemeManager()
    
    func toggleTheme() {
        let def = UserDefaults.standard
        def.set(!isNightMode(), forKey: "Theme")
    }
    
    func isNightMode() -> Bool {
        let def = UserDefaults.standard
        return def.bool(forKey: "Theme")
    }
}
