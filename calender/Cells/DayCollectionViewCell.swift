//
//  DayCollectionViewCell.swift
//  calender
//
//  Created by Ken Alparslan on 2021-07-11.
//

import UIKit

class DayCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var container: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
       
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
       
        var frame = layoutAttributes.frame
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame
       
        return layoutAttributes
    }
}
