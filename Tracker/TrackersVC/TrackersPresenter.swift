//
//  TrackersPresenter.swift
//  Tracker
//
//  Created by  Admin on 16.10.2024.
//

import Foundation

// MARK: - Protocol
protocol TrackersPresenterProtocol: AnyObject {
    var view: TrackersViewControllerProtocol? { get set }
    var dateFormatter: DateFormatter { get }
    
    func addTracker(_ tracker: Tracker, categoryTitle: String)
    func trackerCompletedMark(_ trackerId: UUID, date: String)
    func trackerCompletedUnmark(_ trackerId: UUID, date: String)
    func isTrackerCompleted(_ trackerId: UUID, date: String) -> Bool
    func handleTrackerSelection(_ tracker: Tracker, isCompleted: Bool, date: Date)
    func isDateValidForCompletion(date: Date) -> Bool
    func filterTrackers(for date: Date, searchText: String?, filter: TrackerFilter)
    func loadTrackers()
    func loadCompletedTrackers()
    func deleteTracker(at indexPath: IndexPath)
    func togglePin(for tracker: Tracker)
    func updateTracker(_ updatedTracker: Tracker)
    func showContextMenu(for tracker: Tracker, at indexPath: IndexPath)
}

// MARK: - Object
final class TrackersPresenter: TrackersPresenterProtocol {
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    private let pinnedCategoryKey = "pinned_category_key"
    private let filterManager: TrackersFilterManager?
    private let statisticsViewModel: StatisticsViewModel
    
    weak var view: TrackersViewControllerProtocol?
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale.current
        return dateFormatter
    }()
    
    init(
        trackerStore: TrackerStore,
        categoryStore: TrackerCategoryStore,
        recordStore: TrackerRecordStore,
        statisticsStore: StatisticsStore,
        filterManager: TrackersFilterManager?
    ) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        self.filterManager = filterManager
        self.statisticsViewModel = StatisticsViewModel(
            statisticsStore: statisticsStore
        )
    }
    
    func addTracker(_ tracker: Tracker, categoryTitle: String) {
        do {
            let category = TrackerCategory(title: categoryTitle, trackers: [])
            try categoryStore.addCategory(category)
            try trackerStore.addTracker(tracker)
            loadTrackers()
        } catch {
            Logger.shared.log(
                .error,
                message: "Ошибка при добавлении трекера: \(tracker.name)",
                metadata: ["❌": error.localizedDescription]
            )
        }
    }
    
    func trackerCompletedMark(_ trackerId: UUID, date: String) {
        guard let view else { return }
        
        if isTrackerCompleted(trackerId, date: date) {
            return
        }
        
        let newRecord = TrackerRecord(trackerId: trackerId, date: date)
        do {
            try recordStore.addRecord(newRecord)
            
            statisticsViewModel.updateStatisticsAfterAction(trackerStore: trackerStore, recordStore: recordStore)
            
            loadCompletedTrackers()
            view.reloadData()
        } catch {
            Logger.shared.log(
                .error,
                message: "Ошибка при добавлении записи для трекера \(trackerId) на дату \(date)",
                metadata: ["❌": error.localizedDescription]
            )
        }
    }
    
    func trackerCompletedUnmark(_ trackerId: UUID, date: String) {
        do {
            try recordStore.removeRecord(for: trackerId, on: date)
            
            statisticsViewModel.updateStatisticsAfterAction(trackerStore: trackerStore, recordStore: recordStore)
            
            self.loadCompletedTrackers()
            view?.reloadData()
        } catch {
            Logger.shared.log(
                .error,
                message: "Ошибка при удалении записи для трекера \(trackerId) на дату \(date)",
                metadata: ["❌": error.localizedDescription]
            )
        }
    }
    
    func isTrackerCompleted(_ trackerId: UUID, date: String) -> Bool {
        let records = recordStore.fetchRecords()
        return records.contains { $0.trackerId == trackerId && $0.date == date }
    }
    
    func handleTrackerSelection(_ tracker: Tracker, isCompleted: Bool, date: Date) {
        let currentDateString = dateFormatter.string(from: date)
        
        if isCompleted {
            trackerCompletedUnmark(tracker.id, date: currentDateString)
        } else {
            trackerCompletedMark(tracker.id, date: currentDateString)
        }
  
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self else { return }
            self.view?.reloadData()
        }
    }
    
    func isDateValidForCompletion(date: Date) -> Bool {
        return date <= Date()
    }
    
    func filterTrackers(for date: Date, searchText: String?, filter: TrackerFilter) {
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: date)
        let adjustedIndex = (weekdayIndex + 5) % 7
        let selectedDayString = String(DayOfTheWeek.allCases[adjustedIndex].rawValue)

        let dateString = dateFormatter.string(from: date)
        let completedTrackerIds = recordStore.fetchCompletedTrackerIds(for: dateString)
        let predicate = filterManager?.createPredicate(
            for: date,
            filter: filter,
            completedTrackerIds: completedTrackerIds
        )
        
        trackerStore.fetchTrackers(predicate: predicate)
        let filteredTrackers = trackerStore.fetchTrackers()

        var finalFilteredTrackers = filteredTrackers.filter { trackerCoreData in
            let tracker = Tracker(from: trackerCoreData)

            if tracker.isRegularEvent {
                let matchesSchedule = tracker.schedule.contains(selectedDayString)
                if let searchText = searchText?.lowercased(), !searchText.isEmpty {
                    let matchesSearch = tracker.name.lowercased().contains(searchText)
                    return matchesSchedule && matchesSearch
                } else {
                    return matchesSchedule
                }
            } else {
                guard let creationDate = tracker.creationDate else {
                    Logger.shared.log(
                        .error,
                        message: "Ошибка: у трекера \(tracker.name) нет creationDate."
                    )
                    return false
                }
                let isSameDay = calendar.isDate(creationDate, inSameDayAs: date)
                if let searchText = searchText?.lowercased(), !searchText.isEmpty {
                    let matchesSearch = tracker.name.lowercased().contains(searchText)
                    return isSameDay && matchesSearch
                } else {
                    return isSameDay
                }
            }
        }
        
        finalFilteredTrackers.sort { $0.isPinned && !$1.isPinned }
        let categorizedTrackers = categorizeTrackers(finalFilteredTrackers)
  
        view?.updateFilterButtonVisibility()
        view?.categories = categorizedTrackers
        view?.visibleCategories = categorizedTrackers
        view?.reloadData()
    }

    func togglePin(for tracker: Tracker) {
        var updatedTracker = tracker
        updatedTracker.isPinned.toggle()

        do {
            if updatedTracker.isPinned {
                updatedTracker.originalCategoryTitle = tracker.categoryTitle
            }

            try trackerStore.updateTracker(updatedTracker)

            filterTrackers(for: view?.currentDate ?? Date(), searchText: nil, filter: .allTrackers)
        } catch {
            Logger.shared.log(
                .error,
                message: "Не удалось закрепить трекер: \(tracker.name)"
            )
        }
    }
    
    func loadTrackers() {
        let loadedTrackers = trackerStore.fetchTrackers()
        let categorizedTrackers = categorizeTrackers(loadedTrackers)
        
        view?.categories = categorizedTrackers
        view?.visibleCategories = categorizedTrackers
        view?.reloadData()
    }

    func loadCompletedTrackers() {
        let loadedCompletedTrackers = recordStore.fetchRecords()
        let tempCompletedTrackers = Set(loadedCompletedTrackers.map { TrackerRecord(from: $0) })
        
        if tempCompletedTrackers != view?.completedTrackers {
            view?.completedTrackers = tempCompletedTrackers
        }
        view?.reloadData()
    }

    func categorizeTrackers(_ trackerCoreDataList: [TrackerCoreData]) -> [TrackerCategory] {
        var groupedTrackers: [String: [Tracker]] = Dictionary(
            grouping: trackerCoreDataList.map { Tracker(from: $0) },
            by: { $0.isPinned ? pinnedCategoryKey : $0.categoryTitle }
        )

        var categories: [TrackerCategory] = []
        if let pinnedTrackers = groupedTrackers.removeValue(forKey: pinnedCategoryKey) {
            let pinnedCategory = TrackerCategory(
                title: LocalizationKey.pinnedCategory.localized(),
                trackers: pinnedTrackers
            )
            categories.append(pinnedCategory)
        }

        let sortedCategories = groupedTrackers.map { (title, trackers) in
            TrackerCategory(title: title, trackers: trackers)
        }

        categories.append(contentsOf: sortedCategories)

        return categories
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        guard let view else { return }
        
        let trackerToDelete = view.categories[indexPath.section].trackers[indexPath.row]
        
        do {
            try trackerStore.deleteTracker(withId: trackerToDelete.id)

            filterTrackers(for: view.currentDate, searchText: nil, filter: .allTrackers)
        } catch {
            Logger.shared.log(
                .error,
                message: "Ошибка при удалении трекера \(trackerToDelete.name)",
                metadata: ["❌": error.localizedDescription]
            )
        }
    }
    
    func updateTracker(_ updatedTracker: Tracker) {
        do {
            try trackerStore.updateTracker(updatedTracker)
            loadTrackers()
        } catch {
            Logger.shared.log(.error, message: "Ошибка при обновлении трекера \(updatedTracker.name)")
        }
    }
    
    func showContextMenu(for tracker: Tracker, at indexPath: IndexPath) {
        guard let completedTrackers = view?.completedTrackers else { return }
        let contextMenuHelper = TrackersContextMenuHelper(
            tracker: tracker,
            indexPath: indexPath,
            presenter: self,
            viewController: TrackersViewController(),
            completedTrackers: completedTrackers
        )
        _ = contextMenuHelper.createContextMenu()
    }
}
