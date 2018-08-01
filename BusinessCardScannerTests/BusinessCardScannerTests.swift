//
//  BusinessCardScannerTests.swift
//  BusinessCardScannerTests
//
//  Created by 宋 奎熹 on 2018/8/1.
//  Copyright © 2018 宋 奎熹. All rights reserved.
//

import XCTest
import SWXMLHash

class BusinessCardScannerTests: XCTestCase {
    
    func testExample() {
        var contact: ContactModel = ContactModel(isMe: false)
        print(SWXMLHash.parse(testXMLString)["document"]["businessCard"]["field"].all.forEach {
            handleXMLField($0)
        })
        
        func handleXMLField(_ xmlIndexer: XMLIndexer) {
            let type = xmlIndexer.element!.attribute(by: "type")!.text
            print(type)
            print(xmlIndexer.element!)
            let value = xmlIndexer["value"].element!.text
            switch type {
            case "Phone":
                contact.telephone.append(CardItem(value: value, type: ["phone"]))
            case "Fax":
                contact.telephone.append(CardItem(value: value, type: ["fax"]))
            case "Mobile":
                contact.telephone.append(CardItem(value: value, type: ["mobile"]))
            case "Email":
                contact.email.append(value)
            case "Address":
                contact.address.append(CardItem(value: value, type: ["work"]))
            case "Name":
                contact.formattedName = value
                xmlIndexer["fieldComponents"]["fieldComponent"].all.forEach {
                    handleXMLField($0)
                }
            case "FirstName":
                contact.firstName = value
            case "LastName":
                contact.lastName = value
            case "Job":
                contact.title = value
            case "Company":
                contact.company = value
            default:
                break
            }
        }
        
        print(contact)
    }
    
    override func setUp() {
        super.setUp()
        print("Start")
    }
    
    override func tearDown() {
        super.tearDown()
        print("End")
    }
    
    let testXMLString = """
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<document xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://ocrsdk.com/schema/recognizedBusinessCard-1.0.xsd http://ocrsdk.com/schema/recognizedBusinessCard-1.0.xsd" xmlns="http://ocrsdk.com/schema/recognizedBusinessCard-1.0.xsd">
<businessCard imageRotation="noRotation">
<field type="Phone">
<value>&gt;852 2128 5633</value>
<fieldComponents>
<fieldComponent type="PhoneBody">
<value>85221285633</value>
</fieldComponent>
</fieldComponents>
</field>
<field type="Fax">
<value>2 3167 1701</value>
<fieldComponents>
<fieldComponent type="PhoneBody">
<value>231671701</value>
</fieldComponent>
</fieldComponents>
</field>
<field type="Mobile">
<value>+852 6478 3852</value>
<fieldComponents>
<fieldComponent type="PhonePrefix">
<value>+</value>
</fieldComponent>
<fieldComponent type="PhoneCountryCode">
<value>852</value>
</fieldComponent>
<fieldComponent type="PhoneBody">
<value>64783852</value>
</fieldComponent>
</fieldComponents>
</field>
<field type="Email">
<value>edmund.yick@mhk.com</value>
</field>
<field type="Address">
<value>9/F. watson centre 2 Kung Yip street Kwal OKing New Territories. Hong Kong</value>
<fieldComponents>
<fieldComponent type="StreetAddress">
<value>9/F. watson centre 2 Kung Yip street Kwal OKing New Territories.</value>
</fieldComponent>
<fieldComponent type="Country">
<value>Hong Kong</value>
</fieldComponent>
</fieldComponents>
</field>
<field type="Name">
<value>Edmund Yick</value>
<fieldComponents>
<fieldComponent type="FirstName">
<value>Edmund</value>
</fieldComponent>
<fieldComponent type="LastName">
<value>Yick</value>
</fieldComponent>
</fieldComponents>
</field>
<field type="Company">
<value>Hutchison TelecommunkatJons (Hong Kong) Limited</value>
</field>
<field type="Job">
<value>General Manager Enterprise Mariet Mobile</value>
<fieldComponents>
<fieldComponent type="JobPosition">
<value>General Manager Enterprise Mariet</value>
</fieldComponent>
<fieldComponent type="JobDepartment">
<value>Mobile</value>
</fieldComponent>
</fieldComponents>
</field>
<field type="Text">
<value>1
Edmund Yick
General Manager Enterprise Mariet
Mobile
Hutchison TelecommunkatJons
(Hong Kong) Limited
A mmbev of a HMdinon Hoid» v
Three.comiik
9/F. watson centre
2 Kung Yip street Kwal OKing
New Territories. Hong Kong
Tel &gt;852 2128 S633
Fax+«S 2 3167 1701
Mobile- +852 6478 3852
e&lt;Jmund.yick@&gt;mwt(om
wv^.three.com hk</value>
</field>
</businessCard>
</document>
"""
    
}
