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

    private var isDraggCreatingEntry = false
    private var draggingStartTime: TimeInterval = 0
    private var draggingEndTime: TimeInterval = 0

    static let formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    // MARK: View

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        if #available(OSX 10.13, *) {
//            handleMouseClick(with: event)
        }

        // Single click and on empty space
        let clickedPoint = convert(event.locationInWindow, from: nil)
        guard event.clickCount == 1,
            indexPathForItem(at: clickedPoint) == nil else { return }

        guard let draggStartTimestamp = timestamp(from: event) else {
            return
        }
        draggingStartTime = draggStartTimestamp
        draggingEndTime = draggStartTimestamp + 1
        isDraggCreatingEntry = true

        NSLog("<< mouse down at \(Self.stringTime(from: draggStartTimestamp))")

        timelineDelegate?.timelineDidStartDragging(
            withStartTime: min(draggingStartTime, draggingEndTime),
            endTime: max(draggingStartTime, draggingEndTime)
        )
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        guard let draggTimestamp = timestamp(from: event) else {
            return
        }

        draggingEndTime = draggTimestamp

        NSLog("<< dragg << start: \(Self.stringTime(from: draggingStartTime)); end: \(Self.stringTime(from: draggingEndTime))")

        timelineDelegate?.timelineDidStartDragging(
            withStartTime: min(draggingStartTime, draggingEndTime),
            endTime: max(draggingStartTime, draggingEndTime)
        )
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)

        guard let draggEndTimestamp = timestamp(from: event) else {
            return
        }
        draggingEndTime = draggEndTimestamp
        isDraggCreatingEntry = false

        NSLog(">> mouse up at time \(Self.stringTime(from: draggEndTimestamp))")

        timelineDelegate?.timelineDidEndDragging(
            withStartTime: min(draggingStartTime, draggingEndTime),
            endTime: max(draggingStartTime, draggingEndTime)
        )
    }

    private func timestamp(from event: NSEvent) -> TimeInterval? {
        guard let flowLayout = collectionViewLayout as? TimelineFlowLayout else { return nil }

        // Convert to CollectionView coordinator
        let clickedPoint = convert(event.locationInWindow, from: nil)

        // Skip if the click is in Time Label and Activity section
        guard flowLayout.isInTimeEntrySection(at: clickedPoint) else { return nil }

        // Get timestamp from click point, depend on zoom level and position
        return flowLayout.convertTimestamp(from: clickedPoint)
    }

    private static func stringTime(from timestamp: TimeInterval) -> String {
        return Self.formatter.string(from: Date(timeIntervalSince1970: timestamp))
    }
}

// MARK: Private

extension TimelineCollectionView {

    fileprivate func handleMouseClick(with event: NSEvent) {
        guard let flowLayout = collectionViewLayout as? TimelineFlowLayout else { return }

        // Convert to CollectionView coordinator
        let clickedPoint = convert(event.locationInWindow, from: nil)

        // Single click and on empty space
        guard event.clickCount == 1,
            indexPathForItem(at: clickedPoint) == nil else { return }

        // Skip if the click is in Time Label and Activity section
        guard flowLayout.isInTimeEntrySection(at: clickedPoint) else { return }

        // Get timestamp from click point, depend on zoom level and position
        let timestamp = flowLayout.convertTimestamp(from: clickedPoint)
        timelineDelegate?.timelineShouldCreateEmptyEntry(with: timestamp)
    }
}
