//
//  GridView.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/4/22.
//

import SwiftUI

struct EditEventPencil: View {
  
  @StateObject private var globalViewModel = GlobalViewModel.shared

  var body: some View {
    Image(systemName: "pencil")
      .symbolRenderingMode(.monochrome)
      .foregroundColor(Color("AccentColor"))
      .onTapGesture {
        globalViewModel.showDailyEvents()
      }
  }
}

struct EditEventPencil_Previews: PreviewProvider {
  static var previews: some View {
    EditEventPencil()
  }
}
