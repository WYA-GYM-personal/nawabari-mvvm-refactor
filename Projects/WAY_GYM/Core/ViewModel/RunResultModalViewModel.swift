//
//  RunResultModalViewModel.swift
//  WAY_GYM
//
//  Created by 이주현 on 9/12/25.
//

import Foundation
import SwiftUI

final class RunResultModalViewModel: ObservableObject {
    @Published var latestRecord: RunRecordModel?
    @Published var hasReward: Bool = false
    @Published var rewardQueue: [RewardType] = []
    @Published var showRewardQueue: Bool = false

    @Published var routeImageURL: URL?
    @Published var capturedValue: Int = 0
    @Published var duration: TimeInterval?
    @Published var distance: Double?
    @Published var calories: Double?

    private var runRecordVM: RunRecordService!
    private let minionService = MinionService()
    private let weaponService = WeaponService()

    func loadRecentRunRecord(with runRecordVM: RunRecordService) {
        self.runRecordVM = runRecordVM

        runRecordVM.getLatestRouteImage { [weak self] urlString in
            guard let self = self else { return }
            if let urlString = urlString, let url = URL(string: urlString) {
                DispatchQueue.main.async { self.routeImageURL = url }
            }
        }

        runRecordVM.getLatestRunStats { [weak self] duration, distance, calories in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.duration = duration
                self.distance = distance
                self.calories = calories
            }
        }

        runRecordVM.getLatestCapturedArea { [weak self] value in
            guard let self = self else { return }
            if let value = value {
                DispatchQueue.main.async { self.capturedValue = Int(value) }
            }
        }

        runRecordVM.fetchRunRecordsFromFirestore()

        collectRewards()
    }

    private func collectRewards() {
        var collected: [RewardType] = []

        weaponService.checkWeaponUnlockOnStop { [weak self] unlocked in
            guard let self = self else { return }
            let weaponRewards = unlocked.map { RewardType.weapon($0) }
            collected.append(contentsOf: weaponRewards)
            print("해금된 무기: \(unlocked.map { $0.id })")

            self.minionService.checkMinionUnlockOnStop { [weak self] unlockedMinions in
                guard let self = self else { return }
                let minionRewards = unlockedMinions.map { RewardType.minion($0) }
                print("해금된 미니언: \(unlockedMinions.map { $0.id })")

                // 미니언을 앞으로
                collected.insert(contentsOf: minionRewards, at: 0)

                DispatchQueue.main.async {
                    if !collected.isEmpty {
                        self.rewardQueue = collected
                        self.hasReward = true
                    }
                }
            }
        }
    }

    var hasRewardQueue: Bool {
        !rewardQueue.isEmpty
    }
}
