//
//  HistoryTableViewCell.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-04-01.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    
    @IBOutlet weak var trailName: UILabel!
    @IBOutlet weak var completedDate: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
