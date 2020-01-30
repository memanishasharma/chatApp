//
//  ChatCells.swift
//  DTAssist
//
//  Created by Manisha Sharma on 30/01/20.
//  Copyright © 2020 Manisha Sharma. All rights reserved.
//

import Foundation
import UIKit

enum DisplayState: String {
 case option
 case message
 case chartView
}

class ChatCell: UICollectionViewCell {
    
    static let identifier = String(describing: ChatCell.self)
    
    var displayState: DisplayState = .option
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    static let grayBubbleImage = UIImage(named: "bubble_gray")!.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    static let blueBubbleImage = UIImage(named: "bubble_blue")!.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    
    var messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = "Sample message"
        textView.backgroundColor = UIColor.clear
        textView.isScrollEnabled = false
        textView.isEditable = false
        return textView
    }()
    
    var textBubbleView: UIView = {
        let view = UIView()
        //        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
         // imageView.image = #imageLiteral(resourceName: "sendIcon")
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ChatCell.blueBubbleImage
        imageView.tintColor = UIColor(white: 0.90, alpha: 1)
        return imageView
    }()
    
    var nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .right
        lbl.textColor = AppConstants.magentaColor
        lbl.font = UIFont.boldSystemFont(ofSize: 15)
        return lbl
    }()
    
    var yesButton: UIButton = {
        let button = UIButton()
        button.setTitle("YES", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.backgroundColor = UIColor.systemGray2
        button.layer.cornerRadius = 2

        return button
    }()
    
    var noButton: UIButton = {
        let button = UIButton()
        button.setTitle("NO", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.backgroundColor = UIColor.systemGray2
        button.layer.cornerRadius = 2

        return button
    }()

    private func setupViews() {
        addSubview(textBubbleView)
        addSubview(nameLabel)
        addSubview(messageTextView)
        textBubbleView.addSubview(bubbleImageView)
        addConstraintsWithVisualStrings(format: "H:|[v0]|", views: bubbleImageView)
        addConstraintsWithVisualStrings(format: "V:|[v0]|", views: bubbleImageView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
         // self.profileImageView.image = nil
        self.messageTextView.text = nil
    }
}
