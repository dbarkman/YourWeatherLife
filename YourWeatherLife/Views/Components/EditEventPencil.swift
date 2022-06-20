//
//  GridView.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/4/22.
//

import SwiftUI

struct EditEventPencil: View {
  @EnvironmentObject private var globalViewModel: GlobalViewModel
  
  var body: some View {
    Image(systemName: "pencil")
      .symbolRenderingMode(.monochrome)
      .foregroundColor(Color.accentColor)
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
