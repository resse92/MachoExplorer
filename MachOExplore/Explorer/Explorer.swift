// MachOExplore
// Created by: resse

import Foundation
import SwiftUI
import MachOKit

enum ValueMode: String, CaseIterable, Identifiable {
    var id: Self {
        self
    }
    case raw = "RAW"
    case rva = "RVA"
}

struct ExplorerView: View {
    
    @Binding var url: URL?
    @State private var searchString: String = ""
    @State private var valueMode: ValueMode = .raw
    
    @State private var nodes: [OutlineItem] = []
    
    @State var topExpanded = false
    @State var toggleStates = (oneIsOn: false, twoIsOn: true)
    @State var selectionItems: UUID?
    
    @ObservedObject var accessor = MachoAccesser()
    
    var body: some View {
        GeometryReader { gp in
            VStack {
                HSplitView {
                    List($nodes, selection: $selectionItems) { item in
                        OutlineGroup($nodes, id: \.id, children: \.children) { node in
                            Text(node.wrappedValue.description)
                        }
                    }.frame(minWidth: 100, idealWidth: 200, maxWidth: gp.size.width * 0.5, maxHeight: .infinity)
                    
                    DisclosureGroup("Items", isExpanded: $topExpanded) {
                        Toggle("Toggle 1", isOn: $toggleStates.oneIsOn)
                        Toggle("Toggle 2", isOn: $toggleStates.twoIsOn)
                        DisclosureGroup("Sub-items") {
                            Text("Sub-item 1")
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .toolbar {
                    ToolbarItemGroup {
                        Picker("ValueMode", selection: $valueMode) {
                            ForEach(ValueMode.allCases, id: \.id) {
                                Text($0.rawValue)
                            }
                        }.pickerStyle(.segmented)
                        
                        TextField(text: self.$searchString) {
                            HStack {
                                Image(systemName: "magnifyingglass").font(.footnote)
                                Text("search")
                            }.padding(.horizontal, 10).padding(.vertical, 5)
                        }
                    }
                }.onAppear {
                    self.accessor.url = self.url
                }.task {
                    do {
                        self.nodes = try await self.accessor.processUrl()
                        print(self.nodes.count)
                    } catch let err {
                        print(err)
                    }
                }
            }.frame(width: gp.size.width, height: gp.size.height)
        }.frame(width: 1000, height: 600)
    }
}

