//
//  ChatCells.swift
//  DTAssist
//
//  Created by Manisha Sharma on 30/01/20.
//  Copyright © 2020 Manisha Sharma. All rights reserved.
//

import Foundation
import UIKit

class ChatCell: UICollectionViewCell {
    
    static let identifier = String(describing: ChatCell.self)
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

    //    var chat: ChatModel? {
    //        didSet{
    //            guard let sender = chat else { return }
    //            self.setupTextViewLayout(chat: sender)
    //            if let url = URL.init(string: sender.user_image_url) {
    //                fetchProfileImage(from: url)
    //            }
    //            self.bubbleImageView.image = sender.is_sent_by_me ? grayBubbleImage : blueBubbleImage
    //            self.messageTextView.text = sender.text
    //        }
    //    }
    
//    private var imageCache = NSCache<NSString, UIImage>()
//    var profileImageURL: URL? {
//        didSet{
//            self.fetchProfileImage(from: profileImageURL!)
//        }
//    }
//
//    func fetchProfileImage(from url: URL) {
//
//        //If image is available in cache, use it
//        if let img = self.imageCache.object(forKey: url.absoluteString as NSString) {
//            DispatchQueue.main.async {
//                self.profileImageView.image = img
//            }
//            //Otherwise fetch from remote and cache it for futher use
//        } else {
//
//            let session = URLSession.init(configuration: .default)
//            session.dataTask(with: url) { (data, response, error) in
//                DispatchQueue.main.async {
//                    if let imgData = data {
//                        if let img = UIImage(data: imgData) {
//                            self.profileImageView.image = img
//                            self.imageCache.setObject(img, forKey: url.absoluteString as NSString)
//                        }
//                    }
//                }
//                }.resume()
//        }
//    }
    
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
    
//    var profileImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
//        imageView.layer.cornerRadius = 15
//         // imageView.image = #imageLiteral(resourceName: "sendIcon")
//        imageView.layer.masksToBounds = true
//        return imageView
//    }()
    
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
