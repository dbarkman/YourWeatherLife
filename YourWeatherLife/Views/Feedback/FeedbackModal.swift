//
//  FeedbackModal.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/7/22.
//

import SwiftUI
import Mixpanel
import FirebaseAnalytics

struct FeedbackModal: View {
  
  @Environment(\.presentationMode) var presentationMode
  
  @StateObject private var globalViewModel = GlobalViewModel.shared

  @State private var email = ""
  @State private var feedback = ""
  @State private var showVersion = false
  @State private var currentVersion = ""

  @FocusState private var isFocused: Bool
  
  var body: some View {
    NavigationStack {
      ZStack {
        BackgroundColor()
        List {
          Section() {
            VStack(alignment: .leading) {
              Text("Thank you for using Your Weather Life! Please use the form below to ask a question, give feedback, request a feature or report a bug.")
            }
            VStack(alignment: .leading) {
              Text("Email:")
              TextField("optional", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .focused($isFocused)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .cornerRadius(5)
                .background(RoundedRectangle(cornerRadius: 50).fill(Color.red))
                .environment(\.colorScheme, .light)
              Text("Include your email if you'd like a reply.")
                .font(.caption)
            }
            VStack(alignment: .leading) {
              Text("Feedback:")
                .lineLimit(2)
                .focused($isFocused)
              TextEditor(text: $feedback)
                .disabled(feedback.count >= (512))
                .focused($isFocused)
                .background(.gray)
                .cornerRadius(5)
                .environment(\.colorScheme, .light)
              Text("\(feedback.count) of 512")
                .font(.caption2)
            }
            VStack(alignment: .leading) {
              Text("If you would like to forward a screenshot from the app or send any other information, you can email support@yourweather.life.")
            }
            VStack(alignment: .leading) {
              Text("Any information you provide here will only be used to support the development of this app. Provided information will never be sold or given to a third party. 🤙 Pinky promise!")
                .font(.footnote)
            }
            VStack(alignment: .leading) {
              HStack {
                Text("Send")
                  .font(.title2)
                  .foregroundColor(Color("AccentColor"))
                  .onTapGesture {
                    withAnimation() {
                      sendFeedback()
                    }
                }
                Spacer()
                Text("ver")
                  .font(.title2)
                  .foregroundColor(Color("ListBackground"))
                  .onTapGesture {
                    withAnimation() {
                      showVersion.toggle()
                    }
                  }
              }
            }
            if showVersion {
              Text(currentVersion)
            }
          } //end of Section
          .listRowBackground(Color("ListBackground"))
        } //end of list
        .listStyle(.plain)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
              presentationMode.wrappedValue.dismiss()
            }) {
              Text("Cancel")
            }
          }
          ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
              sendFeedback()
            }) {
              Text("Send")
            }
          }
          ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") {
              isFocused = false
            }
          }
        }
        .navigationTitle("Feedback")
      }
      .onAppear() {
//        let appearance = UINavigationBarAppearance()
//        appearance.backgroundColor = UIColor(Color("NavigationBackground"))
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Color("AccentColor"))
        Mixpanel.mainInstance().track(event: "Feedback View")
        Analytics.logEvent("View", parameters: ["view_name": "Feedback"])
        let appVersion = globalViewModel.fetchAppVersionNumber()
        let buildNumber = globalViewModel.fetchBuildNumber()
        currentVersion = "\(appVersion)-\(buildNumber)"
      }
    }
    .accentColor(Color("AccentColor"))
  }
  
  private func sendFeedback() {
    Mixpanel.mainInstance().track(event: "Feedback", properties: [
      "email": email,
      "feedback": feedback,
      "currentVersion": currentVersion
    ])
    presentationMode.wrappedValue.dismiss()
  }
}

struct FeedbackModal_Previews: PreviewProvider {
  static var previews: some View {
    FeedbackModal().environment(\.colorScheme, .dark)
  }
}
