//
//  ProfileView.swift
//  LearnAlert
//
//  Created by Blake Miller on 3/27/24.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            List {
        //        Section(header: Text("General")) {
              //      NavigationLink(destination: KnownBugsView()) {
             //           Text("Known Bugs")
           //         }
               //   NavigationLink(destination: QuestionsPage()) {
                 //       Text("App Info")
                 //   }
               //     NavigationLink(destination: FeedbackSubmissionView()) {
                //        Text("Submit Feedback")
                //    }
           //     }
                
          
                
                Section(header: Text("Contact")) {
                    NavigationLink(destination: ContactusPage()) {
                        Text("Contact Us")
                    }
                }
            }
            .navigationTitle("Settings")
            .listStyle(GroupedListStyle())
        }
    }
}




// Preview provider
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
