//
//  SheetView.swift
//  LearnUserNotifications
//
//  Created by hs on 8/8/24.
//

import SwiftUI

enum SheetView: String, Identifiable {
    case type1, type2
    var id: String {
        self.rawValue
    }
    
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .type1:
            Text("This is type1 View")
                .font(.largeTitle)
        case .type2:
            Text("This is type2 View")
                .font(.largeTitle)
        }
    }
}

