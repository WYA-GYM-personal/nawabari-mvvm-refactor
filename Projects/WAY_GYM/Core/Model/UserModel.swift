//
//  UserModel.swift
//  Ch3Personal
//
//  Created by 이주현 on 5/30/25.
//

import Foundation

struct UserModel {
    var id: UUID
    var runRecords: [RunRecordModel]
    
    init(id: UUID, runRecords: [RunRecordModel]) {
            self.id = id
            self.runRecords = runRecords
        }
}
