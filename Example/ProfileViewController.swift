//
//  ProfileViewController.swift
//  Example
//
//  Created by alex.huo on 2019/2/19.
//  Copyright © 2019 blessingsoft. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    let id: String

    init(id: String) {
        self.id = id
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = id
        view.backgroundColor = UIColor.white

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(handleRewind(_:)))
    }

    @objc func handleRewind(_ sender: UIBarButtonItem) {
        Router.route(to: .home)
    }
}
