//
//  IGCollectionViewCell.swift
//  Image Gallery
//
//  Created by Кирилл Афонин on 16/04/2019.
//  Copyright © 2019 krrl. All rights reserved.
//

import UIKit

class IGCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    // sets the url and downloads image
    var imageURL: URL? {
        didSet {
            imageView.image = nil
            fetchImage()
        }
    }
    
    // downloads image in global thread
    private func fetchImage() {
        if let url = imageURL {
            DispatchQueue.global(qos: .userInitiated).async {
                let urlContents = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let imageData = urlContents, let image = UIImage(data: imageData), url == self.imageURL {
                        self.imageView.image = image
                    }
                }
            }
        }
    }
    
}
