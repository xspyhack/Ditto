//
//  HomeViewController.swift
//  Example
//
//  Created by alex.huo on 2019/2/19.
//  Copyright © 2019 blessingsoft. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        Router.shared.delegate = self
    }

    @IBAction func routeToUser(_ sender: Any) {
        let user = User(id: "xspyhack", name: "alex")
        Router.route(to: user)
    }

    @IBAction func openBrowser(_ sender: Any) {
        let url = URL(string: "https://www.apple.com")!
        Router.route(to: .browser(url))
    }
}

extension HomeViewController: RoutingCoordinatorDelegate {
    func coordinatorRepresentation() -> RoutingCoordinator.Representaion {
        if let presented = self.presentedViewController as? UINavigationController {
            return .push(from: presented, animated: true)
        }

        if let navigationController = navigationController {
            return .push(from: navigationController, animated: true)
        } else {
            return .present(from: self, animated: true)
        }
    }
}
