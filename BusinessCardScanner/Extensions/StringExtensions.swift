//
//  StringExtensions.swift
//  BusinessCardScanner
//
//  Created by 宋 奎熹 on 2018/8/1.
//  Copyright © 2018 宋 奎熹. All rights reserved.
//

import Foundation

extension String {
    
    func base64EncodedString() -> String {
        let data = self.data(using: String.Encoding.utf8)
        return data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }
    
}
