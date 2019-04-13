//
//  ExportHelper.swift
//  BusinessCardScanner
//
//  Created by 宋 奎熹 on 2019/4/10.
//  Copyright © 2019 宋 奎熹. All rights reserved.
//

import UIKit
import Contacts

class ExportHelper: NSObject {
    
    static let shared: ExportHelper = ExportHelper()

    private override init() {
        
    }
    
    func exportToAddressList(_ model: ContactModel, handler: @escaping ((Error?) -> Void)) {
        let cnContact = CNMutableContact(model: model)
        let saveRequest = CNSaveRequest()
        saveRequest.add(cnContact, toContainerWithIdentifier: nil)
        
        let store = CNContactStore()
        do {
            try store.execute(saveRequest)
            handler(nil)
        } catch let exception {
            handler(exception)
        }
    }
    
    func exportToGS(_ model: ContactModel, handler: @escaping ((Error?) -> Void)) {
        
    }
    
}
