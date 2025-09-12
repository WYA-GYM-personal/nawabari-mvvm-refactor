//
//  ProfileViewModel.swift
//  WAY_GYM
//
//  Created by 이주현 on 9/12/25.
//

import Foundation

import SwiftUI

final class ProfileViewModel: ObservableObject {
    @AppStorage("selectedWeaponId") var selectedWeaponId: String = "0"
    private let minionService = MinionService()
    private let runRecordService = RunRecordService()
    
    var mainWeaponImageName: String {
        return "main_\(selectedWeaponId)"
    }
    var weaponIconImageName: String {
        return "weapon_\(selectedWeaponId)"
    }
    
    func load() {
        runRecordService.getTotalDistanceForRewards { [weak self] _ in
            DispatchQueue.main.async { self?.objectWillChange.send() }
        }
        runRecordService.getTotalCapturedAreaForRewards()
        DispatchQueue.main.async { [weak self] in self?.objectWillChange.send() }
    }

    var totalCapturedAreaText: String { "\(runRecordService.totalCapturedAreaValue)m²" }
    var totalDistanceKmText: String { "\(formatDecimal2(runRecordService.totalDistance / 1000)) km" }

    var hasUnlockedMinions: Bool {
        let unlocked = MinionModel.allMinions.filter { minion in
            return minionService.isUnlocked(minion, with: Int(runRecordService.totalDistance))
        }
        return !unlocked.isEmpty
    }

    var hasRunRecords: Bool { runRecordService.totalDistance > 0 }
}
