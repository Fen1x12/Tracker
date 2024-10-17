//
//  LayoutConfigurator.swift
//  Tracker
//
//  Created by  Admin on 16.10.2024.
//

import UIKit

protocol LayoutConfigurator {
    func setupLayout(
        in view: UIView,
        with tableView: UITableView)
}

final class DefaultLayoutConfigurator: LayoutConfigurator {
    func setupLayout(
        in view: UIView,
        with tableView: UITableView) {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
