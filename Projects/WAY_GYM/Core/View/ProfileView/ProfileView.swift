import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ProfileView: View {
    @EnvironmentObject var router: AppRouter
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var vm = ProfileViewModel()

    // 제거가 목표
    @StateObject  private var runRecordService = RunRecordService()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.gang_bg_profile
                    .ignoresSafeArea()
                
                VStack {
                    ScrollView {
                        VStack(spacing: 16) {
                            // 유저 설명 vstack
                            VStack {
                                ZStack {
                                    Image("Flash")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 220)
                                    
                                    Image(vm.mainWeaponImageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 200)
                                        .padding(.bottom, -20)
                                    
                                    VStack {
                                        HStack {
                                            Spacer()
                                            
                                            VStack {
                                                NavigationLink(destination: WeaponListView()
                                                    .foregroundStyle(Color.gang_text_2)
                                                    .environmentObject(runRecordService))
                                                {
                                                    ZStack {
                                                        Image("box")
                                                            .resizable()
                                                            .frame(width: 52, height: 52)
                                                        
                                                        Image(vm.weaponIconImageName)
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 40)
                                                    }
                                                }
                                                
                                                Text("무기")
                                                    .font(.title02)
                                            }
                                        }
                                        Spacer()
                                    } // 무기 선택
                                } // 유저 아이콘 zstack
                                .padding(3)
                                
                                Group {
                                    Text("한성인")
                                        .font(.title01)
                                        .padding(.bottom, 2)
                                    
                                    Text("남구 연일읍 1대손파 형님")
                                }
                                .foregroundStyle(Color.white)
                            } // 유저 설명 vstack
                            .padding(.bottom, 20)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("총 차지한 영역")
                                        .font(.text01)
                                        .padding(.bottom, 8)
                                    
                                    Text(vm.totalCapturedAreaText)
                                        .font(.title01)
                                }
                                .padding(20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .customBorder()
                                
                                Spacer()
                                    .frame(width: 16)
                                
                                VStack(alignment: .leading) {
                                    Text("총 이동한 거리")
                                        .font(.text01)
                                        .padding(.bottom, 8)
                                    
                                    Text(vm.totalDistanceKmText)
                                        .font(.title01)
                                }
                                .padding(20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .customBorder()
                            }
                            
                            VStack {
                                HStack {
                                    Text("나의 똘마니")
                                        .font(.title01)
                                    Spacer()
                                    NavigationLink(destination:
                                                    MinionListView()
                                                        .font(.text01)
                                                        .foregroundColor(Color.gang_text_2)) {
                                        Text("모두 보기")
                                            .foregroundStyle(Color.gang_highlight_3)
                                    }
                                }
                                .opacity(vm.hasUnlockedMinions ? 1 : 0)
                                .disabled(!vm.hasUnlockedMinions)
                                
                                ProfileMinionView()
                                    .padding(.vertical, 4)
                                    .font(.text01)
                                    .foregroundColor(Color.gang_text_2)
                                    
                            }
                            .padding(20)
                            .customBorder()
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("구역순찰 기록")
                                        .font(.title01)
                                    Spacer()
                                    NavigationLink(destination: RunHistoryView()
                                        .environmentObject(runRecordService)
                                        .foregroundColor(Color.gang_text_2)
                                        .font(.title01)) {
                                        Text("모두 보기")
                                            .foregroundStyle(Color.gang_highlight_3)
                                    }
                                    .opacity(vm.hasRunRecords ? 1 : 0)
                                    .disabled(!vm.hasRunRecords)
                                }
                                
                                RunRecentView()
                                    .padding(.vertical, 4)
                                    .foregroundColor(Color.gang_text_2)
                                    .font(.title01)
                            }
                            .padding(20)
                            .customBorder()
                        }
                        .padding(.top, 70)
                    } // 스크롤뷰
                    .scrollIndicators(.hidden)
                    .edgesIgnoringSafeArea(.top)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.yellow)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 3)
                                )
                            
                            Text("구역 확장하러 가기")
                                .font(.title02)
                                .foregroundStyle(Color.black)
                                .padding(.vertical, 22)
                        }
                        .padding(.bottom, 5)
                    }
                }
                .padding(.horizontal, 25)
            }
            .onAppear {
                vm.load()
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(.all, edges: .top)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppRouter())
        .environmentObject(RunRecordService())
        .font(.text01)
        .foregroundColor(Color.gang_text_2)
}
