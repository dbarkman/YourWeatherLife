//
//  FeedbackModal.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/7/22.
//

import SwiftUI
import Mixpanel

struct FeedbackModal: View {
  
  @Environment(\.presentationMode) var presentationMode
  
  @State var email = ""
  @State var feedback = ""

  var body: some View {
    NavigationView {
      ZStack {
        BackgroundColor()
        List {
          VStack(alignment: .leading) {
            Text("Thank you so much for taking the time to test this app, I'm David the developer and I really appreciate your help! Please use the form below to ask a question, give feedback, request a feature, ask for help or report a bug.")
          }
          .listRowBackground(Color("ListBackground"))
          VStack(alignment: .leading) {
            Text("Only include your email if you'd like a reply.")
            Text("Email:")
            TextField("optional", text: $email)
              .textFieldStyle(RoundedBorderTextFieldStyle())
              .keyboardType(.emailAddress)
              .disableAutocorrection(true)
              .autocapitalization(.none)
              .cornerRadius(5)
              .background(RoundedRectangle(cornerRadius: 50).fill(Color.red))
              .environment(\.colorScheme, .light)
          }
          .listRowBackground(Color("ListBackground"))
          VStack(alignment: .leading) {
            Text("Comment, Question, Request or Bug Report:")
            TextEditor(text: $feedback)
              .disabled(feedback.count >= (256))
              .background(.gray)
              .cornerRadius(5)
              .environment(\.colorScheme, .light)
            Text("\(feedback.count) of 256")
              .font(.caption2)
          }
          .listRowBackground(Color("ListBackground"))
          VStack(alignment: .leading) {
            Text("If you would like to forward a screenshot from the app or send any other information, you can email them to support@dbarkman.com.")
          }
          .listRowBackground(Color("ListBackground"))
          VStack(alignment: .leading) {
            Text("Any information you provide here will only be used to support the development of this app. Provided information will never be sold or given to a third party.")
              .font(.footnote)
          }
          .listRowBackground(Color("ListBackground"))
          VStack(alignment: .leading) {
            Button("Send", action: {
              sendFeedback()
            })
            .buttonStyle(BorderlessButtonStyle())
          }
          .listRowBackground(Color("ListBackground"))
        } //end of list
        .listStyle(.plain)
        .onAppear() {
          let appearance = UINavigationBarAppearance()
          appearance.backgroundColor = UIColor(Color("NavigationBackground"))//.opacity(0.9))
          UINavigationBar.appearance().standardAppearance = appearance
          UINavigationBar.appearance().scrollEdgeAppearance = appearance
          UINavigationBar.appearance().tintColor = UIColor(Color("AccentColor"))
          Mixpanel.mainInstance().track(event: "Feedback View")
        }
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
              sendFeedback()
            }) {
              Text("Send")
            }
          }
        }
        .navigationTitle("Developer Feedback")
      }
    }
  }
  
  func sendFeedback() {
    Mixpanel.mainInstance().track(event: "Feedback", properties: [
      "email": email,
      "feedback": feedback
    ])
    presentationMode.wrappedValue.dismiss()
  }
}

struct FeedbackModal_Previews: PreviewProvider {
  static var previews: some View {
    FeedbackModal().environment(\.colorScheme, .dark)
  }
}
