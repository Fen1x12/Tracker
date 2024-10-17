//
//  ViewController + Extension DataSource.swift
//  Tracker
//
//  Created by  Admin on 16.10.2024.
//

import UIKit

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return categories[section].trackers.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard indexPath.section < categories.count else {
            Logger.shared.log(
                .error,
                message: "Недопустимый section: \(indexPath.section), всего секций: \(categories.count)"
            )
            return UICollectionViewCell()
        }
        
        let trackers = categories[indexPath.section].trackers
        guard indexPath.row < trackers.count else {
            Logger.shared.log(
                .error,
                message: "Недопустимый row: \(indexPath.row), всего элементов в секции: \(trackers.count)"
            )
            return UICollectionViewCell()
        }
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackersCardCell.reuseIdentifier,
            for: indexPath) as? TrackersCardCell else {
            return UICollectionViewCell()
        }
        
        let tracker = trackers[indexPath.row]
        let currentDateString = presenter?.dateFormatter.string(from: currentDate) ?? ""
        let trackerId = tracker.id
        let isRegularEvent = tracker.isRegularEvent
        
        let isCompletedToday = completedTrackers.contains { record in
            return record.trackerId == trackerId && record.date == currentDateString
        }
        
        let isDateValidForCompletion = presenter?.isDateValidForCompletion(date: currentDate) ?? false
        
        cell.configure(
            with: tracker,
            countComplete: completedTrackers,
            isCompleted: isCompletedToday,
            isDateValidForCompletion: isDateValidForCompletion,
            isRegularEvent: isRegularEvent
        )
        
        cell.selectButtonTappedHandler = { [weak self] in
            guard let self = self else { return }

            if isDateValidForCompletion {
                self.presenter?.handleTrackerSelection(
                    tracker,
                    isCompleted: isCompletedToday,
                    date: self.currentDate
                )
                collectionView.reloadItems(at: [indexPath])
            }
        }
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier,
            for: indexPath) as? SectionHeaderView else { return UICollectionReusableView() }
        
        let title = categories[indexPath.section].title
        header.addTitle(title)
        
        return header
    }
}