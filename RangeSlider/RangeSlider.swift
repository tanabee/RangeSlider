//
//  RangeSlider.swift
//  RangeSlider
//
//  Created by 田邉　裕貴 on 2016/07/04.
//  Copyright © 2016年 example. All rights reserved.
//

import UIKit

protocol RangeSliderDelegate: class {
    /**
     * 値の変更を伝える
     * left: 0-1 の Float
     * right: 0-1 の Float
     **/
    func rangeSliderValueChanged(left: Float, right: Float)
}

@IBDesignable
class RangeSlider: UIView {
    
    weak var delegate: RangeSliderDelegate?
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundBar: UIView!
    @IBOutlet weak var activeBar: UIView!
    @IBOutlet weak var leftThumb: UIView!
    @IBOutlet weak var rightThumb: UIView!
    var recentValue: (Float, Float) = (0, 1)
    
    var thumbWidth: CGFloat {
        return leftThumb.frame.width
    }
    
    // コードから初期化はここから
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    // Storyboard/xib から初期化はここから
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // xibからカスタムViewを読み込んで準備する
    private func commonInit() {
        // RangeSlider.xib からカスタムViewをロードする
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "RangeSlider", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil).first as! UIView
        addSubview(view)
        
        let leftGesture = UIPanGestureRecognizer(target: self, action: #selector(didDragLeftThumb(_:)))
        leftThumb.addGestureRecognizer(leftGesture)
        leftThumb.layer.cornerRadius = leftThumb.frame.width/2
        let rightGesture = UIPanGestureRecognizer(target: self, action: #selector(didDragRightThumb(_:)))
        rightThumb.addGestureRecognizer(rightGesture)
        rightThumb.layer.cornerRadius = rightThumb.frame.width/2
        
        NSNotificationCenter
            .defaultCenter()
            .addObserver(self,
                         selector: #selector(orientationChanged(_:)),
                         name: UIDeviceOrientationDidChangeNotification, object: nil)
        
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
    var borderCornerRadius: CGFloat = 0 {
        didSet {
            backgroundBar.layer.cornerRadius = borderCornerRadius
        }
    }
    
    /**
     * 値をセットする
     * left: 左のつまみの値 (0-1 の Float)
     * right: 右のつまみの値 (0-1 の Float)
     */
    func setValue(left: Float, right: Float) {
        if left < 0 || left > 1 || right < 0 || right > 1 || left > right { return }
        leftConstraint.constant = backgroundBar.frame.width * CGFloat(left)
        rightConstraint.constant = backgroundBar.frame.width * (CGFloat(right) - 1)
    }
    
    func didDragLeftThumb(gestureRecognizer: UIPanGestureRecognizer) {
        let x = gestureRecognizer.locationInView(backgroundBar).x
        
        if x < 0 {
            leftConstraint.constant = 0
            valueChanged()
            return
        }
        if (x - rightConstraint.constant) >= backgroundBar.frame.width - thumbWidth &&
           gestureRecognizer.translationInView(backgroundBar).x > 0
        {
            leftConstraint.constant = backgroundBar.frame.width - thumbWidth + rightConstraint.constant
            valueChanged()
            return
        }
        
        leftConstraint.constant = x
        valueChanged()
    }
    
    func didDragRightThumb(gestureRecognizer: UIPanGestureRecognizer) {
        let x = gestureRecognizer.locationInView(backgroundBar).x
        let constant = x - backgroundBar.frame.width
        
        if x - backgroundBar.frame.width > 0 {
            rightConstraint.constant = 0
            valueChanged()
            return
        }
        
        if (leftConstraint.constant - constant) >= backgroundBar.frame.width - thumbWidth &&
           gestureRecognizer.translationInView(backgroundBar).x < 0
        {
            rightConstraint.constant = leftConstraint.constant - backgroundBar.frame.width + thumbWidth
            valueChanged()
            return
        }
        
        rightConstraint.constant = constant
        valueChanged()
    }
    
    // 値が変更された時に呼び出される
    // 値が変更されている場合にデリゲートメソッドを実行する
    private func valueChanged() {
        let width = backgroundBar.frame.width
        let left = Float(leftConstraint.constant / width)
        let right = Float((width + rightConstraint.constant) / width)
        
        if recentValue == (left, right) { return }
        recentValue = (left, right)
        
        delegate?.rangeSliderValueChanged(left, right: right)
    }
    
    func orientationChanged(notification: NSNotification) {
        self.layoutIfNeeded()
        UIView.animateWithDuration(0.3) {
            self.setValue(self.recentValue.0, right: self.recentValue.1)
            self.layoutIfNeeded()
        }
    }
}
