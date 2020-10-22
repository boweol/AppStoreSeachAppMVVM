//
//  CALayer.swift
//  AppStoreSearchAppMVVM
//
//  Created by isens on 22/10/2020.
//  Copyright © 2020 isens. All rights reserved.
//

import UIKit

extension CALayer {
    
    func addBorder(_ edgeList: [UIRectEdge], thick: CGFloat, widthMargin: CGFloat) {
        for edge in edgeList {
            let border = CALayer()
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect.init(x: 0, y: 0, width: frame.width - widthMargin, height: thick)
                break
            case UIRectEdge.bottom:
                border.frame = CGRect.init(x: 0, y: frame.height - thick, width: frame.width - widthMargin, height: thick)
                break
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: 0, width: thick, height: frame.height)
                break
            case UIRectEdge.right:
                border.frame = CGRect.init(x: frame.width - thick, y: 0, width: thick, height: frame.height)
                break
            default:
                break
            }
            
            border.backgroundColor = UIColor.systemGray6.cgColor
            self.addSublayer(border)
        }
    }
}

