//
//  ListTableViewCell.swift
//  BusinessCardScanner
//
//  Created by 宋 奎熹 on 2018/7/31.
//  Copyright © 2018 宋 奎熹. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    
    static let fmt: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df
    }()

    func bind(with contact: ContactModel) {
        textLabel?.text = contact.formattedName
        detailTextLabel?.text = ListTableViewCell.fmt.string(from: contact.addedTime)
    }
    
}
