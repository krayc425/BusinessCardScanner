//
//  InfoTableViewController.swift
//  BusinessCardScanner
//
//  Created by 宋 奎熹 on 2018/7/30.
//  Copyright © 2018 宋 奎熹. All rights reserved.
//

import UIKit

private let cellId = "UITableViewCell"

class InfoTableViewController: UITableViewController {

    var contactModel: ContactModel?
    
    // 0 Name, Title, Company
    // 1 Phone
    // 2 Email
    // 3 Address
    // 4 URL, etc.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = 60.0
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        
        if let contactModel = self.contactModel {
            self.title = contactModel.formattedName
            
            if let image = UIImage(data: contactModel.image) {
                let cardImageView = UIImageView(frame: CGRect(x: 0,
                                                              y: 0,
                                                              width: UIScreen.main.bounds.size.width,
                                                              height: UIScreen.main.bounds.size.width / image.size.width * image.size.height))
                cardImageView.image = image
                self.tableView.tableHeaderView = cardImageView
            }
            self.tableView.reloadData()
        }
    }
    
    @IBAction func exportAction(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Choose an action", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Save to Outlook", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Save to GSGO", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Save to Contacts", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let contact = contactModel else {
            return 0
        }
        switch section {
        case 0:
            return 4
        case 1:
            return contact.telephone.count
        case 2:
            return contact.email.count
        case 3:
            return contact.address.count
        case 4:
            return contact.url.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
            cell.textLabel?.text = contactModel?.firstName
            cell.detailTextLabel?.text = "First Name"
            return cell
        case (0, 1):
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
            cell.textLabel?.text = contactModel?.lastName
            cell.detailTextLabel?.text = "Last Name"
            return cell
        case (0, 2):
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = contactModel?.title
            cell.detailTextLabel?.text = "Title"
            cell.textLabel?.sizeToFit()
            return cell
        case (0, 3):
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = contactModel?.company
            cell.detailTextLabel?.text = "Company"
            cell.textLabel?.sizeToFit()
            return cell
        case (1, _):
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
            cell.textLabel?.text = contactModel?.telephone[indexPath.row].value
            cell.detailTextLabel?.text = contactModel?.telephone[indexPath.row].type.joined(separator: ", ")
            return cell
        case (2, _):
            let cell = UITableViewCell(style: .default, reuseIdentifier: cellId)
            cell.textLabel?.text = contactModel?.email[indexPath.row]
            return cell
        case (3, _):
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = contactModel?.address[indexPath.row].value
            cell.detailTextLabel?.text = contactModel?.address[indexPath.row].type.joined(separator: ", ")
            cell.textLabel?.sizeToFit()
            return cell
        case (4, _):
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellId)
            cell.textLabel?.text = contactModel?.url[indexPath.row]
            return cell
        default:
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if let text = cell?.textLabel?.text, text != "" {
            var tempText: UITextField?
            let alert = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                tempText = textField
                textField.text = text
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                cell?.textLabel?.text = tempText?.text
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Info", "Phone", "Email", "Address", "Others"][section]
    }
    
}
