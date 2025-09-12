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
    @Published var totalCapturedAreaValue: Int = 0
    
    @Published var distance: Double?
    @Published var duration: TimeInterval?
    @Published var calories: Double?
    
    private var db = Firestore.firestore()
    
    // MARK: - Records: 전체 런닝 기록 로드 (Main/Running View에서 쓰기 위함)
    // 서버에서 런닝 기록 가져오기
    func fetchRunRecordsFromFirestore() {
        db.collection("RunRecordModels")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("⚠️ 런닝 기록 불러오기 실패: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ 서버에 RunRecordsModels 기록 없음")
                    return
                }
                
                self?.runRecords = documents.compactMap { document in
                    try? document.data(as: RunRecordModel.self)
                }
                print("✅ runRecords 개수: \(self?.runRecords.count ?? 0)")
            }
    }
    
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
    
    // 총 딴 면적 합계 로드
    // 서버에서 총 딴 면적 가져오기
    func getTotalCapturedAreaForRewards() {
        db.collection("RunRecordModels")
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("⚠️ 런닝 딴 땅 불러오기 실패: \(error?.localizedDescription ?? "")")
                    return
                }
                
                let areas = documents.compactMap { doc -> Int? in
                    if let value = doc.data()["capturedAreaValue"] as? Int {
                        return value
                    } else if let valueDouble = doc.data()["capturedAreaValue"] as? Double {
                        // 혹시 Double로 저장된 경우 Int로 변환
                        let intValue = Int(valueDouble)
                        print("✅ 총 area 값 (Double->Int 변환): \(intValue)")
                        return intValue
                    } else {
                        print("⚠️ area 없음 또는 타입 불일치")
                        return nil
                    }
                }
                
                DispatchQueue.main.async {
                    self?.totalCapturedAreaValue = areas.reduce(0, +)
                    print("🎯 총 딴 땅 계산 완료: \(self?.totalCapturedAreaValue ?? 0)")
                }
            }
    }
    
    // MARK: - 최신 1건 요약 (RunResultModalView에 띄우기 위함)
    func getLatestCapturedArea(completion: @escaping (Double?) -> Void) {
        db.collection("RunRecordModels")
            .order(by: "start_time", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ 최신 기록 불러오기 실패: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    print("❌ 기록 없음")
                    completion(nil)
                    return
                }
                
                let data = document.data()
                if let value = data["capturedAreaValue"] as? Double {
                    completion(value)
                } else if let valueInt = data["capturedAreaValue"] as? Int {
                    completion(Double(valueInt))
                } else {
                    print("❌ capturedAreaValue 타입 불일치")
                    completion(nil)
                }
            }
    }
    
    // 최신 경로 이미지 URL 로드
    func getLatestRouteImage(completion: @escaping (String?) -> Void) {
        db.collection("RunRecordModels")
            .order(by: "start_time", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ routeImage 가져오기 실패: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let doc = snapshot?.documents.first else {
                    print("❌ 문서 없음")
                    completion(nil)
                    return
                }
                
                if let urlString = doc.data()["routeImage"] as? String {
                    print("✅ routeImage 가져옴: \(urlString)")
                    completion(urlString)
                } else {
                    print("❌ routeImage 필드 없음")
                    completion(nil)
                }
            }
    }
    
    // 최신 거리, 시간(여기서 계산), 칼로리(여기서 계산) 가져오기
    func getLatestRunStats(completion: @escaping (_ distance: Double, _ duration: TimeInterval, _ calories: Double) -> Void) {
        db.collection("RunRecordModels")
            .order(by: "start_time", descending: true)
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                guard let document = snapshot?.documents.first else {
                    print("❌ 문서 없음 또는 오류: \(error?.localizedDescription ?? "")")
                    return
                }
                
                let data = document.data()
                
                guard let distance = data["distance"] as? Double,
                      let startTimestamp = data["start_time"] as? Timestamp,
                      let endTimestamp = data["end_time"] as? Timestamp else {
                    print("❌ 필요한 필드 누락 또는 타입 오류")
                    return
                }
                
                let start = startTimestamp.dateValue()
                let end = endTimestamp.dateValue()
                let duration = end.timeIntervalSince(start)
                let calories = duration / 60 * 7.4
                
                DispatchQueue.main.async {
                    self?.distance = distance
                    self?.duration = duration
                    self?.calories = calories
                    completion(distance, duration, calories)
                }
            }
    }
}
