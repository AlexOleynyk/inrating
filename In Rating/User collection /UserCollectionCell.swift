//
//  UserCollectionCell.swift
//  In Rating
//
//  Created by Alex Oleynyk on 13.09.2018.
//  Copyright © 2018 oleynyk.com. All rights reserved.
//

import UIKit

//struct UserCollectionCellViewModel {
//    let name: String
//}

class UserCollectionCell: UICollectionViewCell {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    
    
    func configure(with data: UserData, imageCache: NSCache<NSString, UIImage>) {
        userNameLabel.text = data.name
        
        if let image = imageCache.object(forKey: data.avatarImageUrl as NSString) {
            DispatchQueue.main.async {
                self.userPhotoImageView.image = image
            }
        } else {
            ApiService().loadImage(fromUrl: data.avatarImageUrl) { [weak self] (imageData) in
                DispatchQueue.main.async {
                    if let image = UIImage(data: imageData) {
                        imageCache.setObject(image, forKey: data.avatarImageUrl as NSString)
                        self?.userPhotoImageView.image = image
                    }
                }
            }
        }
        
    }
    
}
