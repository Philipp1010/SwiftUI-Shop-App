//
//  SlideShowView.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import SwiftUI

struct SlideShowView: View {
    let images = ["fn1", "fn2", "fn3", "fn4"]
    @State private var currentIndex = 0
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    Image(images[index])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 200)
            .onReceive(timer) { _ in
                withAnimation {
                    currentIndex = (currentIndex + 1) % images.count
                }
            }
            
            // Custom Indicator
            HStack(spacing: 6) {
                ForEach(0..<images.count, id: \.self) { index in
                    Circle()
                        .fill(currentIndex == index ? Color.white : Color.white.opacity(0.5))
                        .frame(width: 6, height: 6)
                        .scaleEffect(currentIndex == index ? 1.2 : 1.0)
                        .animation(.spring(), value: currentIndex)
                }
            }
            .padding(.bottom, 12)
        }
    }
}

#Preview {
    SlideShowView()
}
