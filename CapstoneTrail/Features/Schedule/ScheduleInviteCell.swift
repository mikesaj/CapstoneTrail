//
//  ScheduleInvitationViewCell.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-03-05.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit

class ScheduleInviteCell: UITableViewCell {

    // labels
    @IBOutlet weak var scheduleTitle: UILabel!
    @IBOutlet weak var scheduleTime: UILabel!
    
    // buttons
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
