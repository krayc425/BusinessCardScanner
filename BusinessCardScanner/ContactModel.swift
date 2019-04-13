//
//  ContactModel.swift
//  BusinessCardScanner
//
//  Created by 宋 奎熹 on 2018/7/31.
//  Copyright © 2018 宋 奎熹. All rights reserved.
//

import Foundation
import SwiftyJSON
import SWXMLHash

enum ContactStatus {
    
    case processing
    case new
    case done
    
}

struct CardItem: Codable {
    var value: String
    var type: [String]
    
    init(value: String, type: [String]) {
        self.value = value
        self.type = type
    }
}

struct ContactModel: Codable, Hashable {
    
    var addedTime: Date = Date()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(Int(addedTime.timeIntervalSince1970))
    }

    var formattedName: String
    var firstName: String       // Given Name
    var lastName: String        // Family Name
    var telephone: [CardItem]
    var title: String
    var address: [CardItem]
    var url: [String]
    var email: [String]
    var company: String
    
    var image: Data = Data()
    
    init(xmlIndexer: XMLIndexer) {
        self.init(isMe: false)
        xmlIndexer["document"]["businessCard"]["field"].all.forEach {
            handleXMLField($0)
        }

        func handleXMLField(_ xmlIndexer: XMLIndexer) {
            let type = xmlIndexer.element!.attribute(by: "type")!.text
            let value = xmlIndexer["value"].element!.text
            switch type {
            case "Phone", "Fax", "Mobile":
                self.telephone.append(CardItem(value: value, type: [type.lowercased()]))
            case "Email":
                self.email.append(value)
            case "Address":
                self.address.append(CardItem(value: value, type: ["work"]))
            case "Name":
                self.formattedName = value
                xmlIndexer["fieldComponents"]["fieldComponent"].all.forEach {
                    handleXMLField($0)
                }
            case "FirstName":
                self.firstName = value
            case "LastName":
                self.lastName = value
            case "Job":
                self.title = value
            case "Company":
                self.company = value
            case "Web":
                self.url.append(value)
            default:
                break
            }
        }
    }
    
    init(json: JSON) {
        self.firstName = json["name"][0]["item"]["given_name"].stringValue
        self.lastName = json["name"][0]["item"]["family_name"].stringValue
        self.formattedName = json["formatted_name"][0]["item"].stringValue
        self.title = json["title"][0]["item"].stringValue
        self.telephone = json["telephone"].arrayValue.map {
            return CardItem(value: $0["item"]["number"].stringValue,
                            type: $0["item"]["type"].arrayValue.map { $0.stringValue })
        }
        self.url = json["url"].arrayValue.map({ (json) -> String in
            var urlString = json["item"].stringValue
            if !urlString.hasPrefix("http") && !urlString.hasPrefix("https") {
                urlString = "http://\(urlString)"
            }
            return urlString
        })
        self.email = json["email"].arrayValue.map { $0["item"].stringValue }
        self.address = json["address"].arrayValue.map {
            return CardItem(value: "\($0["item"]["street"].stringValue) \($0["item"]["locality"].stringValue)",
                            type: $0["item"]["type"].arrayValue.map { $0.stringValue })
        }
        self.company = json["organization"].arrayValue.map { $0["item"] }.first(where: { (json) -> Bool in
            json["name"] != ""
        })?["name"].stringValue ?? ""
    }
    
    init(isMe: Bool) {
        if isMe {
            self.email = ["krayc425@gmail.com"]
            self.firstName = "Kuixi"
            self.lastName = "Song"
            self.formattedName = "Kuixi Song"
            self.telephone = [CardItem(value: "+8612345678", type: ["home", "cell"]),
                              CardItem(value: "+8687654321", type: ["work", "phone"])]
            self.url = ["http://www.baidu.com", "http://github.com/songkuixi"]
            self.title = "iOS Developer"
            self.address = [CardItem(value: "Somewhere", type: ["work"])]
            self.company = "None"
        } else {
            self.email = []
            self.firstName = ""
            self.lastName = ""
            self.formattedName = ""
            self.telephone = []
            self.url = []
            self.title = ""
            self.address = []
            self.company = ""
        }
    }
    
    static func ==(lhs: ContactModel, rhs: ContactModel) -> Bool {
        return lhs.addedTime == rhs.addedTime
    }
    
}
