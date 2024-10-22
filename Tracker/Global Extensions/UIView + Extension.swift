//
//  UIView + Extension.swift
//  Tracker
//
//  Created by  Admin on 16.10.2024.
//

import UIKit

extension UIView {
    func superview<T>(of type: T.Type) -> T? {
        return superview as? T ?? superview?.superview(of: type)
    }
}
