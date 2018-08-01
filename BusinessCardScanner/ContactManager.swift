//
//  ContactManager.swift
//  BusinessCardScanner
//
//  Created by 宋 奎熹 on 2018/7/31.
//  Copyright © 2018 宋 奎熹. All rights reserved.
//

import Foundation

class ContactManager: NSObject {
    
    static let shared: ContactManager = ContactManager()
    
    private var contacts: Set<ContactModel> = Set()
    
    private override init() {
        
    }
    
    func contactArray() -> [ContactModel] {
        return contacts.sorted(by: { (cm1, cm2) -> Bool in
            cm1.addedTime.timeIntervalSince1970 < cm2.addedTime.timeIntervalSince1970
        })
    }
    
    func addContact(_ contact: ContactModel) {
        contacts.insert(contact)
        saveContacts()
    }
    
    func deleteContact(_ contact: ContactModel) {
        contacts.remove(contact)
        saveContacts()
    }
    
    private func saveContacts() {
//        UserDefaults.standard.set(contacts, forKey: "contacts")
    }
    
}
