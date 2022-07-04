//
//  EventListItem.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import SwiftUI

struct EventListItem: View {
  @EnvironmentObject private var globalViewModel: GlobalViewModel
  
  @State var event: String
  @State var startTime: String
  @State var endTime: String
  @State var summary: String
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text(event)
          .font(.callout)
          .fontWeight(.semibold)
          .minimumScaleFactor(0.1)
        Spacer()
        Text(startTime)
          .font(.callout)
        Text(" - ")
          .font(.callout)
          .padding(.horizontal, -5)
        Text(endTime)
          .font(.callout)
        EditEventPencil()
      } //end of HStack
      Text(summary)
        .font(.title2)
        .minimumScaleFactor(0.1)
    } //end of VStack
    .padding([.leading, .trailing, .top], 10)
    .padding(.bottom, 20)
    .overlay {
      RoundedRectangle(cornerRadius: 10)
        .stroke(.gray, lineWidth: 2)
        .padding(.bottom, 10)
    }
    .environmentObject(globalViewModel)
  }
}

//struct EventListItem_Previews: PreviewProvider {
//  static var previews: some View {
//    EventListItem(event: "Morning Commute:", startTime: "7a", endTime: "9a", summary: "75° Clear and dry")
//  }
//}
