//
//  ImageGallery.swift
//  Image Gallery
//
//  Created by Кирилл Афонин on 03/04/2019.
//  Copyright © 2019 krrl. All rights reserved.
//

import Foundation

// imgage has url and aspect ratio to set the proper height
struct Image {
    var url: URL
    var aspectRatio: Double
}

struct ImageGallery {
    
    var name: String
    var image = [Image]()
    
    init(name: String) {
        self.name = name
    }
    
    }
