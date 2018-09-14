//
//  UsersCollectionViewController.swift
//  In Rating
//
//  Created by Alex Oleynyk on 13.09.2018.
//  Copyright © 2018 oleynyk.com. All rights reserved.
//

import UIKit

class UsersCollectionViewModel {
    var usersData = [UserData]()
    var isCollectionVisible = true
   
    
    func loadUsers() {
        
    }
}

enum UserCollectionTypes {
    case likes
    case commentators
    case mentions
    case reposters
    case views
    case bookmarks
}

class UsersCollectionViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noActivityLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let usersCollectionViewModel = UsersCollectionViewModel()
    var imageCache =  NSCache<NSString, UIImage>()
    weak var delegate: UsersCollectionViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.cornerRadius = 5
    }
    
    func configure(type: UserCollectionTypes, initialValue: Int = 0, isCollectionVisible: Bool = true) {
        
        switch type {
        case .likes:
            titleLabel.text = "Лайки \(initialValue)"
            ApiService().getLikers(forId: 20157) { [weak self] (userData) in
                self?.updateViewModel(userData: userData)
                if initialValue == 0 {self?.titleLabel.text = "Лайки \(userData.count)"}
            }
        case .commentators:
            titleLabel.text = "Комментаторы  \(initialValue)"
            ApiService().getCommentators(forId: 20157) { [weak self] (userData) in
                self?.updateViewModel(userData: userData)
                self?.titleLabel.text = "Комментаторы \(userData.count)"
            }
        case .mentions:
            titleLabel.text = "Отметки  \(initialValue)"
            ApiService().getMentions(forId: 20157) { [weak self] (userData) in
                self?.updateViewModel(userData: userData)
                self?.titleLabel.text = "Отметки \(userData.count)"
            }
        case .reposters:
            titleLabel.text = "Репосты \(initialValue)"
            ApiService().getReposters(forId: 20157) { [weak self] (userData) in
                self?.updateViewModel(userData: userData)
                self?.titleLabel.text = "Репосты \(userData.count)"
            }
        case .views:
            titleLabel.text = "Просмотры \(initialValue)"
        case .bookmarks:
            titleLabel.text = "Закладки \(initialValue)"
        }
        
        
        if !isCollectionVisible {
            collectionView.isHidden = true
        }
        
        
        
    }
    
     private func updateViewModel(userData: [UserData]) {
        usersCollectionViewModel.usersData = userData
        
        if let delegate = delegate {
            let height = userData.count > 0 ? 110 : 40
            delegate.usersCollectionViewController(self, didChangeHeight: height)
        }
        
        
        if usersCollectionViewModel.isCollectionVisible {
            collectionView.reloadData()
        }
    }
}

extension UsersCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return usersCollectionViewModel.isCollectionVisible ? usersCollectionViewModel.usersData.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCollectionCell", for: indexPath) as! UserCollectionCell
        let userData = usersCollectionViewModel.usersData[indexPath.row]
        cell.configure(with: userData, imageCache: imageCache)
        return cell
    }
    
}
