//
//  RunRecordModelsViewModel.swift
//  WAY_GYM
//
//  Created by 이주현 on 6/4/25.
//
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
import SwiftUI
import MapKit

class RunRecordService: ObservableObject {
    @Published var runRecords: [RunRecordModel] = []
    
    @Published var totalDistance: Double = 0.0
    
    @Published var distance: Double?
    @Published var duration: TimeInterval?
    @Published var calories: Double?
    
    private var db = Firestore.firestore()

    // MARK: - Rewards Prereq: 누적 거리/면적 합계 (Unlock 조건 계산)
    // 서버에서 달린 거리의 합 가져오기
    func getTotalDistanceForRewards(completion: @escaping (Double) -> Void) {
        db.collection("RunRecordModels")
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("⚠️ 런닝 총거리 불러오기 실패: \(error?.localizedDescription ?? "")")
                    completion(0.0)
                    return
                }
                
                let distances = documents.compactMap { doc -> Double? in
                    doc.data()["distance"] as? Double
                }
                
                let sum = distances.reduce(0, +)
                
                DispatchQueue.main.async {
                    self?.totalDistance = sum
                    print("🎯 총 달린 거리 계산 완료: \(sum)")
                    completion(sum)
                }
            }
    }    
}
