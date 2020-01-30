//
//  Recording.swift
//  DTAssist
//
//  Created by Manisha Sharma on 29/01/20.
//  Copyright © 2020 Manisha Sharma. All rights reserved.
//

import Foundation
import UIKit

protocol RecordViewDelegate: class {
    
    func RecordViewDidSelectRecord(sender : RecordView, button: UIView)
    func RecordViewDidStopRecord(sender : RecordView, button: UIView)
    func RecordViewDidCancelRecord(sender : RecordView, button: UIView)
    
}

class RecordView: UIView {
    enum RecordViewState {
        
        case Recording
        case None
        
    }
    
    var state : RecordViewState = .None {
        
        didSet {
            
            UIView.animate(withDuration: 0.3) { () -> Void in
                
                self.slideToCancel.alpha = 1.0
                self.invalidateIntrinsicContentSize()
                self.setNeedsLayout()
                self.layoutIfNeeded()
                
            }
            
        }
    }
    
    let recordButton : UIButton = UIButton(type: .custom)
    let slideToCancel : UILabel = UILabel(frame: CGRect.zero)
    
    weak var delegate : RecordViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        setupRecordButton()
        setupLabel()
    }


    func setupRecordButton() {
        
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(recordButton)
        let hConsts = NSLayoutConstraint.constraints(withVisualFormat: "H:[recordButton]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["recordButton":recordButton])
        self.addConstraints(hConsts)
        
        let vConsts = NSLayoutConstraint.constraints(withVisualFormat: "V:|[recordButton]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["recordButton":recordButton])
        self.addConstraints(vConsts)
        
        recordButton.setImage(UIImage(named: "record")!, for: .normal)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(userDidTapRecord(_:)))
        longPress.cancelsTouchesInView = false
        longPress.allowableMovement = 10
        longPress.minimumPressDuration = 0.2
        recordButton.addGestureRecognizer(longPress)
        
    }
    
    func setupLabel() {
        
        slideToCancel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(slideToCancel)
        backgroundColor = UIColor.clear
        
        let hConsts = NSLayoutConstraint.constraints(withVisualFormat: "H:|[slideToCancel][bt]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["slideToCancel":slideToCancel,"bt":recordButton])
        self.addConstraints(hConsts)
        
        let vConsts = NSLayoutConstraint.constraints(withVisualFormat: "V:|[slideToCancel]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["slideToCancel":slideToCancel])
        self.addConstraints(vConsts)
        
        slideToCancel.alpha = 0.0
        slideToCancel.font = UIFont(name: "Lato-Bold", size: 17)
        slideToCancel.textAlignment = .center
        slideToCancel.textColor = UIColor.black
    }
    
    
    override public var intrinsicContentSize: CGSize {
        if state == .none {
            return recordButton.intrinsicContentSize
        } else {
            
            return CGSize(width: recordButton.intrinsicContentSize.width * 3, height: recordButton.intrinsicContentSize.height)
        }
    }
    
    func userDidTapRecordThenSwipe(sender: UIButton) {
        slideToCancel.text = nil
         // delegate?.RecordViewDidCancelRecord(sender: self, button: sender)
    }
    
    func userDidStopRecording(sender: UIButton) {
        slideToCancel.text = nil
        delegate?.RecordViewDidStopRecord(sender: self, button: sender)
    }
    
    func userDidBeginRecord(sender : UIButton) {
        slideToCancel.text = "Slide to cancel <"
        delegate?.RecordViewDidSelectRecord(sender: self, button: sender)
        
    }
    
    @objc func userDidTapRecord(_ sender: UIGestureRecognizer) {
        
        print("Long Tap \(sender.state)")
        
        let button = sender.view as! UIButton
        
        let location = sender.location(in: button)
        
        var startLocation = CGPoint.zero
        
        switch sender.state {
            
        case .began:
            startLocation = location
            userDidBeginRecord(sender: button)
        case .changed:
            
            let translate = CGPoint(x: location.x - startLocation.x, y: location.y - startLocation.y)
            
            if !button.bounds.contains(translate) {
                
                if state == .Recording {
                    userDidTapRecordThenSwipe(sender: button)
                }
            }
        case .ended:
            
            if state == .None { return }
            
//            let translate = CGPoint(x: location.x - startLocation.x, y: location.y - startLocation.y)
//
//            if !button.frame.contains(translate) {
//
//                userDidStopRecording(sender: button)
//
//            }
            userDidStopRecording(sender: button)
        case .failed, .possible ,.cancelled :
            
            if state == .Recording {
                userDidStopRecording(sender: button)
            }
            else {
                userDidTapRecordThenSwipe(sender: button)
            }
            
        }
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
