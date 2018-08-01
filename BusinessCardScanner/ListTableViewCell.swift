//
//  ListTableViewCell.swift
//  BusinessCardScanner
//
//  Created by 宋 奎熹 on 2018/7/31.
//  Copyright © 2018 宋 奎熹. All rights reserved.
//

import UIKit

enum ProcessStatus {
    case none
    case processing
    case done
}

class ListTableViewCell: UITableViewCell {
    
    static let fmt: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df
    }()
    
    var status: ProcessStatus = .none {
        didSet {
//            switch status {
//            case .processing:
//                detailTextLabel?.text = "Processing"
//            case .done:
//                detailTextLabel?.text = "Done"
//            case .none:
//                detailTextLabel?.text = ""
//            }
        }
    }

    func bind(with contact: ContactModel) {
        textLabel?.text = contact.formattedName
        detailTextLabel?.text = ListTableViewCell.fmt.string(from: contact.addedTime)
    }
    
}
