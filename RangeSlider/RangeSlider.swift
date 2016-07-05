//
//  RangeSlider.swift
//  RangeSlider
//
//  Created by 田邉　裕貴 on 2016/07/04.
//  Copyright © 2016年 example. All rights reserved.
//

import UIKit

@IBDesignable
class RangeSlider: UIView {
    
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundBar: UIView!
    @IBOutlet weak var activeBar: UIView!
    @IBOutlet weak var leftThumb: UIView!
    @IBOutlet weak var rightThumb: UIView!
    @IBOutlet weak var leftThumbWrapperView: UIView!
    @IBOutlet weak var rightThumbWrapperView: UIView!
    
    // コードから初期化はここから
    override init(frame: CGRect) {
        super.init(frame: frame)
        comminInit()
    }
    
    // Storyboard/xib から初期化はここから
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        comminInit()
    }
    
    // xibからカスタムViewを読み込んで準備する
    private func comminInit() {
        // RangeSlider.xib からカスタムViewをロードする
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "RangeSlider", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil).first as! UIView
        addSubview(view)
        
        let leftGesture = UIPanGestureRecognizer(target: self, action: #selector(didDragLeftThumb(_:)))
        leftThumbWrapperView.addGestureRecognizer(leftGesture)
        let rightGesture = UIPanGestureRecognizer(target: self, action: #selector(didDragRightThumb(_:)))
        rightThumbWrapperView.addGestureRecognizer(rightGesture)
        
        // カスタムViewのサイズを自分自身と同じサイズにする
        view.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["view": view]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|",
            options:NSLayoutFormatOptions(rawValue: 0),
            metrics:nil,
            views: bindings))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|",
            options:NSLayoutFormatOptions(rawValue: 0),
            metrics:nil,
            views: bindings))
    }
    
    @IBInspectable
    var thumbBorderColor: UIColor = UIColor.clearColor() {
        didSet {
            leftThumb.layer.borderColor = thumbBorderColor.CGColor
            rightThumb.layer.borderColor = thumbBorderColor.CGColor
        }
    }
    
    @IBInspectable
    var thumbBorderWidth: CGFloat = 0 {
        didSet {
            leftThumb.layer.borderWidth = thumbBorderWidth
            rightThumb.layer.borderWidth = thumbBorderWidth
        }
    }
    
    @IBInspectable
    var thumbCornerRadius: CGFloat = 0 {
        didSet {
            leftThumb.layer.cornerRadius = thumbCornerRadius
            rightThumb.layer.cornerRadius = thumbCornerRadius
        }
    }
    
    @IBInspectable
    var borderCornerRadius: CGFloat = 0 {
        didSet {
            backgroundBar.layer.cornerRadius = borderCornerRadius
        }
    }
    
    func didDragLeftThumb(gestureRecognizer: UIPanGestureRecognizer) {
        let x = gestureRecognizer.locationInView(backgroundBar).x
        
        if x < 0 { return }
        if (x - rightConstraint.constant) >= backgroundBar.frame.width - 20 &&
           gestureRecognizer.translationInView(backgroundBar).x > 0
        {
            leftConstraint.constant = backgroundBar.frame.width - 20 + rightConstraint.constant
            return
        }
        
        leftConstraint.constant = x
    }
    
    func didDragRightThumb(gestureRecognizer: UIPanGestureRecognizer) {
        let x = gestureRecognizer.locationInView(backgroundBar).x
        let constant = x - backgroundBar.frame.width
        
        if x - backgroundBar.frame.width > 0 { return }
        if (leftConstraint.constant - constant) >= backgroundBar.frame.width - 20 &&
           gestureRecognizer.translationInView(backgroundBar).x < 0
        {
            rightConstraint.constant = leftConstraint.constant - backgroundBar.frame.width + 20
            return
        }
        
        rightConstraint.constant = constant
    }
}
