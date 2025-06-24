//
//  StatisticsServiceProtocol.swift
//  Tracker
//
//  Created by Алина on 19.06.2025.
//

protocol StatisticsServiceProtocol {
    func calculate(records: [TrackerRecord], trackers: [Tracker]) -> Statistics
}
