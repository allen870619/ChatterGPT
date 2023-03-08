//
//  ChatboxCell.swift
//  ChatGPT
//
//  Created by Lee Yen Lin on 2023/3/8.
//

import UIKit

class SendChatboxCell: ChatboxCell {
    @IBOutlet var lbMessage: UILabel!

    override func awakeFromNib() {
        backgroundColor = .systemGray4
    }

    override func setMessage(_ message: String) {
        lbMessage.text = message
    }
}

class RecvChatboxCell: ChatboxCell {
    @IBOutlet var lbMessage: UILabel!

    override func awakeFromNib() {
        backgroundColor = .systemGray6
    }

    override func setMessage(_ message: String) {
        lbMessage.text = message
    }
}

class ChatboxCell: UITableViewCell {
    func setMessage(_: String) {}
}
