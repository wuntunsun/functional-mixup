//
//  ViewController.swift
//  functional-mixup
//
//  Created by Robert Norris on 31.01.21.
//

import UIKit


import functional



class ViewController: UIViewController {

    private var organizations: Organizations? = nil
    lazy var tableViewController: UITableViewController = {

        let controller = UITableViewController(style: .plain)

        controller.tableView.separatorStyle = .none
        controller.tableView.register(UITableViewCell.self
                                      , forCellReuseIdentifier: String(describing: self))

        controller.tableView.layoutMargins = UIEdgeInsets.zero

        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // it has a child view controller
        // that has no extras other than being a UITableViewController
        // it also uses a standard UITableViewCell
        // the DTO is a class because it must conform to protocol UITableViewDataSource
        // which inherits from NSObjectProtocol...
        // a class protocol ': class' or ': AnyObject' does not imply ': NSObject' but
        // ': NSObject' implies ': AnyObject'
        // the question is how quickly can control be handed off to a value type
        // and back again without too much boilerplate code?

        self.addChild(self.tableViewController)
        self.view.addSubview(self.tableViewController.tableView)
        self.tableViewController.didMove(toParent: self)

        self.tableViewController.view.frame = self.view.frame

        Organizations.withOrganizations { result in

            self.organizations = try? result.get()

            DispatchQueue.main.async {

                self.tableViewController.tableView.dataSource = self.organizations
                self.tableViewController.tableView.reloadData()
            }
        }
    }
}



protocol UPModel {

}



protocol UPController {

    // prevents UPController being used as type due to Self or associatedtype
    //associatedtype Model : UPModel

    mutating func viewDidLoad(_ viewController: UPViewController)

    func viewDidLayoutSubviews(_ viewController: UPViewController)
}



struct FooModel: UPModel {

    var title: String?
}



struct FooController: UPController {

    private(set) var model: FooModel

    init(_ model: FooModel) {

        self.model = model
    }

    mutating func setTitle(_ title: String?, viewController: UIViewController? = nil) {

        self.model.title = title

        if let button = viewController?.view.viewWithTag(666) as? UIButton {

            // poor practice...
            // is 'layout' often enough for this?
            button.setTitle(title, for: .normal)
        }
    }

    mutating func viewDidLoad(_ viewController: UPViewController) {

        let button = UIButton()
        button.tag = 666 // can use the tag to identify but poor practice...
        viewController.view.addSubview(button)

        //@objc can only be used with members of classes, @objc protocols, and concrete extensions of classes
        //button.addTarget(self, action: #selector(onButtonPressed), for: .touchUpInside)

        // iOS 14 introduced UIAction which allows for anonymous handling
        button.addAction(UIAction(title: "", handler: { action in

            guard let button = action.sender as? UIButton else {

                return
            }

            if button.title(for: .normal) == "Foo" {

                // self is a struct that can mutate which is not allowed...
                //self.setTitle("Bar", viewController: viewController)
                self.model.title = "Bar"
            }

            if button.title(for: .normal) == "Bar" {

                //self.setTitle("Foo", viewController: viewController)
                self.model.title = "Foo"
            }

        }), for: .touchUpInside)

        button.setTitle(self.model.title, for: .normal)

        let disposables: [Disposable] = [

            // Instance method 'bind(_:to:at:)' requires that 'FooViewModel' be a class type
            //button.bind(\.titleLabel.text, to: self, at: \.header)
        ]
    }

    func viewDidLayoutSubviews(_ viewController: UPViewController) {

    }
}




class UPViewController: UIViewController {

    private(set) var controller: UPController

    init(controller: UPController) {

        self.controller = controller

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        self.controller.viewDidLoad(self)
    }

    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        self.controller.viewDidLayoutSubviews(self)
    }
}

let test = {

    var model = FooModel(title: "Foo") // notifies -> controller ?
    var controller = FooController(model) // updates -> model, updates -> view ?
    let viewController = UPViewController(controller: controller) // user-action -> controller

    // the controller is updating model and view
    // rather than have the model being observed
    // this is a typical controller action
    // the controller setting up an observer is just an abstraction of this

    // updates -> view
    controller.setTitle("Bar", viewController: viewController)

    // a more natural way would be to change the model, have the model 'notify' the
    // controller which in turn 'updates' the view.
    model.title = "Moo" // notifies -> controller
    // UINotificationSystem
}()


