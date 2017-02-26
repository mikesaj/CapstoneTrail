//
//  TrailTableViewCell.swift
//  CapstoneTrail
//
//  Created by Joohyung Ryu on 2017. 2. 22..
//  Copyright © 2017년 MSD. All rights reserved.
//

import UIKit


class TrailTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var areaLogoImage: UIImageView!
    @IBOutlet weak var streetNameLabel: UILabel!
    @IBOutlet weak var trailBriefLabel: UILabel!


    override func awakeFromNib() {

        super.awakeFromNib()
    }


    override func setSelected(_ selected: Bool, animated: Bool) {

        super.setSelected(selected, animated: animated)
    }
}
