//
//  ListTableViewController.swift
//  BusinessCardScanner
//
//  Created by 宋 奎熹 on 2018/7/30.
//  Copyright © 2018 宋 奎熹. All rights reserved.
//

import UIKit

enum Recognizer {
    case abbyy
    case camcard
}

class ListTableViewController: UITableViewController {

    var contactArray        : [ContactModel] = []
    var contactManager      : ContactManager = .shared
    var cardHelper          : CardHelper = .shared
    var waitingCount        : UInt = 0
    var currentRecognizer   : Recognizer = .abbyy
    var selectedContacts    : Set<ContactModel> = Set()
    var imageQueue          : [UIImage] = []
    var failedContacts      : [UIImage] = []
      
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        
        let sc = UISegmentedControl(items: ["ABBYY", "Camcard"])
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(recognizerChanged(_:)), for: .valueChanged)
        self.navigationItem.titleView = sc
        
        self.navigationController?.toolbar.isHidden = true
    }
    
    @objc func recognizerChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.currentRecognizer = .abbyy
        case 1:
            self.currentRecognizer = .camcard
        default:
            return
        }
    }
    
    private func reloadData() {
        self.contactArray = contactManager.contactArray()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
//        self.processImage()
    }
    
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        if self.tableView.isEditing {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editAction(_:)))
            self.navigationController?.toolbar.isHidden = true
            self.tableView.setEditing(false, animated: true)
            self.selectedContacts.removeAll()
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(editAction(_:)))
            self.navigationController?.toolbar.isHidden = false
            self.tableView.setEditing(true, animated: true)
        }
    }
    
    @IBAction func deleteAction(_ sender: UIBarButtonItem) {
        print(self.selectedContacts)
    }
    
    @IBAction func exportAction(_ sender: UIBarButtonItem) {
        print(self.selectedContacts)
    }
    
    func processImage() {
        guard let firstImage = self.imageQueue.first else {
            return
        }
        
        switch currentRecognizer {
        case .abbyy:
            cardHelper.abbyyRecognize(firstImage) { (contact) in
                self.waitingCount -= 1
                
                self.contactManager.addContact(contact)
                self.reloadData()
            }
        case .camcard:
            cardHelper.camcardRecognize(firstImage) { (contact) in
                self.waitingCount -= 1
                if let contact = contact {
                    self.contactManager.addContact(contact)
                    self.reloadData()
                } else {
                    self.failedContacts.append(firstImage)
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell") as? ListTableViewCell
        if cell == nil {
            cell = ListTableViewCell()
        }

        let contact = contactArray[indexPath.row]
        cell!.bind(with: contact)
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contactArray[indexPath.row]
        if tableView.isEditing {
            if !self.selectedContacts.contains(contact) {
                self.selectedContacts.insert(contact)
            }
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            self.performSegue(withIdentifier: "detailSegue", sender: contact)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let contact = contactArray[indexPath.row]
        if tableView.isEditing {
            if self.selectedContacts.contains(contact) {
                self.selectedContacts.remove(contact)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle(rawValue: UITableViewCell.EditingStyle.delete.rawValue | UITableViewCell.EditingStyle.insert.rawValue)!
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Sure to delete?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                self.contactManager.deleteContact(self.contactArray[indexPath.row])
                self.reloadData()
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(waitingCount) card\(waitingCount > 1 ? "s" : "") waiting"
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            let infoVC: InfoTableViewController = segue.destination as! InfoTableViewController
            infoVC.contactModel = (sender as! ContactModel)
        } else if segue.identifier == "cameraSegue" {
            let cameraVC: CameraViewController = segue.destination as! CameraViewController
            cameraVC.delegate = self
        }
    }
    
}

extension ListTableViewController: CapturePictureDelegate {
    
    func capture(with image: UIImage) {
        self.waitingCount += 1
        
        self.imageQueue.append(image)
        
        guard self.waitingCount == self.imageQueue.count else {
            return
        }
        
        if self.imageQueue.count == 1 {
            self.processImage()
        }
    }
    
}
