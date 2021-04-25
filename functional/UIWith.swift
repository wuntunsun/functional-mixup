//
//  UIWith.swift
//  functional
//
//  Created by Robert Norris on 31.01.21.
//

import UIKit



///
/// Completes with the `UITableView.headerView` for the given `section`.
///
/// Suitable for the generic global pure function 'with' once all but completion are bound.
///
/// - Warning: Calls `UITableViewDelegate.viewForHeaderInSection` if needed.
///
/// Usage:
///
///     curry(withHeaderView)(tableView)(forSection)
///
/// - Parameters:
///     - tableView: The UITableView from which a UITableView.headerView is to be retrieved.
///     - for: The section for which the UITableView.headerView.
///     - completion: The resulting UIView of the given concrete *ViewType*
///     - viewType: The concrete UIView type you expect.
///
public func withHeaderView<ViewType: UIView>(tableView: UITableView
    , for section: Int
    , completion: (_ viewType: ViewType?) -> ()) {

    let headerView = tableView.headerView(forSection: section) as? ViewType

    guard let delegate = tableView.delegate
        , headerView == nil else {

        completion(headerView)
        return
    }

    completion(delegate.tableView?(tableView, viewForHeaderInSection: section) as? ViewType)
}

public func withTableViewCell<TableViewCellType: UITableViewCell>(tableView: UITableView
    , at indexPath: IndexPath
    , completion: (_ tableViewCell: TableViewCellType?) -> ()) {

    let tableViewCell = tableView.cellForRow(at: indexPath) as? TableViewCellType

    guard let dataSource = tableView.dataSource
        , tableViewCell == nil else {

        completion(tableViewCell)
        return
    }

    completion(dataSource.tableView(tableView, cellForRowAt: indexPath) as? TableViewCellType)
}
