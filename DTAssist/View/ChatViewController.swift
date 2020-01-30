//
//  ChatViewController.swift
//  DTAssist
//
//  Created by Manisha Sharma on 30/01/20.
//  Copyright © 2020 Manisha Sharma. All rights reserved.
//

import UIKit
import AI
import AVFoundation
import Speech

let rec = RecordView(frame: CGRect.zero)

class ChatViewController: UIViewController {
    @IBOutlet var contentView: UIView!
    @IBOutlet var chatCollView: UICollectionView!
    @IBOutlet var inputViewContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet var chatTF: UITextField!
    @IBOutlet var recordView: UIView!
    
    var chatsArray: [Chat] = []
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    
    private let audioEngine = AVAudioEngine()

    var aiResponse: QueryResponse!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // permission
        SFSpeechRecognizer.requestAuthorization { [unowned self] authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    print("Good to go!")
                } else {
                    print("Transcription permission was declined.")
                }
            }
        }

        self.navigationItem.title = "DT Assist"
        self.assignDelegates()
        self.manageInputEventsForTheSubViews()
        
      
        rec.delegate = self
        recordView.addSubview(rec)
        
        let hConsts = NSLayoutConstraint.constraints(withVisualFormat: "H:[bt]-(2)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["bt":rec])
        recordView.addConstraints(hConsts)
        
        let vConsts = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(2)-[bt]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["bt":rec])
        recordView.addConstraints(vConsts)
        
        
        let fileMgr = FileManager.default

        let dirPaths = fileMgr.urls(for: .documentDirectory,
                        in: .userDomainMask)

        let soundFileURL = dirPaths[0].appendingPathComponent("sound.caf")
        let recordSettings =
        [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
                 AVEncoderBitRateKey: 16,
                 AVNumberOfChannelsKey: 2,
                 AVSampleRateKey: 44100.0] as [String : Any]
        let audioSession = AVAudioSession.sharedInstance()
        do {
              //  try audioSession.setCategory(
              //      AVAudioSession.Category.playAndRecord)
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }

        do {
            try audioRecorder = AVAudioRecorder(url: soundFileURL,
                settings: recordSettings as [String : AnyObject])
            audioRecorder?.prepareToRecord()
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        audioRecorder?.delegate = self
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private func manageInputEventsForTheSubViews() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChangeNotfHandler(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChangeNotfHandler(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardFrameChangeNotfHandler(_ notification: Notification) {
        
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            inputViewContainerBottomConstraint.constant = isKeyboardShowing ? keyboardFrame.height : 0
            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                
                if isKeyboardShowing {
                    let lastItem = self.chatsArray.count - 1
                    let indexPath = IndexPath(item: lastItem, section: 0)
                    self.chatCollView.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
            })
        }
    }
    
    private func assignDelegates() {
        
        self.chatCollView.register(ChatCell.self, forCellWithReuseIdentifier: ChatCell.identifier)
        self.chatCollView.dataSource = self
        self.chatCollView.delegate = self
        
        self.chatTF.delegate = self
    }
    
    @IBAction func onSendChat(_ sender: UIButton?) {
        guard let chatText = chatTF.text, chatText.count >= 1 else { return }
        chatTF.text = ""
        showChat(chatText, false)
    }
    
    func showChat(_ chatText: String, _ is_sent_by_me: Bool) {
        let chat = Chat.init(user_name: "", user_image_url: nil, is_sent_by_me: is_sent_by_me, text: chatText)
        self.chatsArray.append(chat)
        self.chatCollView.reloadData()

        let lastItem = self.chatsArray.count - 1
        let indexPath = IndexPath(item: lastItem, section: 0)
        //        self.chatCollView.insertItems(at: [indexPath])
        self.chatCollView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        self.chatCollView.reloadData()
        if !is_sent_by_me {
         requestAIResponse(text: chatText)
        }
    }

    func requestAIResponse(text: String) {
        AI.sharedService.textRequest(text ?? "").success {[weak self] (response) -> Void in
            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else {
                    return
                }
                sSelf.aiResponse = response
                let reply = self?.aiResponse.result.fulfillment?.messages.first?.speech
                let utterance = AVSpeechUtterance(string: reply ?? "hi")
                utterance.volume = 1
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

                utterance.rate = 0.5

                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                
                if let chatText = reply {
                    self?.showChat(chatText, true)
                }
            }
        }.failure { (error) -> Void in
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Error",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                
                alert.addAction(
                    UIAlertAction(
                        title: "Cancel",
                        style: .cancel,
                        handler: .none
                    )
                )
                
                self.present(
                    alert,
                    animated: true,
                    completion: .none
                )
            }
        }
    }
}

extension ChatViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return chatsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = chatCollView.dequeueReusableCell(withReuseIdentifier: ChatCell.identifier, for: indexPath) as? ChatCell {
            
            let chat = chatsArray[indexPath.item]
            
            cell.messageTextView.text = chat.text
            cell.nameLabel.text = chat.user_name
//            if let url = chat.user_image_url {
//             cell.profileImageURL = URL.init(string: url)
//            }
            
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            var estimatedFrame = NSString(string: chat.text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], context: nil)
            estimatedFrame.size.height += 18
            
            let nameSize = NSString(string: chat.user_name).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)], context: nil)
            
            let maxValue = max(estimatedFrame.width, nameSize.width)
            estimatedFrame.size.width = maxValue
            
            
            if chat.is_sent_by_me {
                if cell.displayState == .option {
                    cell.addSubview(cell.yesButton)
                    cell.addSubview(cell.noButton)
        
                    cell.messageTextView.frame = CGRect(x: 12, y: 12, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                    cell.textBubbleView.frame = CGRect(x: 6, y: -4, width: estimatedFrame.width + 16 + 8 + 16 + 12, height: estimatedFrame.height + 20 + 6)
                    cell.yesButton.frame = CGRect(x: 10, y: estimatedFrame.height + 22, width: 40, height: 30)
                    cell.noButton.frame = CGRect(x: 40 + 20 , y: estimatedFrame.height + 22 , width: 40 , height: 30)
                    
                    cell.bubbleImageView.image = ChatCell.grayBubbleImage
                    cell.messageTextView.textColor = UIColor.black
                    cell.nameLabel.textAlignment = .left
                    cell.bubbleImageView.tintColor = UIColor(white: 0.95, alpha: 1)
                } else {
                    cell.nameLabel.textAlignment = .left
                    cell.messageTextView.frame = CGRect(x: 48 + 8, y: 12, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                    cell.textBubbleView.frame = CGRect(x: 48 - 10, y: -4, width: estimatedFrame.width + 16 + 8 + 16 + 12, height: estimatedFrame.height + 20 + 6)
                    cell.bubbleImageView.image = ChatCell.grayBubbleImage
                    cell.bubbleImageView.tintColor = UIColor(white: 0.95, alpha: 1)
                    cell.messageTextView.textColor = UIColor.black
                }
                
            } else {
                cell.nameLabel.frame = CGRect(x: collectionView.bounds.width - estimatedFrame.width - 16 - 16 - 8 - 30 - 12, y: 0, width: estimatedFrame.width + 16, height: 18)
                cell.messageTextView.frame = CGRect(x: collectionView.bounds.width - estimatedFrame.width - 16 - 16 - 8 - 30, y: 12, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.textBubbleView.frame = CGRect(x: collectionView.frame.width - estimatedFrame.width - 16 - 8 - 16 - 10 - 30, y: -4, width: estimatedFrame.width + 16 + 8 + 10, height: estimatedFrame.height + 20 + 6)
                cell.bubbleImageView.image = ChatCell.blueBubbleImage
                cell.bubbleImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                cell.messageTextView.textColor = UIColor.white
            }
            
            return cell
        }
        
        return ChatCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let chat = chatsArray[indexPath.item]
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        var estimatedFrame = NSString(string: chat.text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], context: nil)
        estimatedFrame.size.height += 18
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCell.identifier, for: indexPath) as! ChatCell
        if cell.displayState == .option {
            estimatedFrame.size.height += 40
        }
        return CGSize(width: chatCollView.frame.width, height: estimatedFrame.height + 20)
    }
    
}

extension ChatViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let txt = textField.text, txt.count >= 1 {
            textField.resignFirstResponder()
            return true
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        textField.resignFirstResponder()
        onSendChat(nil)
    }
}


extension ChatViewController : RecordViewDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    func RecordViewDidCancelRecord(sender: RecordView, button: UIView) {
        
        sender.state = .None
        
        print("Cancelled")
        audioRecorder?.stop()
    }
    
    func RecordViewDidSelectRecord(sender: RecordView, button: UIView) {
        
        sender.state = .Recording
        
        print("Began ")
        audioRecorder?.record()
    }
    
    func RecordViewDidStopRecord(sender : RecordView, button: UIView) {
        
        sender.state = .None
        
        print("Done")
        audioRecorder?.stop()
    }
    
    
     // player delegate method
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    //        recordButton.isEnabled = true
    //        stopButton.isEnabled = false
            print("did finish")
        }

        func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
            print("Audio Play Decode Error")
        }

        func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
            print("flag \(flag)")
            let recognizer = SFSpeechRecognizer()
            let fileMgr = FileManager.default

            let dirPaths = fileMgr.urls(for: .documentDirectory,
                            in: .userDomainMask)

            let soundFileURL = dirPaths[0].appendingPathComponent("sound.caf")
            let request = SFSpeechURLRecognitionRequest(url: soundFileURL)

            // start recognition!
            recognizer?.recognitionTask(with: request) { [weak self] (result, error) in
                // abort if we didn't get any transcription back
                guard let result = result else {
                    print("There was an error: \(error!)")
                    return
                }

                // if we got the final transcription back, print it
                if result.isFinal {
                    // pull out the best transcription...
                    print(result.bestTranscription.formattedString)
                    let chatText = result.bestTranscription.formattedString
//                    let chat = Chat.init(user_name: "", user_image_url: nil, is_sent_by_me: false, text: chatText)
//                    self?.chatsArray.append(chat)
//                    self?.chatCollView.reloadData()
//                    if let count = self?.chatsArray.count {
//                        let lastItem = count - 1
//                        let indexPath = IndexPath(item: lastItem, section: 0)
//                        self?.chatCollView.scrollToItem(at: indexPath, at: .bottom, animated: true)
//                    }
                    self?.showChat(chatText, false)
                }
            }
        }

        func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
            print("Audio Record Encode Error")
        }
}
