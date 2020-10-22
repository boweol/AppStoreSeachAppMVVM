//
//  API.swift
//  AppStoreSearchAppMVVM
//
//  Created by isens on 21/10/2020.
//  Copyright © 2020 isens. All rights reserved.
//

import Foundation
import RxSwift

class API {
    static let urlString = "http://itunes.apple.com/search?media=software&country=kr&term="
    
    static func repositoriesBy(_ searchText: String) -> Observable<Any> {
        guard !searchText.isEmpty, let url = URL(string: "\(urlString)\(searchText)") else {
            return Observable.just([])
        }
        
        return URLSession.shared.rx.json(url: url)
            .retry(3)
    }
}
