//
//  Created by Pete Smith
//  http://www.petethedeveloper.com
//
//
//  License
//  Copyright © 2017-present Pete Smith
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit

/*
 ScalingCarouselLayout is used together with SPBCarouselView to
 provide a carousel-style collection view.
*/
open class ScalingCarouselLayout: UICollectionViewFlowLayout {

    open var inset: CGFloat = 0.0
    
    
    /// Initialize a new carousel-style layout
    ///
    /// - parameter inset: The carousel inset
    ///
    /// - returns: A new carousel layout instance
    convenience init(withCarouselInset inset: CGFloat = 0.0) {
        self.init()
        self.inset = inset
    }
    
    override open func prepare() {

        guard let collectionViewSize = collectionView?.frame.size else { return }

        // Set itemSize based on total width and inset
        itemSize = collectionViewSize
        itemSize.width = itemSize.width - (inset * 2)

        // Set scrollDirection and paging
        scrollDirection = .horizontal
        collectionView?.isPagingEnabled = true

        minimumLineSpacing = 0.0
        minimumInteritemSpacing = 0.0

        sectionInset = UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: 0.0)
        footerReferenceSize = CGSize.zero
        headerReferenceSize = CGSize.zero
    }
    
    /*override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }
        
        return attributes
    }*/

}
