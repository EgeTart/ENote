//
//  HistoryNotesLayout.swift
//  ENote
//
//  Created by min-mac on 16/12/5.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

import UIKit

protocol HistoryNoteLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForContentAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat
}

class HistoryNotesLayout: UICollectionViewLayout {
    
    var delegate: HistoryNoteLayoutDelegate!
    
    let numberOfColumns = 2
    let cellPadding: CGFloat = 6.0
    
    private var cache = [UICollectionViewLayoutAttributes]()
    
    private var contentHeight: CGFloat = 0.0
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return (collectionView!.bounds).width - (insets.left + insets.right)
    }
    
    private let fixHeight: CGFloat = 38.0
    
    override func prepare() {
        
        if cache.isEmpty {
            let columnWidth = contentWidth / CGFloat(numberOfColumns)
            var xOffset = [CGFloat]()
            for column in 0..<numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth + cellPadding)
            }
            
            var column = 0
            var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
            
            let numberOfSections = collectionView!.numberOfSections
            for section in 0..<numberOfSections {
                for item in 0..<collectionView!.numberOfItems(inSection: section) {
                    
                    let indexPath = IndexPath(item: item, section: section)
                    
                    let width = columnWidth - 2 * cellPadding
                    let contentLabelHeight = delegate.collectionView(collectionView!, heightForContentAtIndexPath: indexPath, withWidth: width)
                    let height = contentLabelHeight + fixHeight + cellPadding * 5.8
                    
                    let frame = CGRect(x: xOffset[column], y: yOffset[column], width: width, height: height)
                    let insetFrame = frame.insetBy(dx: 2.0, dy: cellPadding)
                    
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = insetFrame
                    cache.append(attributes)
                    
                    contentHeight = max(contentHeight, frame.maxY)
                    yOffset[column] = yOffset[column] + height
                    
                    column = (column >= numberOfColumns - 1) ? 0 : column + 1
                }
                
                column = 0
                
                let maxYOffset = yOffset.max()!
                for column in 0..<numberOfColumns {
                    yOffset[column] = maxYOffset
                }
            }
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        
        return layoutAttributes
    }
}
