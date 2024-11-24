//
//  LottieView.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 10/14/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import SwiftUI
import DotLottie

struct LottieAnimationFromBundleView: View {
    var body: some View {
        DotLottieAnimation(fileName: "animation", config: AnimationConfig(autoplay: true, loop: true))
            .view()
            .frame(width: 300, height: 300)
    }
}

struct LottieAnimationFromBundleView_Previews: PreviewProvider {
    static var previews: some View {
        LottieAnimationFromBundleView()
    }
}
