//
//  CreatingTrackerViewController.swift
//  Tracker
//
//  Created by  Admin on 16.10.2024.
//

import UIKit

final class CreatingTrackerViewController: BaseTrackerViewController {
    
    private var trackerName: String?
    private var selectedColor: UIColor?
    private var selectedEmoji: String?
    private var isRegularEvent: Bool

    init(type: TrackerViewControllerType, isRegularEvent: Bool) {
        self.isRegularEvent = isRegularEvent
        super.init(type: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotificationObservers()
        dismissKeyboard(view: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCreateButtonState()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func textViewCellDidChange(_ cell: TextViewCell) {
        // Обновляем текст для trackerName каждый раз при изменении текста
        trackerName = cell.getText().text
        updateCreateButtonState()
    }
    
    override func didSelectCategory(_ category: TrackerCategory) {
        selectedCategory = category
        tableView.reloadData()
        updateCreateButtonState()
    }
    
    override func didSelect(_ days: [DayOfTheWeek]) {
        self.selectedDays = days
        updateCreateButtonState()
        tableView.reloadRows(
            at: [IndexPath(row: 1, section: TrackerSection.buttons.rawValue)],
            with: .automatic
        )
    }
    
    func updateCreateButtonState() {
        let textIsValid = !(trackerName?.isEmpty ?? true)
        let categoryIsSelected = selectedCategory != nil
        let colorIsSelected = selectedColor != nil
        let emojiIsSelected = selectedEmoji != nil && !(selectedEmoji?.isEmpty ?? true)
        let daysAreSelected = !selectedDays.isEmpty
        
        let isValid: Bool

        if isRegularEvent {
            isValid = textIsValid && daysAreSelected && categoryIsSelected && colorIsSelected && emojiIsSelected
        } else {
            isValid = textIsValid && categoryIsSelected && colorIsSelected && emojiIsSelected
        }
        
        if let createButtonCell = tableView.cellForRow(
            at: IndexPath(row: 0, section: TrackerSection.createButtons.rawValue)
        ) as? CreateButtonsViewCell {
            createButtonCell.updateCreateButtonState(isEnabled: isValid)
        }
    }

    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEmojiSelected),
            name: .emojiSelected,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleColorSelected),
            name: .colorSelected,
            object: nil)
    }
    
    func handleCreateButtonTapped() {
        guard let trackerName = trackerName, !trackerName.isEmpty,
              let selectedColor = selectedColor,
              let selectedEmoji = selectedEmoji
        else {
            Logger.shared.log(
                .error,
                message: "Не все обязательные поля заполнены для создания трекера"
            )
            return
        }
        
        let categoryTitle = selectedCategory?.title ?? "Новая категория"
        let scheduleStrings = selectedDays.map { String($0.rawValue) }

        let tracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: selectedColor.toHexString(),
            emoji: selectedEmoji,
            schedule: scheduleStrings,
            categoryTitle: categoryTitle,
            isRegularEvent: isRegularEvent,
            creationDate: Date()
        )
        
        let userInfo: [String: Any] = [
            "tracker": tracker,
            "categoryTitle": categoryTitle
        ]
        
        NotificationCenter.default.post(name: .trackerCreated, object: nil, userInfo: userInfo)
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }

    private func handleCancelButtonTapped() {
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
    
    @objc private func handleEmojiSelected(_ notification: Notification) {
        if let emoji = notification.userInfo?["selectedEmoji"] as? String {
            selectedEmoji = emoji
            updateCreateButtonState()
        }
    }
    
    @objc private func handleColorSelected(_ notification: Notification) {
        if let hexColor = notification.userInfo?["selectedColor"] as? String {
            selectedColor = UIColor(hex: hexColor)
            updateCreateButtonState()
        }
    }
}

extension CreatingTrackerViewController {
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        guard let trackerSection = TrackerSection(rawValue: section) else { return 0 }
        switch trackerSection {
        case .textView:
            return 1
        case .buttons:
            return isRegularEvent ? 2 : 1
        case .emoji, .color, .createButtons:
            return 1
        }
    }
}

// MARK: - cellForRowAt
extension CreatingTrackerViewController {
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewControllerType {
        case .creatingTracker:
            return configureCreatingTrackerCell(at: indexPath)
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - ConfigureCell
extension CreatingTrackerViewController {
    private func configureCreatingTrackerCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let trackerSection = TrackerSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        switch trackerSection {
        case .textView:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: TextViewCell.reuseIdentifier,
                for: indexPath
            ) as? TextViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        case .buttons:
            if !isRegularEvent && indexPath.row == 1 {
                return UITableViewCell()
            }
            let cell = UITableViewCell()
            let totalRows = isRegularEvent ? 2 : 1
            
            configureButtonCell(cell, at: indexPath, isSingleCell: isRegularEvent)
            configureBaseCell(cell, at: indexPath, totalRows: totalRows)
            configureSeparator(cell, isLastRow: indexPath.row == (isRegularEvent ? 1 : 0))
            cell.selectionStyle = .none
            return cell
        case .emoji:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: EmojiesAndColorsTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? EmojiesAndColorsTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: emojies, isEmoji: true)
            cell.selectionStyle = .none
            return cell
        case .color:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: EmojiesAndColorsTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? EmojiesAndColorsTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: colors, isEmoji: false)
            cell.selectionStyle = .none
            return cell
        case .createButtons:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CreateButtonsViewCell.reuseIdentifier,
                for: indexPath
            ) as? CreateButtonsViewCell else {
                return UITableViewCell()
            }
            
            cell.onCreateButtonTapped = { [weak self] in
                self?.handleCreateButtonTapped()
            }
            
            cell.onCancelButtonTapped = { [weak self] in
                self?.handleCancelButtonTapped()
            }
            cell.selectionStyle = .none
            return cell
        }
    }
}
