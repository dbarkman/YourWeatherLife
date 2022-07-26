//
//  ForecastListItem.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/26/22.
//

import SwiftUI

struct ForecastListItem: View {
  
  @State var displayDate = ""
  @State var warmestTemp = ""
  @State var coldestTemp = ""
  @State var condition = ""
  @State var conditionIcon = ""
  @State var isHour = false
  
  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text("\(displayDate)")
          .fontWeight(.semibold)
        if isHour {
          Text("\(warmestTemp), Feels like: \(coldestTemp)")
        } else {
          Text("High: \(warmestTemp), Low: \(coldestTemp)")
        }
        Text("\(condition)")
      }
      Spacer()
      HStack {
        AsyncImage(url: URL(string: "https:\(conditionIcon)")) { image in
          image.resizable()
        } placeholder: {
          Image("day/113")
        }
        .frame(width: 72, height: 72)
        Image(systemName: "chevron.right")
          .symbolRenderingMode(.monochrome)
          .foregroundColor(Color("AccentColor"))
          .padding(.horizontal, 5)
      }
    } //end of HStack
    .padding([.leading, .trailing, .top], 10)
    .padding(.bottom, 20)
    .overlay {
      RoundedRectangle(cornerRadius: 10)
        .stroke(.gray, lineWidth: 2)
        .padding(.bottom, 10)
    }
  }
}

struct ForecastListItem_Previews: PreviewProvider {
  static var previews: some View {
    ForecastListItem()
  }
}
