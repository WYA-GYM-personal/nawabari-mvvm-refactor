//
//  AppRouter.swift
//  WAY_GYM
//
//      Created by soyeonsoo on 6/2/25.
//

import Foundation
import SwiftUI

enum AppScreen {
    case main(id: UUID = UUID())
    case profile
}

class AppRouter: ObservableObject {
    @Published var currentScreen: AppScreen = .main(id: UUID())
}
