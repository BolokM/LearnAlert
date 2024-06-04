//
//  ViewStyles.swift
//  LearnAlert
//
//  Created by Blake Miller on 3/27/24.
//

import SwiftUI

struct StandardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
        .bold()
        .frame(height: 35)
        .padding(.horizontal, 10)
        .foregroundStyle(.appLabel)
        //.background(Color(uiColor: .appBackground2))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
             
