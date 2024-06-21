//
//  File.swift
//
//
//  Created by mayong on 2024/6/21.
//

import Combine
import Foundation
import SwiftUI

@available(iOS 14.0, *)
private final class CycleScrollViewData: ObservableObject {
    @Published var selection: Int = 0
    
    var originCount: Int = 0
    
    var count: Int = 0
    
    var interval: Int = 0
    
    var cancelSet: Set<AnyCancellable> = []
    
    func reloadData(
        _ count: Int,
        interval: Int
    ) {
        originCount = count
        self.count = count == 1 ? 1 : count
        self.interval = interval
        cancelSet = []
        startTimer()
        selection = count == 1 ? 1 : selection
    }
    
    func startTimer() {
        Timer.publish(
            every: TimeInterval(interval),
            on: .main,
            in: .common
        )
        .autoconnect()
        .sink { [unowned self] _ in
            self.nextSelection()
        }
        .store(in: &cancelSet)
    }
    
    func nextSelection() {
        let newSelection = selection + 1
        if newSelection == count - 1 {
            selection = newSelection % originCount
        } else {
            selection = newSelection
        }
    }
}

@available(iOS 14.0, *)
public struct CycleScrollView<Content: View>: View {
    @StateObject private var data: CycleScrollViewData = .init()
    
    let content: (Int) -> Content
    let count: Int
    let interval: Int
    init(
        _ count: Int,
        interval: Int = 5,
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self.content = content
        self.count = count
        self.interval = interval
    }

    public var body: some View {
        TabView(selection: $data.selection) {
            ForEach(0 ..< data.count, id: \.self) { index in
                content(index)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tag(index)
            }
        }
        .tabViewStyle(
            .page(indexDisplayMode: .never)
        )
        .animation(.linear, value: data.selection)
        .onAppear {
            self.data.reloadData(
                count,
                interval: interval
            )
        }
    }
}

let colors: [Color] = [.red, .green, .yellow, .orange, .purple, .accentColor, .white, .black]
@available(iOS 14.0, *)
#Preview {
    CycleScrollView(
        colors.count,
        interval: 3,
        content: { colors[$0] }
    )
    .frame(width: 300, height: 180)
}
