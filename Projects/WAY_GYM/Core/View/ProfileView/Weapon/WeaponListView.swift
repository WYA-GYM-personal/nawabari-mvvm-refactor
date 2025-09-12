import SwiftUI

// weapon = area, 1,000,000단위
struct WeaponListView: View {
    @StateObject private var viewModel = WeaponListViewModel()
    
    var body: some View {
        ZStack {
            Color.gang_bg_profile
                .ignoresSafeArea()
            
            VStack {
                CustomNavigationBar(title: "무기 창고")
                
                // 진한 박스 zstack
                ZStack {
                    Color.gang_bg_primary_4
                    
                    VStack {
                        // 사용자 이미지
                        ZStack {
                            Image("Flash")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            
                            Image("main_\(viewModel.selectedWeaponId)")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 230)
                                .padding(.bottom, -15)
                                .padding(.leading, -7)
                        } // 사용자 이미지 zstack
                        .padding(.vertical, 15)
                        
                        VStack {
                            if let weapon = viewModel.selectedDisplayWeapon {
                                Text(weapon.name)
                                    .padding(.vertical, 5)

                                Text(weapon.description)
                                    .multilineTextAlignment(.center)

                                HStack(spacing: 16) {
                                    Spacer()

                                    Text("\(formatShortDate(viewModel.acquisitionDate ?? Date()))")
                                    
                                    Text("\(Int(weapon.unlockNumber))m²")
                                }
                                .font(.title02)
                                .padding(.vertical, 1)

                            } else {
                                Text("맨손")
                                    .padding(.vertical, 5)

                                Text("무기? 필요 있나?\n내 주먹이 무기인데")
                                    .multilineTextAlignment(.center)

                                HStack {
                                    Spacer()
                                    Text("00")
                                    Text("00.00.00")
                                }
                                .font(.title02)
                                .foregroundStyle(Color("gang_bg_primary_4"))
                                .padding(.vertical, 1)

                            }
                        }
                        .font(.title01)
                        .frame(maxWidth: .infinity)
                        .padding(16) // 박스 내부 여백
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        .padding(.bottom, 20)
                        .padding(.horizontal, 14)
                        
                        
                    }
                } // 진한 박스 zstack
                .frame(height: UIScreen.main.bounds.height * 0.5)
                
                ScrollView {
                    let columns = [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ]
                    LazyVGrid(columns: columns, spacing: 30) {
                        ForEach(viewModel.allWeapons) { weapon in
                            if viewModel.isUnlocked(weapon) {
                                Button(action: {
                                    viewModel.toggleSelection(weapon)
                                }) {
                                    ZStack {
                                        Image("box")
                                            .resizable()
                                            .frame(width: UIScreen.main.bounds.width * 0.25, height: UIScreen.main.bounds.width * 0.25)
                                        
                                        VStack {
                                            Image(weapon.imageName)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 90)
                                        }
                                    }
                                    .cornerRadius(8)
                                    .shadow(radius: 2)
                                    .overlay {
                                        if viewModel.isSelected(weapon) {
                                            Image("selected")
                                                .resizable()
                                                .frame(width: UIScreen.main.bounds.width * 0.25, height: UIScreen.main.bounds.width * 0.25)
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else {
                                Image("unlockbox")
                                    .resizable()
                                    .frame(width: UIScreen.main.bounds.width * 0.25, height: UIScreen.main.bounds.width * 0.25)
                            }
                        }
                    }
                    .padding(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black, lineWidth: 7)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 14)
                .scrollIndicators(.hidden)
            }
        }
        .onAppear { viewModel.onAppear() }
        .onChange(of: viewModel.selectedWeapon) {
            viewModel.refreshAcquisitionDate()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    StatefulPreviewWrapper(nil as WeaponDefinitionModel?) { binding in
        WeaponListView()
            .font(.text01)
            .foregroundColor(Color.gang_text_2)
    }
}

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ initialValue: Value, content: @escaping (Binding<Value>) -> Content) {
        _value = State(wrappedValue: initialValue)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
