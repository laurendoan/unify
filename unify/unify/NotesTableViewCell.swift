//
//  NotesTableViewCell.swift
//  unify
//
//  Created by Priya Patel on 5/7/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit

class NotesTableViewCell: UITableViewCell {

    @IBOutlet weak var notesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure() {
        notesLabel.textColor = JDColor.appText.color
    }
}
