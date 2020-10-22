//
//  DetailViewModel.swift
//  AppStoreSearchAppMVVM
//
//  Created by isens on 20/10/2020.
//  Copyright © 2020 isens. All rights reserved.
//

import RxSwift
import RxCocoa

class DetailViewModel {
    let receivedData = BehaviorRelay<AppInfo?>(value: nil)
    var infoTableData = BehaviorRelay<[[String: Any]]>(value: [])
    
    func addInfoTableData(_ info: [String: Any]) {
        infoTableData.accept(infoTableData.value + [info])
    }
}
