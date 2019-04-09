//
//  CardHelper.swift
//  BusinessCardScanner
//
//  Created by 宋 奎熹 on 2018/8/1.
//  Copyright © 2018 宋 奎熹. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SWXMLHash

class CardHelper: NSObject {
    
    static let shared: CardHelper = CardHelper()
    
    private override init() {
        
    }
    
    func abbyyRecognize(_ image: UIImage, handler: @escaping ((ContactModel) -> Void)) {
        func fetchedDataByDataTask(from request: URLRequest, completion: @escaping (Data) -> Void){
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    print(error as Any)
                } else {
                    guard let data = data else{
                        return
                    }
                    completion(data)
                }
            }
            task.resume()
        }
        
        handler(ContactModel(isMe: true))
        return
        
        print("USING ABBYY!!")
        let authKey = "Basic \(String(format: "%@:%@", ABBYYKeys.id, ABBYYKeys.password).base64EncodedString())"
        
        let imageData = image.jpegData(compressionQuality: 1.0)!
        
        let url = URL(string: "https://cloud.ocrsdk.com/processBusinessCard?language=English,ChinesePRC,ChineseTaiwan&exportFormat=xml&xml:writeFieldComponents=true")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = imageData
        request.setValue(authKey, forHTTPHeaderField: "Authorization")
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        fetchedDataByDataTask(from: request) {
            let xml = SWXMLHash.parse($0)
            print(xml)
            let task = xml["response"]["task"][0]
            if let taskId = task.element?.attribute(by: "id")?.text
//                let processTime = task.element?.attribute(by: "estimatedProcessingTime")?.text
                {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
                    let taskUrl = URL(string: "https://cloud.ocrsdk.com/getTaskStatus?taskId=\(taskId)")!
                    var taskRequest = URLRequest(url: taskUrl)
                    taskRequest.setValue(authKey, forHTTPHeaderField: "Authorization")
                    fetchedDataByDataTask(from: taskRequest, completion: {
                        let taskXml = SWXMLHash.parse($0)
                        print(taskXml)
                        if let resultUrl = taskXml["response"]["task"][0].element?.attribute(by: "resultUrl")?.text {
                            fetchedDataByDataTask(from: URLRequest(url: URL(string: resultUrl)!)) {
                                var contact = ContactModel(xmlIndexer: SWXMLHash.parse($0))
                                contact.image = imageData
                                handler(contact)
                            }
                        }
                    })
                })
            }
        }
    }
    
    func camcardRecognize(_ image: UIImage, handler: @escaping ((ContactModel) -> Void)) {
        print("USING CAMCARD!!")
        let imageData = image.jpegData(compressionQuality: 1.0)!

        let headers: HTTPHeaders = ["Content-Type": "application/form-data"]
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            print("Image Size \(imageData.count / 1024) KB")
            multipartFormData.append(imageData,
                                     withName: "file",
                                     fileName: "image.jpg",
                                     mimeType: "image/jpeg")
        }, to: URL(string: "https://bcr2.intsig.net/BCRService/BCR_VCF2?PIN=\(CamcardKeys.pin)&user=\(CamcardKeys.user)&pass=\(CamcardKeys.pass)&json=1&lang=7")!,
           method: .post,
           headers: headers) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let err = response.error {
                        print(err.localizedDescription)
                        return
                    } else {
                        var contact = ContactModel(json: JSON(response.result.value!))
                        contact.image = imageData
                        handler(contact)
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
            }
        }
    }

}
