//
//  CNMutableContactExtensions.swift
//  BusinessCardScanner
//
//  Created by 宋 奎熹 on 2019/4/13.
//  Copyright © 2019 宋 奎熹. All rights reserved.
//

import UIKit
import Contacts

extension CNMutableContact {
    
    convenience init(model: ContactModel) {
        self.init()
        self.givenName = model.firstName
        self.familyName = model.lastName
        self.jobTitle = model.title
        self.organizationName = model.company
        self.emailAddresses = model.email.map { CNLabeledValue(label: CNLabelWork, value: $0 as NSString) }
        self.urlAddresses = model.url.map { CNLabeledValue(label: CNLabelWork, value: $0 as NSString) }
        self.phoneNumbers = model.telephone.map { CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: $0.value)) }
        self.postalAddresses = model.address.map({ (item) -> CNLabeledValue<CNPostalAddress> in
            let postalAddress = CNMutablePostalAddress()
            postalAddress.street = item.value
            return CNLabeledValue(label: CNLabelWork, value: postalAddress)
        })
    }
    
}
