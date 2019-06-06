//
//  IGTableViewController.swift
//  Image Gallery
//
//  Created by Кирилл Афонин on 23/04/2019.
//  Copyright © 2019 krrl. All rights reserved.
//

import UIKit

class IGTableViewController: UITableViewController {
    
    // contains name of gallery and array of its images
    var listOfImageGalleries = [ImageGallery]()
    var recentDeleted = [ImageGallery]()

    @IBAction func newGallery(_ sender: UIBarButtonItem) {
        var igNames = [String]()
        for index in listOfImageGalleries.indices {
            igNames.append(listOfImageGalleries[index].name)
        }
        listOfImageGalleries.append(ImageGallery(name: "Untitled".madeUnique(withRespectTo: igNames)))
        tableView.reloadData()
    }
    
    
    // creating cells
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return listOfImageGalleries.count
        case 1:
            return recentDeleted.count
        default:
            print("There is no section with this number")
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "GalleryCell", for: indexPath)
        switch indexPath.section {
        case 0:
            if let igCell = cell as? IGTableViewCell {
                igCell.textField.text = listOfImageGalleries[indexPath.row].name
                igCell.resignationHandler = { [weak self, unowned igCell] in
                    if let name = igCell.textField.text {
                        self?.listOfImageGalleries[indexPath.row].name = name
                        self?.tableView.reloadData()
                    }
                }
            }
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "DeletedCell", for: indexPath)
            cell.textLabel?.text = recentDeleted[indexPath.row].name
        default:
            print("There is no section with this number")
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return "Recently Deleted"
        default:
            print("There is no section with this number")
            return nil
    }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.performBatchUpdates({
                if indexPath.section == 0 {
                    recentDeleted.append(listOfImageGalleries.remove(at: indexPath.row))
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.insertRows(at: [IndexPath(row: recentDeleted.count-1, section: 1)], with: .automatic)
                } else if indexPath.section == 1 {
                    recentDeleted.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }

            })
        } else if editingStyle == .insert {
  
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let undelete = UIContextualAction(style: .normal, title: "Undelete", handler: { (contextAction, sourceView, completionHandler) in
                tableView.performBatchUpdates({
                    self.listOfImageGalleries.append(self.recentDeleted.remove(at: indexPath.row))
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.insertRows(at: [IndexPath(row: self.listOfImageGalleries.count-1, section: 0)], with: .automatic)
                })
                completionHandler(true)
            })
            undelete.backgroundColor = UIColor.green
            return UISwipeActionsConfiguration(actions: [undelete])
        } else {
            return nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CollectionViewSegue" {
            if let cvs = segue.destination.contents as? IGCollectionViewController, let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                cvs.imageGallery = listOfImageGalleries[indexPath.row]
                cvs.title = listOfImageGalleries[indexPath.row].name
            }
        }
    }

    override func viewDidLoad() {
        listOfImageGalleries.append(ImageGallery(name: "1"))
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }

}
