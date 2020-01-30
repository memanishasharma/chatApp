//
//  Chat.swift
//  DTAssist
//
//  Created by Manisha Sharma on 30/01/20.
//  Copyright © 2020 Manisha Sharma. All rights reserved.
//

import Foundation
import UIKit

struct Chat: Codable {
    
    var user_name: String!
    var user_image_url: String?
    var is_sent_by_me: Bool
    var text: String!
}
