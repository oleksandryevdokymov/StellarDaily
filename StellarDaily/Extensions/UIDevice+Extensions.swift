//
//  UIDevice+Extensions.swift
//  StellarDaily
//
//  Created by Oleksandr Yevdokymov on 14.02.2026.
//

import UIKit

extension UIDevice {
    static var isPad: Bool {
        return Self.current.userInterfaceIdiom == .pad
    }
}
