//
//  CalendarTableViewCell.swift
//  unify
//
//  Created by David Do on 4/6/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit

class CalendarTableViewCell: UITableViewCell {
    /* Initialized Outlets */
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
