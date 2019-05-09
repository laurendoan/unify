//
//  MuteTableViewCell.swift
//  unify
//
//  Created by Saarila Kenkare on 4/8/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit

class MuteTableViewCell: UITableViewCell {
    @IBOutlet weak var muteSwitch: UISwitch!
    @IBOutlet weak var muteLabel: UILabel!
    
    let userDefaults = UserDefaults.standard
    var mute = true
    var courseName = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(courseName: String) {
        self.courseName = courseName
        // Display switch based on previous toggle stored in userDefaults.
        mute = userDefaults.bool(forKey: "Mute \(courseName)")
        muteSwitch.setOn(mute, animated: true)
        // Set color of mute label.
        muteLabel.textColor = JDColor.appText.color
    }
    
    // Set mute switch state in userDefaults when toggled.
    @IBAction func muteSwitchToggled(_ sender: Any) {
        mute = muteSwitch.isOn
        userDefaults.set(mute, forKey: "Mute \(courseName)")
    }
}
