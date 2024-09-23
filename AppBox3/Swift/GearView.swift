//
//  GearView.swift
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 9/15/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import SwiftUI

struct GearView: View {
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: -10) {
                HStack(spacing: 20) {
                    // 첫 번째 톱니바퀴
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(rotationAngle))
                        .foregroundColor(.blue)
                        .animation(Animation.linear(duration: 2).repeatForever(autoreverses: false), value: rotationAngle)
                }
                HStack(spacing: 0) {
                    // 첫 번째 톱니바퀴
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-rotationAngle))
                        .foregroundColor(.blue)
                        .animation(Animation.linear(duration: 2).repeatForever(autoreverses: false), value: rotationAngle)
                    
                    // 두 번째 톱니바퀴
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(rotationAngle))
                        .foregroundColor(.blue)
                        .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: rotationAngle)
                    
                }
            }
            .onAppear {
                rotationAngle = 360
            }
            CoverLayerView()
            GeometryReader { geometry in
                VStack() {
                    Text("AppBox Pro\n\nData optimization in progress. \nPlease wait...")
                        .font(.headline) // 텍스트 스타일
                        .padding() // 텍스트 주변에 패딩 추가
                        .frame(maxWidth: .infinity, alignment: .top) // 가로로 꽉 차게 하고 상단에 정렬
                        .background(Color.yellow) // 배경 색상 추가(선택 사항)           }
                    Spacer()
                    Text("Preparing")
                        .font(.headline) // 텍스트 스타일
                        .padding() // 텍스트 주변에 패딩 추가
                        .frame(maxWidth: .infinity, alignment: .top) // 가로로 꽉 차게 하고 상단에 정렬
                        .background(Color.yellow) // 배경 색상 추가(선택 사항)           }
                }
            }
        }
    }
}

struct CoverLayerView: View {
    var body: some View {
        ZStack {
            Color(red: 0.8, green: 0.8, blue: 0.9)
                .opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            Circle()
                .frame(width: 150, height: 150)
                .foregroundColor(.clear)
                .shadow(color: Color.black.opacity(0.4), radius: 10, x: 5, y: 5) // 그림자
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.7), lineWidth: 5) // 하이라이트 효과
                        .blur(radius: 2) // 살짝 흐림 효과로 자연스러움 추가
                )
                .blendMode(.destinationOut)
        }
        .compositingGroup() // 이 그룹을 통해 블렌드 모드를 적용
    }
}

#Preview {
    GearView()
}
