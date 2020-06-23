//
//  TimelineCollectionView.swift
//  TogglDesktop
//
//  Created by Nghia Tran on 9/9/19.
//  Copyright © 2019 Alari. All rights reserved.
//

import Cocoa

protocol TimelineCollectionViewDelegate: class {
    func timelineShouldCreateEmptyEntry(with startTime: TimeInterval)
    func timelineDidStartDragging(withStartTime startTime: TimeInterval, endTime: TimeInterval)
    func timelineDidUpdateDragging(withStartTime startTime: TimeInterval, endTime: TimeInterval)
    func timelineDidEndDragging(withStartTime startTime: TimeInterval, endTime: TimeInterval)
}

/// Main View of the Timline
/// Responsible for handling the Click Action on the cell
/// We don't use didSelection on CollectionView because we couldn't select twice on the selected view
final class TimelineCollectionView: NSCollectionView {

    // MARK: Variables

    weak var timelineDelegate: TimelineCollectionViewDelegate?

    // TODO: rename
    private var isDraggCreatingEntry = false
    private var draggingStartTime: TimeInterval = 0
    private var draggingEndTime: TimeInterval = 0

    // MARK: View

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)

        guard isDraggToCreateEvent(event) else { return }
        guard let draggStartTimestamp = timestamp(from: event) else {
            return
        }
        draggingStartTime = draggStartTimestamp
        draggingEndTime = draggStartTimestamp + 1
        isDraggCreatingEntry = true

        timelineDelegate?.timelineDidStartDragging(
            withStartTime: min(draggingStartTime, draggingEndTime),
            endTime: max(draggingStartTime, draggingEndTime)
        )
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        guard isDraggCreatingEntry else { return }
        guard let draggTimestamp = timestamp(from: event) else { return }
        draggingEndTime = draggTimestamp

        timelineDelegate?.timelineDidStartDragging(
            withStartTime: min(draggingStartTime, draggingEndTime),
            endTime: max(draggingStartTime, draggingEndTime)
        )
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)

        guard isDraggCreatingEntry else { return }
        guard let draggEndTimestamp = timestamp(from: event) else { return }
        draggingEndTime = draggEndTimestamp
        isDraggCreatingEntry = false

        timelineDelegate?.timelineDidEndDragging(
            withStartTime: min(draggingStartTime, draggingEndTime),
            endTime: max(draggingStartTime, draggingEndTime)
        )
    }

    // MARK: - Private

    private func isDraggToCreateEvent(_ event: NSEvent) -> Bool {
        let clickedPoint = convert(event.locationInWindow, from: nil)
        guard event.clickCount == 1 && indexPathForItem(at: clickedPoint) == nil else {
            return false
        }
        guard let layout = collectionViewLayout as? TimelineFlowLayout else { return false }

        return layout.isInTimeEntrySection(at: clickedPoint)
    }

    private func timestamp(from event: NSEvent) -> TimeInterval? {
        guard let layout = collectionViewLayout as? TimelineFlowLayout else { return nil }
        let location = convert(event.locationInWindow, from: nil)
        return layout.convertTimestamp(from: location)
    }
}
