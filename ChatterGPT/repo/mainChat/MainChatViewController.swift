//
//  MainChatViewController.swift
//  ChatGPT
//
//  Created by Lee Yen Lin on 2023/3/8.
//

import Combine
import iOSCommonUtils
import UIKit

class MainChatViewController: KBShifterViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var btnSend: UIButton!
    @IBOutlet var tvMessage: UITextView!

    private var viewModel = MainChatViewModel()

    override func viewDidLoad() {
        shiftMode = .kbHeight

        viewModel.delegate = self

        tableView.delegate = self
        tableView.dataSource = self

        btnSend.addAction(.init(handler: { [weak self] _ in
            self?.tvMessage.endEditing(true)
            if let message = self?.tvMessage.text {
                self?.viewModel.sendMessage(message: message)
                self?.tvMessage.text.removeAll()
            }
        }), for: .touchUpInside)
    }

    deinit {
        print(#function)
    }
}

extension MainChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        viewModel.messageList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = viewModel.messageList[indexPath.row]
        var cell: ChatboxCell?
        if data.role != "user" {
            cell = tableView.dequeueReusableCell(withIdentifier: "recvChatboxCell") as? RecvChatboxCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "sendChatboxCell") as? SendChatboxCell
        }
        cell?.setMessage(data.content)
        return cell ?? UITableViewCell()
    }
}

extension MainChatViewController: MainChatDelegate {
    func notifyUpdateMessageTable() {
        DispatchQueue.main.async { [self] in

            let animation: UITableView.RowAnimation = viewModel.messageList.last?.role == "user" ? .right : .left
            let count = viewModel.messageList.count
            let indexPath = IndexPath(row: count - 1, section: 0)
            tableView.insertRows(at: [indexPath], with: animation)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}
