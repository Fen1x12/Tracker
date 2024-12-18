//
//  FilterViewController.swift
//  Tracker
//
//  Created by  Admin on 27.11.2024.
//

import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

final class FilterViewController: UIViewController {
    
    var selectedFilter: TrackerFilter
    weak var delegate: FilterViewControllerDelegate?
    
    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let filters = [
        (LocalizationKey.filtersAllTrackers.localized(), TrackerFilter.allTrackers),
        (LocalizationKey.filtersOnToday.localized(), TrackerFilter.today),
        (LocalizationKey.filtersComplete.localized(), TrackerFilter.completed),
        (LocalizationKey.filtersNotComplete.localized(), TrackerFilter.uncompleted)
    ]
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBackground
        setupUI()
        title = LocalizationKey.filtersTitle.localized()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return filters.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        
        ConfigureTableViewCellsHelper.configureBaseCell(cell, at: indexPath, totalRows: filters.count)
        ConfigureTableViewCellsHelper.configureSeparator(cell, isLastRow: filters.count == indexPath.row + 1)
        
        let filter = filters[indexPath.row]
        cell.textLabel?.text = filter.0
        
        if (filter.1 == .allTrackers && (selectedFilter == .allTrackers || selectedFilter == .today)) ||
            (filter.1 == selectedFilter && (selectedFilter == .completed || selectedFilter == .uncompleted)) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 75
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        selectedFilter = filters[indexPath.row].1
        delegate?.didSelectFilter(selectedFilter)
        dismiss(animated: true)
    }
}
