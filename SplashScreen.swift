//
//  SplashScreen.swift
//  LearnAlert
//
//  Created by Blake Miller on 4/15/24.
//

import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false  // Handles transition to main content
    @State private var showNotification = false  // Controls the visibility of the "An EDD Project" text
    
    var body: some View {
        VStack {
            if isActive {
                MainTabView()  // Main content view
            } else {
                splashContent
            }
        }
        .onAppear {
            // Delay the initial appearance
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    self.showNotification = true
                }
                // Delay the switch to the main content
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
    
    var splashContent: some View {
        VStack {
            Spacer()
            Image("AppIcon2")
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .frame(width: 100, height: 100)
            Text("LearnAlert")
                .bold()
                .font(.largeTitle)
                .padding()
                .offset(y:-30)
            
            if showNotification {
                Text("An EDD Project")
                    .bold()
                    .padding()
                    .offset(y:-60)
                //  .transition(.opacity)
                
                    .transition(.move(edge: .top).combined(with: .opacity))
                
                Text("By: Blake Miller & Laila Melendez")
                    .bold()
                    .padding()
                    .offset(y:200)
                    .transition(.opacity)
                    .onAppear {
                        
                        withAnimation(.easeIn(duration: 7.0)) {
                            self.showNotification = true
                        }
                    }.opacity(0.2)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}


#Preview {
    SplashScreen()  .preferredColorScheme(.dark)

}
