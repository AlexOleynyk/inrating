//
//  DataProvider.swift
//  JatApp
//
//  Created by Alex Oleynyk on 05.09.2018.
//  Copyright © 2018 oleynyk.com. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct UserData {
    let name: String
    let avatarImageUrl: String
}

class ApiService {
    private static var token: String = ""
    
    private func loadToken() {
        if let path = Bundle.main.path(forResource: "Autorization", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) {
            if let token = dict["Bearer"] as? String {
                ApiService.token = token
            }
        }
    }
    
    init() {
        if ApiService.token == "" { loadToken() }
    }
    
    func getLikers(forId postId: Int, completion: @escaping ([UserData]) -> Void) {
        executeUserCollectionRequest(.likes, postId) { completion($0) }
    }
    
    func getCommentators(forId postId: Int, completion: @escaping ([UserData]) -> Void) {
        executeUserCollectionRequest(.commentators, postId) { completion($0) }
    }
    
    func getMentions(forId postId: Int, completion: @escaping ([UserData]) -> Void) {
        executeUserCollectionRequest(.mentions, postId) { completion($0) }
    }
    
    func getReposters(forId postId: Int, completion: @escaping ([UserData]) -> Void) {
        executeUserCollectionRequest(.reporters, postId) { completion($0) }
    }
    
    func getStats(forSlug postSlug: String, completion: @escaping ([String: Int]) -> Void) {
        let requestUrl = RequestType.stats.rawValue
        
        let params = [
            "slug": "\(postSlug)"
        ]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Authorization": "Bearer \(ApiService.token)"
        ]
        
        request(requestUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if let views = json["views_count"].int,
                        let likes = json["likes_count"].int,
                        let reposts = json["reposts_count"].int,
                        let comments = json["comments_count"].int,
                        let bookmarks = json["bookmarks_count"].int {
                        completion(["views": views, "likes": likes, "reposts": reposts, "comments": comments, "bookmarks": bookmarks])
                    } else {
                        completion([:])
                    }
                case .failure(let error):
                    print(error)
                    completion([:])
                }
        }
    }
    
    func executeUserCollectionRequest(_ requestType: RequestType, _ postId: Int, completion: @escaping ([UserData]) -> Void)  {
        
        let requestUrl = requestType.rawValue
        
        let params = [
            "id": "\(postId)"
        ]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Authorization": "Bearer \(ApiService.token)"
        ]
        
        request(requestUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if let dataArray = json["data"].array {
                        let data = dataArray.map { (item) -> UserData in
                            let name = item["name"].string ?? "noname"
                            let avatarImageUrl = item["avatar_image"]["url_small"].string ?? ""
                            return UserData(name: name, avatarImageUrl: avatarImageUrl)
                        }
                        completion(data)
                    }
                    
                case .failure(let error):
                    print(error)
                    completion([])
                }
        }
    }
    
    func loadImage(fromUrl: String, completion: @escaping (Data) -> Void ) {
        
        request(fromUrl)
            .responseData { response in
                if let data = response.result.value {
                    completion(data)
                }
                
                if let error = response.error {
                    print(error)
                }
        }
    }

}

enum RequestType: String {
    case likes = "https://api.inrating.top/v1/users/posts/likers/all"
    case commentators = "https://api.inrating.top/v1/users/posts/commentators/all"
    case mentions = "https://api.inrating.top/v1/users/posts/mentions/all"
    case reporters = "https://api.inrating.top/v1/users/posts/reposters/all"
    case stats = "https://api.inrating.top/v1/users/posts/get"
}
