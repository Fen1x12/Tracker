//
//  TypeTrackersLayoutConfigurator.swift
//  Tracker
//
//  Created by  Admin on 16.10.2024.
//

import UIKit

final class TypeTrackersLayoutConfigurator: LayoutConfigurator {
    func setupLayout(
        in view: UIView,
        with tableView: UITableView) {
        let numberOfCells = 2
        let cellHeight: CGFloat = 60
        let spacing: CGFloat = 16
        let tableHeight = CGFloat(numberOfCells) * cellHeight + CGFloat(numberOfCells - 1) * spacing
        
        NSLayoutConstraint.activate([
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            tableView.heightAnchor.constraint(equalToConstant: tableHeight)
        ])
    }
}
