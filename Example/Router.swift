//
//  Router.swift
//  Example
//
//  Created by alex.huo on 2019/2/19.
//  Copyright © 2019 blessingsoft. All rights reserved.
//

import UIKit
import Ditto
import SafariServices

class Router {
    static let shared = Router()

    static let schemes: [String] = ["https", "http", "alligator"]
    static let hosts: [String] = ["www.alligator.com", "alligator.com", "www.alligator.org"]

    private let router: Ditto.Router<RoutingCoordinator>

    var appCoordinator: AppCoodinator?
    weak var delegate: RoutingCoordinatorDelegate?

    private init() {
        router = Ditto.Router(schemes: Router.schemes, hosts: Router.hosts)
    }

    static func register() {
        do {
            try shared.router.register([
                // 首页
                // alligator://home
                ("/home", { context in
                    let rootViewController = shared.appCoordinator?.rootViewController
                    rootViewController?.navigationController?
                        .popToRootViewController(animated: context.coordinator.animated)
                    return true
                }),
                // 用户主页
                // alligator://user/[id]
                ("/user/:id", { context in
                    guard let id: String = try? context.argument(forKey: "id") else {
                        return false
                    }

                    let vc = ProfileViewController(id: id)
                    let coordinator = context.coordinator
                    coordinator.show(vc)
                    return true
                }),
                // 用浏览器打开链接
                // alligator://browser?link=[url]
                ("/browser", { context in
                    guard let url: URL = context.parameter(forKey: "link") else {
                        return false
                    }
                    // always present
                    let safariViewController = SFSafariViewController(url: url)
                    let coordinator = context.coordinator
                    coordinator.present(safariViewController)
                    return true
                }),
                // 切换环境
                // alligator://development/environment?type=[debug|release]
                ("/development/environment", { context in
                    guard let environment: Environment = context.parameter(forKey: "type") else {
                        return false
                    }

                    print("switch to environment: \(environment)")
                    return true
                }),
            ])
        } catch {
            print("register router failed with error: \(error)")
        }
    }

    @discardableResult
    static func route(to destination: Routable, isFromLaunching: Bool = false) -> Bool {
        guard let representation = shared.delegate?.coordinatorRepresentation() else {
            return false
        }
        let coordinator = RoutingCoordinator(isFromLaunching: isFromLaunching, representation: representation)
        return shared.router.route(to: destination, coordinator: coordinator)
    }

    static func responds(to destination: Routable) -> Bool {
        guard let representation = shared.delegate?.coordinatorRepresentation() else {
            return false
        }
        let coordinator = RoutingCoordinator(isFromLaunching: false, representation: representation)
        return shared.router.responds(to: destination, coordinator: coordinator)
    }

    @discardableResult
    static func route(to url: URL, isFromLaunching: Bool = false) -> Bool {
        guard let representation = shared.delegate?.coordinatorRepresentation() else {
            return false
        }
        let coordinator = RoutingCoordinator(isFromLaunching: isFromLaunching, representation: representation)
        return shared.router.route(to: url, coordinator: coordinator)
    }

    static func responds(to url: URL) -> Bool {
        guard let representation = shared.delegate?.coordinatorRepresentation() else {
            return false
        }
        let coordinator = RoutingCoordinator(isFromLaunching: false, representation: representation)
        return shared.router.responds(to: url, coordinator: coordinator)
    }
}

extension Router {

    enum Endpoint: Routable {
        case home
        case profile(String)
        case browser(URL)
        case development(Environment)

        var url: URL {
            switch self {
            case .home:
                return URL(string: "alligator://home")!
            case .profile(let id):
                return URL(string: "alligator://user/\(id)")!
            case .browser(let link):
                return URL(string: "alligator://browser?link=\(link)")!
            case .development(let environment):
                return URL(string: "alligator://development/environment?type=\(environment.rawValue)")!
            }
        }
    }

    @discardableResult
    static func route(to endpoint: Endpoint, isFromLaunching: Bool = false) -> Bool {
        guard let representation = shared.delegate?.coordinatorRepresentation() else {
            return false
        }
        let coordinator = RoutingCoordinator(isFromLaunching: isFromLaunching, representation: representation)
        return shared.router.route(to: endpoint, coordinator: coordinator)
    }

    static func responds(to endpoint: Endpoint) -> Bool {
        guard let representation = shared.delegate?.coordinatorRepresentation() else {
            return false
        }
        let coordinator = RoutingCoordinator(isFromLaunching: false, representation: representation)
        return shared.router.responds(to: endpoint, coordinator: coordinator)
    }
}

struct AppCoodinator {
    weak var rootViewController: UIViewController?

    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
}

struct RoutingCoordinator {
    enum Representaion {
        case push(from: UINavigationController, animated: Bool)
        case present(from: UIViewController, animated: Bool)

        var animated: Bool {
            switch self {
            case .push(_, animated: let animated):
                return animated
            case .present(_, animated: let animated):
                return animated
            }
        }

        var viewController: UIViewController {
            switch self {
            case .push(from: let viewController, _):
                return viewController
            case .present(from: let viewController, _):
                return viewController
            }
        }
    }

    let isFromLaunching: Bool
    let representation: Representaion

    /// 如果是 from launching，则忽略 coordinator 里面的 animated
    var animated: Bool {
        return isFromLaunching ? false : representation.animated
    }

    /// 用来 present 的 view controller
    var viewController: UIViewController {
        return representation.viewController
    }

    /// present 一个 view controller
    func present(_ vc: UIViewController) {
        viewController.present(vc, animated: animated, completion: nil)
    }

    /// 根据当前的场景来 push 一个 view controller
    func pushViewController(_ vc: UIViewController) {
        (viewController as? UINavigationController)?.pushViewController(vc, animated: animated)
    }

    /// 根据 representaion 决定是 push 还是 present
    func show(_ vc: UIViewController) {
        switch representation {
        case .push(let navigationController, _):
            navigationController.pushViewController(vc, animated: animated)
        case .present(let viewController, _):
            viewController.present(vc, animated: animated, completion: nil)
        }
    }
}

protocol RoutingCoordinatorDelegate: class {
    func coordinatorRepresentation() -> RoutingCoordinator.Representaion
}

struct User {
    let id: String
    let name: String
}

extension User: Routable {
    public var url: URL {
        return URL(string: "https://www.alligator.com/user/\(id)")!
    }
}

enum Environment: String {
    case release
    case debug
}

extension Environment: Extractable {
    public static func extract(from string: String) -> Environment? {
        return Environment(rawValue: string)
    }
}
