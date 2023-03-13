//
//  MainChatViewController.swift
//  ChatGPT
//
//  Created by Lee Yen Lin on 2023/3/8.
//

import Combine
import iOSCommonUtils
import RxSwift
import UIKit

class MainChatViewController: KBShifterViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var btnSend: UIButton!
    @IBOutlet var tvMessage: UITextView!

    private var viewModel = MainChatViewModel()
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        shiftMode = .kbHeight

        tableView.delegate = self
        tableView.dataSource = self

        btnSend.addAction(.init(handler: { [unowned self] _ in
            self.tvMessage.endEditing(true)
            if let message = self.tvMessage.text {
                self.viewModel.sendMessageRx(message: message)
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { data in
                        self.newMessage(data)
                    })
                    .disposed(by: self.disposeBag)
                self.tvMessage.text.removeAll()
            }
        }), for: .touchUpInside)
    }

    deinit {
        disposeBag = DisposeBag()
    }

    /// Update table when notified by data update.
    /// - Parameter data: receive data pack
    private func newMessage(_ data: Message) {
        let animation: UITableView.RowAnimation = data.role == "user" ? .right : .left
        let count = viewModel.messageList.count
        let indexPath = IndexPath(row: count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: animation)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
