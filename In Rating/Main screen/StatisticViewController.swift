//
//  ViewController.swift
//  In Rating
//
//  Created by Alex Oleynyk on 13.09.2018.
//  Copyright © 2018 oleynyk.com. All rights reserved.
//

import UIKit

class StatisticViewControllerViewModel {
    
}

protocol UsersCollectionViewControllerDelegate: class {
     func usersCollectionViewController(_ userCollection: UsersCollectionViewController , didChangeHeight height: Int)
}


class StatisticViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ApiService().getStats(forSlug: "suCP11LONie4") { [weak self] ( dict ) in
            
            if let childs = self?.childViewControllers.enumerated() {
                for (index, childVC) in childs {
                    if let childVC = childVC as? UsersCollectionViewController {
                        switch index {
                        case 0: childVC.configure(type: .views, initialValue: dict["views"] ?? 0, isCollectionVisible: false)
                        case 1: childVC.configure(type: .likes, initialValue: dict["likes"] ?? 0)
                        case 2: childVC.configure(type: .commentators, initialValue: dict["comments"] ?? 0)
                        case 3: childVC.configure(type: .mentions)
                        case 4: childVC.configure(type: .reposters, initialValue: dict["reposts"] ?? 0)
                        case 5: childVC.configure(type: .bookmarks, initialValue: dict["bookmarks"] ?? 0, isCollectionVisible: false)
                        default:
                            break
                        }
                        childVC.delegate = self
                    }
                }
            }
        }
    }
}

extension StatisticViewController: UsersCollectionViewControllerDelegate {
    func usersCollectionViewController(_ userCollection: UsersCollectionViewController , didChangeHeight height: Int) {
        if let cons = userCollection.view.superview?.superview?.constraints {
            for constraint in cons {
                if constraint.firstAttribute == .height {
                    constraint.constant = CGFloat(height)
                }
            }
        }
    }
}

