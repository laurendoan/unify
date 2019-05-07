//
//  MembersPanelTableViewCell.swift
//  unify
//
//  Created by Priya Patel on 5/7/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit

class MembersPanelTableViewCell: UITableViewCell {

    @IBOutlet weak var membersLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure() {
        membersLabel.textColor = JDColor.appText.color
    }

}
