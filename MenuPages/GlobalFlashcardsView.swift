//
//  GlobalFlashcardsView.swift
//  LearnAlert
//
//  Created by Blake Miller on 3/27/24.
//

import SwiftUI

struct GlobalFlashcardsView: View {
    var body: some View {
        NavigationView {
          
            VStack {
               //Text("Your Library is currently empty.")
               // Spacer()
                Text("Coming Soon")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.blue)
                //    .offset(y:-80)
                Text("We have plans to provide a Global library to share and distribute Study sets and flashcards with anyone, aswell as community made Study Sets & Quizzes with more customization!")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(Color.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                //    .offset(y:-80)
            }
            .padding()
            .background(Color(UIColor.systemGroupedBackground))
            .cornerRadius(15)
            .padding()
            .navigationTitle("Library") 
        }
    }
}

// Preview
struct GlobalFlashcardsView_Previews: PreviewProvider {
    static var previews: some View {
        GlobalFlashcardsView()
    }
}
