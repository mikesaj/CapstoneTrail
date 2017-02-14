//
//  AddressBook.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-14.
//  Copyright © 2017 MSD. All rights reserved.
//

import Foundation
import AddressBook

func PetBookViewController(){

    let authorizationStatus = ABAddressBookGetAuthorizationStatus()
    
    switch authorizationStatus {
        case .denied, .restricted:
            //1
            print("Denied")
        case .authorized:
            //2
            print("Authorized")
        case .notDetermined:
            //3
            print("Not Determined")
    }
    
    let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()

//promptForAddressBookRequestAccess(petButton)
}
