// MachOExplore
// Created by: resse

import Foundation
import SwiftUI

enum ValueMode: String, CaseIterable, Identifiable {
    var id: Self {
        self
    }
    case raw = "RAW"
    case rva = "RVA"
}

struct DetailView: View {
    
    @Binding var valueMode: ValueMode
    @Binding var item: OutlineItem?
    
    var body: some View {
        VStack {
            if let item = item {
                Text(item.description)
            } else {
                Text("nothing")
            }
            
        }
        
    }
}
