//
//  SearchViewModel.swift
//  AppStoreSearchAppMVVM
//
//  Created by isens on 20/10/2020.
//  Copyright © 2020 isens. All rights reserved.
//

import RxSwift
import RxCocoa

class SearchViewModel {
    let searchText = BehaviorRelay<String>(value: "")
    
    lazy var data: Driver<[AppInfo]> = {
        return self.searchText.asObservable()
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance) // 해당 시간 뒤에 반환
            .distinctUntilChanged() // 같은값은 받지 않음
            .flatMapLatest(API.repositoriesBy)
            .map(parse)
            .asDriver(onErrorJustReturn: [])
    }()
    
    func search(_ searchWord: String) {
        searchText.accept(searchWord)
    }
    
    func parse(json: Any) -> [AppInfo] {
        guard let retObj = json as? [String: Any] else {
            return []
        }
        guard let items = retObj["results"] as? [[String: Any]] else {
            return []
        }
        print("items: \(items)")
        
        var apps = [AppInfo]()
        items.forEach {
            var appInfo = AppInfo()
            if let screenshotUrls: [String] = $0["screenshotUrls"] as? [String] {
                appInfo.screenshotUrls = screenshotUrls
            }
            if let artworkUrl60: String = $0["artworkUrl60"] as? String {
                appInfo.artworkUrl60 = artworkUrl60
            }
            if let artworkUrl100: String = $0["artworkUrl100"] as? String {
                appInfo.artworkUrl100 = artworkUrl100
            }
            if let artworkUrl512: String = $0["artworkUrl512"] as? String {
                appInfo.artworkUrl512 = artworkUrl512
            }
            if let artistViewUrl: String = $0["artistViewUrl"] as? String {
                appInfo.artistViewUrl = artistViewUrl
            }
            if let minimumOsVersion: String = $0["minimumOsVersion"] as? String {
                appInfo.minimumOsVersion = minimumOsVersion
            }
            if let trackName: String = $0["trackName"] as? String {
                appInfo.trackName = trackName
            }
            if let currentVersionReleaseDate: String = $0["currentVersionReleaseDate"] as? String {
                appInfo.currentVersionReleaseDate = currentVersionReleaseDate
            }
            if let sellerName: String = $0["sellerName"] as? String {
                appInfo.sellerName = sellerName
            }
            if let trackCensoredName: String = $0["trackCensoredName"] as? String {
                appInfo.trackCensoredName = trackCensoredName
            }
            if let languageCodesISO2A: [String] = $0["languageCodesISO2A"] as? [String] {
                appInfo.languageCodesISO2A = languageCodesISO2A
            }
            if let fileSizeBytes: String = $0["fileSizeBytes"] as? String {
                appInfo.fileSizeBytes = fileSizeBytes
            }
            if let sellerUrl: String = $0["sellerUrl"] as? String {
                appInfo.sellerUrl = sellerUrl
            }
            if let contentAdvisoryRating: String = $0["contentAdvisoryRating"] as? String {
                appInfo.contentAdvisoryRating = contentAdvisoryRating
            }
            if let averageUserRating: Double = $0["averageUserRating"] as? Double {
                appInfo.averageUserRating = averageUserRating
            }
            if let trackViewUrl: String = $0["trackViewUrl"] as? String {
                appInfo.trackViewUrl = trackViewUrl
            }
            if let userRatingCount: Int = $0["userRatingCount"] as? Int {
                appInfo.userRatingCount = userRatingCount
            }
            if let trackContentRating: String = $0["trackContentRating"] as? String {
                appInfo.trackContentRating = trackContentRating
            }
            if let description: String = $0["description"] as? String {
                appInfo.description = description
            }
            if let genres: [String] = $0["genres"] as? [String] {
                appInfo.genres = genres
            }
            if let version: String = $0["version"] as? String {
                appInfo.version = version
            }
            if let releaseNotes: String = $0["releaseNotes"] as? String {
                appInfo.releaseNotes = releaseNotes
            }
            
            apps.append(appInfo)
        }
        return apps
    }
}
