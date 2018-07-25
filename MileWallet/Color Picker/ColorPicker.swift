//
//  ColorPicker.swift
//  MileWallet
//
//  Created by denn on 24.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import UIKit

//
// source: https://github.com/gkye/MaterialColorPicker
//

public class ColorPickerCell: UICollectionViewCell{
    
    func setup(){
        self.layer.cornerRadius = self.bounds.width / 2
    }
    
    //MARK: - Lifecycle
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


public protocol ColorPickerDataSource {
    ///
    /// Set colors for ColorPicker (optional. Default colors will be used if nil)
    /// - returns: should return an array of `UIColor`
    ///
    func colorPickerColors()->[UIColor]
}

extension ColorPickerDataSource {
}

public protocol ColorPickerDelegate{
    ///
    /// Return selected index and color for index
    ///
    /// - parameter index: index of selected item
    /// - parameter color: background color of selected item
    ///
    func colorPicker(_ colorPickerView: ColorPicker, didSelectIndex at: Int, color: UIColor)

    /// Customize selected cell
    ///
    /// - Parameters:
    ///   -  parameter colorPickerView: current colorPicker instantse
    ///   -  parameter cell: cell
    ///
    func colorPicker(_ colorPickerView: ColorPicker, didSelectCell cell: ColorPickerCell)
    
    /// Customize deselected cell
    ///
    /// - Parameters:
    ///   -  parameter colorPickerView: current colorPicker instantse
    ///   -  parameter cell: cell
    ///
    func colorPicker(_ colorPickerView: ColorPicker, didDeselectCell cell: ColorPickerCell)
    
    
    ///
    /// Return a size for the current cell (overrides default size)
    ///
    /// - parameter colorPickerView: current colorPicker instantse
    /// - parameter index:                   index of cell
    /// - returns: CGSize
    ///
    func sizeForCellAtIndex(_ colorPickerView: ColorPicker, index at: Int)->CGSize
}

extension ColorPickerDelegate {
    func sizeForCellAtIndex(_ colorPickerView: ColorPicker, index at: Int)->CGSize { return CGSize(width: 50, height: 50)}
    func colorPicker(_ colorPickerView: ColorPicker, didSelectCell cell: ColorPickerCell){
        cell.layer.borderWidth = colorPickerView.selectedBorderWidth
        cell.layer.borderColor = colorPickerView.selectionColor.cgColor
    }
    func colorPicker(_ colorPickerView: ColorPicker, didDeselectCell cell: ColorPickerCell){
        cell.layer.borderWidth = 0
        cell.layer.borderColor = UIColor.clear.cgColor
    }
}

open class ColorPicker: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    fileprivate var selectedIndex: IndexPath?
    
    public var dataSource: ColorPickerDataSource?

    open var delegate: ColorPickerDelegate?
    
    /// Color for border of selected cell
    open var selectionColor: UIColor = UIColor.black
    
    /// Border width for selected Cell
    open var selectedBorderWidth: CGFloat = 2
    
    /// Set spacing between cells
    open var cellSpacing: CGFloat = 2
    
    //Setup collectionview and flow layout
    lazy var collectionView: UICollectionView = {
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: self.bounds.height, height: self.bounds.height)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ColorPickerCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        initialize()
        addContrains(self, subView: collectionView)
    }
    
    fileprivate func initialize() {
        collectionView.removeFromSuperview()
        self.addSubview(self.collectionView)
    }
    
    //Select index programtically
    open func selectCellAtIndex(_ index: Int){
        let indexPath = IndexPath(row: index, section: 0)
        selectedIndex = indexPath
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        self.delegate?.colorPicker(self, didSelectIndex: (self.selectedIndex! as NSIndexPath).item,
                                             color: (dataSource?.colorPickerColors() ?? [])[index])
        animateCell(manualSelection: true)
    }
    
    //MARK: CollectionView DataSouce
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.colorPickerColors().count ?? 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ColorPickerCell
       
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        
        cell.backgroundColor =  (dataSource?.colorPickerColors() ?? [])[(indexPath as NSIndexPath).item]
        
        if indexPath == selectedIndex {
            cell.isSelected = true
            delegate?.colorPicker(self, didSelectCell: cell)
        }else{
            cell.isSelected = false
            delegate?.colorPicker(self, didDeselectCell: cell)
        }
        return cell
    }
    
    //MARK: CollectionView delegate
    private var lastIndexPath:IndexPath?
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath
        animateCell()
        lastIndexPath = selectedIndex
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let size = delegate?.sizeForCellAtIndex(self, index: (indexPath as NSIndexPath).row){
            return size
        }
        
        return CGSize(width: self.bounds.height, height: self.bounds.height - 1)
    }
    
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    
    
    /**
     Animate cell on selection
     */
    fileprivate func animateCell(manualSelection: Bool = false){
        
        let duration = 0.1
        
        if let l = lastIndexPath {
            self.collectionView.reloadItems(at: [l])
        }

        if let cell = collectionView.cellForItem(at: selectedIndex!){
            UIView.animate(withDuration: duration , animations: {() -> Void in
                cell.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
            }, completion: {(finished: Bool) -> Void in
                UIView.animate(withDuration: duration , animations: {() -> Void in
                    cell.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
                }, completion: {(finished: Bool) -> Void in
                    UIView.animate(withDuration: duration , animations: {() -> Void in
                        cell.transform = CGAffineTransform.identity
                        if !manualSelection{
                            self.delegate?.colorPicker(self, didSelectIndex: (self.selectedIndex! as NSIndexPath).item, color: cell.backgroundColor!)
                        }
                        let set = [self.selectedIndex!]
                        self.collectionView.reloadItems(at: set)
                    })
                })
            })
        }
    }
    
    fileprivate func addContrains(_ superView: UIView, subView: UIView){
        subView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["myView" : subView]
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[myView]|", options:[] , metrics: nil, views: views))
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[myView]|", options:[] , metrics: nil, views: views))
    }
}


//Shuffle extension

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffle() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in startIndex ..< endIndex - 1 {
            let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
            if i != j {
                self.swapAt(i, j)
            }
        }
    }
}
