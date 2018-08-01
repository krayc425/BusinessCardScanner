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

struct CardItem: Codable {
    var value: String
    var type: [String]
}

struct ContactModel: Codable, Hashable {
    
    var addedTime: Date = Date()
    var hashValue: Int {
        return Int(addedTime.timeIntervalSince1970)
    }

    var formattedName: String
    var firstName: String       // Given Name
    var lastName: String        // Family Name
    var telephone: [CardItem]
    var title: String
    var address: [CardItem]
    var url: [String]
    var email: [String]
    
    var image: Data = Data()
    
    init(xml: XMLIndexer) {
        print(xml["field"])
        self.init()
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
        print(json)
    }
    
    init() {
        self.email = ["krayc425@gmail.com"]
        self.firstName = "Kuixi"
        self.lastName = "Song"
        self.formattedName = "Kuixi Song"
        self.telephone = [CardItem(value: "+8612345678", type: ["home", "cell"]),
                          CardItem(value: "+8687654321", type: ["work", "phone"])]
        self.url = ["http://www.baidu.com", "http://github.com/songkuixi"]
        self.title = "iOS Developer"
        self.address = [CardItem(value: "Somewhere", type: ["work"])]
    }
    
    static func ==(lhs: ContactModel, rhs: ContactModel) -> Bool {
        return lhs.addedTime == rhs.addedTime
    }
    
}
