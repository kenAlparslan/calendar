//
//  ExtensionUIImage.swift
//  calender
//
//  Created by Ken Alparslan on 2021-07-11.
//

import UIKit

extension UIImage {
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
