// MachOExplore
// Created by: resse

import Foundation
import SwiftUI


struct SpinnerView: View {
  var body: some View {
    ProgressView()
      .progressViewStyle(CircularProgressViewStyle(tint: .blue))
      .scaleEffect(2.0, anchor: .center) // Makes the spinner larger
  }
}



#Preview {
    SpinnerView()
}
