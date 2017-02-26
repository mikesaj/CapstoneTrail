//
//  GroupModel.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-20.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit

class GroupModel: NSObject {
    
    var uid:              String?
    var name:             String?
    var isPublic:         Bool?
    var locationName:     String?
    var groupDescription: String?
    var longitude:        String?
    var latitude:         String?
    var members =        [String]()
    var userInvitation = [String]()
    var owneruid:   String?
}
