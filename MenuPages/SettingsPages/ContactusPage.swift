//
//  ContactusPage.swift
//  LearnAlert
//
//  Created by Blake Miller on 4/26/24.
//
import SwiftUI

struct ContactusPage: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Contact Us")
                .font(.largeTitle) // Large and bold title
                .fontWeight(.bold)
            Text("If you have any questions or suggestions, feel free to send us an email:")
                .padding(.bottom, 5)
            Link("contact@learnalertapp.com", destination: URL(string: "mailto:support@learnalertapp.com")!)
                .font(.title2) // Slightly smaller font for the link
               // .foregroundColor(.purple) // Change link color to purple
             //   .padding(10)
            //    .overlay(
             //       RoundedRectangle(cornerRadius: 10)
             //           .stroke(Color.purple, lineWidth: 2)
              //  )
        }
        .padding()
        .background(Color(.systemGray6)) // Soft gray background
        .cornerRadius(10)
    }
}


#Preview {
    ContactusPage()
}
