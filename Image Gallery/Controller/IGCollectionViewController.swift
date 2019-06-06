//
//  IGCollectionViewController.swift
//  Image Gallery
//
//  Created by Кирилл Афонин on 03/04/2019.
//  Copyright © 2019 krrl. All rights reserved.
//

import UIKit

class IGCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate  {
    
    // adds delegates to CollectionView
    @IBOutlet weak var igCollectionView: UICollectionView! {
        didSet {
            igCollectionView.dragDelegate = self
            igCollectionView.dropDelegate = self
            igCollectionView.dataSource = self
            igCollectionView.delegate = self
            
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(scaleWidth(byHandlingGestureRecognizerBy:)))
            igCollectionView.addGestureRecognizer(pinch)
        }
    }
    
    // contains array of images
    //var imageGallery = [Image]()
    var imageGallery = ImageGallery(name: "one") {
        didSet {
            if !(imageGallery === oldValue) {
                igCollectionView?.reloadData()
            }
        }
    }
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    // creating the cells
    
    // number of items equals number of images in gallery
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageGallery.image.count
    }
    
    // sets the size depending on aspect ratio
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat
//        let imageAspectRatio = imageGallery[indexPath.item].aspectRatio
        let imageAspectRatio = imageGallery.image[indexPath.item].aspectRatio
        if let width = flowLayout?.itemSize.width {
            height = width / CGFloat(imageAspectRatio)
            return CGSize(width: width, height: height)
        } else {
            return CGSize(width: 0.0, height: 0.0)
        }
    }
    
    // Configure the cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        
        if let imageViewCell = cell as? IGCollectionViewCell {
            //imageViewCell.imageURL = imageGallery[indexPath.item].url
            imageViewCell.imageURL = imageGallery.image[indexPath.item].url
        }
        return cell
    }
    
    
    // dragging
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    // if we have local image then drag it
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let url = (igCollectionView.cellForItem(at: indexPath) as? IGCollectionViewCell)?.imageURL {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: url as NSURL))
            dragItem.localObject = url
            return [dragItem]
        } else {
            return []
        }
    }
    
    
    // dropping
    
    // if object has both url and an image representation
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        if isSelf {
            return session.canLoadObjects(ofClass: URL.self)
        } else {
            return session.canLoadObjects(ofClass: URL.self) && session.canLoadObjects(ofClass: UIImage.self)
        }
        
    }
    
    // copies image into new cell
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    // performs both local and outside dropping
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                // local dropping
                collectionView.performBatchUpdates({
                    let tempURL = imageGallery.image.remove(at: sourceIndexPath.item)
                    imageGallery.image.insert(tempURL, at: destinationIndexPath.item)
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                })
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            } else {
                var outsideURL: URL? = nil
                var aspectRatio: Double? = nil
                // dropping from the outside
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "LoadingCell"))
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let url = provider as? URL {
                            outsideURL = url.imageURL
                        }
                    }
                }
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let image = provider as? UIImage {
                            aspectRatio = Double(image.size.width) / Double(image.size.height)
                        }
                        if outsideURL != nil, aspectRatio != nil {
                            placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                let newImage = Image(url: outsideURL!, aspectRatio: aspectRatio!)
                                self.imageGallery.image.insert(newImage, at: insertionIndexPath.item)
                            })
                        } else {
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }
    
    // changes width with a pinch gesture
    @objc private func scaleWidth(byHandlingGestureRecognizerBy recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            flowLayout?.itemSize.width *= recognizer.scale
            flowLayout?.invalidateLayout()
            recognizer.scale = 1.0
        default: break
        }
    }
    
    // segue to a scroll view and send url to it
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ScrollViewSegue" {
            if let cell = sender as? IGCollectionViewCell, let indexPath = igCollectionView.indexPath(for: cell), let svc = segue.destination as? ScrollViewController {
                    svc.imageURL = imageGallery.image[indexPath.item].url
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
    }
    
}
