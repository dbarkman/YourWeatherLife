//
//  EventListItem.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import SwiftUI

struct EventListItem: View {
  
  @State var event: String
  @State var startTime: String
  @State var endTime: String
  @State var summary: String
  @State var when: String
  @State var calendarEvent: Bool = false
  @State var isAllDay: Bool = false
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .top) {
        VStack(alignment: .leading) {
          Text(event)
            .font(.body)
            .fontWeight(.semibold)
          if calendarEvent {
            VStack(alignment: .leading) {
              Text(when)
              if !isAllDay {
                HStack {
                  Text(startTime)
                    .font(.callout)
                  Text(" - ")
                    .font(.callout)
                    .padding(.horizontal, -5)
                  Text(endTime)
                    .font(.callout)
                }
              }
            }
          } else {
            HStack {
              if when != "Today" && when != "Tomorrow" && !when.isEmpty {
                Text(when + ":")
              }
              Text(startTime)
                .font(.callout)
              Text(" - ")
                .font(.callout)
                .padding(.horizontal, -5)
              Text(endTime)
                .font(.callout)
            }
          }
        }
        Spacer()
        Image(systemName: "chevron.right")
          .symbolRenderingMode(.monochrome)
          .foregroundColor(Color("AccentColor"))
          .padding(.horizontal, 5)
          .padding(.top, 3)
      } //end of HStack
      HStack {
        Text(summary)
          .font(.title2)
          .minimumScaleFactor(0.1)
      }
    } //end of VStack
    .padding([.leading, .trailing, .top], 10)
    .padding(.bottom, 20)
    .overlay {
      RoundedRectangle(cornerRadius: 10)
        .stroke(.gray, lineWidth: 2)
        .padding(.bottom, 10)
    }
  }
}

struct EventListItem_Previews: PreviewProvider {
  static var previews: some View {
    EventListItem(event: "Morning Commute:", startTime: "7a", endTime: "9a", summary: "75° Clear and dry", when: "Tomorrow")
  }
}
