//
//  NextView.swift
//  LocalNotification
//
//  Created by Benji Loya on 06.04.2024.
//

import SwiftUI

enum NextView: String, Identifiable {
    case promo, renew
    var id: String {
        self.rawValue
    }
    
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .promo:
            Text("Promotional Offer")
                .font(.largeTitle)
        case .renew:
            VStack(spacing: 20) {
                Text("Renew Subscription")
                    .font(.largeTitle)
                
                Image(systemName: "dollarsign.circle")
                    .font(.system(size: 128))
            }
        }
    }
}
