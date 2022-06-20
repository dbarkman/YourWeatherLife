//
//  BackgroundColor.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/12/22.
//

import SwiftUI

struct BackgroundColor: View {
  var body: some View {
    Color("BodyBackground")
      .ignoresSafeArea()
  }
}

struct BackgroundColor_Previews: PreviewProvider {
  static var previews: some View {
    BackgroundColor()
  }
}
