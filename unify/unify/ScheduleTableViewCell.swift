//
//  ScheduleTableViewCell.swift
//  unify
//
//  Created by Priya Patel on 5/7/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {

    @IBOutlet weak var scheduleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure() {
        scheduleLabel.textColor = JDColor.appText.color
    }

}
