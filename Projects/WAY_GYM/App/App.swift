import SwiftUI
import FirebaseCore
import FirebaseFirestore
import UIKit
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("Firebase 초기화 완료")
        return true
    }
}

@main
struct WAY_GYMApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var router = AppRouter()
    @StateObject private var locationManager = LocationManager()
    // @StateObject private var healthKitManager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            RootView()
            
//            ProfileView()
//                .environmentObject(MinionOperation())
//                .environmentObject(WeaponOperation())
//                .environmentObject(AppRouter())
//                .environmentObject(RunRecordViewModel())
//                .font(.text01)
//                .foregroundColor(Color.gang_text_2)
        }
    }
} 

struct RootView: View {
    @StateObject private var router = AppRouter()
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationStack {
            switch router.currentScreen {
            case .main(let id):
                        MainView(locationManager: locationManager)
                            .id(id)
                            .environmentObject(router)
                            .environmentObject(LocationManager())

            case .profile:
                AnyView( ProfileView()
                        .environmentObject(router)
                        .environmentObject(RunRecordService())
                        .font(.text01)
                        .foregroundColor(Color("gang_text_2"))
                         .navigationBarHidden(true)
                )
            }
        }
    }
}

//#Preview {
//    RootView()
//}
