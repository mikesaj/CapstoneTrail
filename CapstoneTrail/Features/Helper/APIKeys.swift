//
// Created by Joohyung Ryu on 2017. 3. 12..
// Copyright (c) 2017 MSD. All rights reserved.
//

import Foundation


// Get API key value from custom 'APIKeys.plist' which is ignored to git
func getAPIKeys(keyName: String) -> String {

    // Create bundle object from 'Credentials/APIKeys.plist' which is ignored to git for getting full file pathname
    guard let filePath = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else {
        // If the file does not exists, return a message
        return "File not found"
    }

    // Create NSDictionary from plist file of the path
    let apiKeyPlist = NSDictionary(contentsOfFile: filePath)

    // Get API key value from the key name
    guard let apiValue = apiKeyPlist?.object(forKey: keyName) else {
        // If the key does not exists, return a message
        return "Key not found"
    }

    return apiValue as! String
}
