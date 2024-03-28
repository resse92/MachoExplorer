// MachOExplore
// Created by: resse

import Foundation
import SwiftUI
import MachOKit



struct ExplorerView: View {
    
    @Binding var url: URL?
    @State private var searchString: String = ""
    @State private var valueMode: ValueMode = .raw
    
    @State private var nodes: [OutlineItem] = []
    @State var selectId: OutlineItem.ID?
    @State var selectItem: OutlineItem?
    
    @ObservedObject var accessor = MachoAccesser()
    
    var body: some View {
        GeometryReader { gp in
            VStack {
                HSplitView {
                    List(selection: $selectId) {
                        OutlineGroup($nodes, id: \.id, children: \.children) { node in
                            Text(node.wrappedValue.description)
                        }
                    }.frame(
                        minWidth: 100,
                        idealWidth: 200,
                        maxWidth: gp.size.width * 0.5,
                        maxHeight: .infinity
                    ).onChange(of: selectId) { _, newValue in
                        if let newValue = newValue {
                            self.selectItem = self.findItem(items: self.nodes, targetId: newValue)
                        } else {
                            self.selectItem = nil
                        }
                    }
                    
                    DetailView(
                        valueMode: $valueMode,
                        item: $selectItem
                    ).frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    } catch let err {
                        print(err)
                    }
                }
            }.frame(width: gp.size.width, height: gp.size.height)
        }.frame(width: 1000, height: 600)
    }
    
    func findItem(items: [OutlineItem], targetId: OutlineItem.ID) -> OutlineItem? {
        for item in items {
            if item.id == targetId {
                return item
            }
            if let children = item.children {
                if let item = findItem(items: children, targetId: targetId) {
                    return item
                }
            }
        }
        return nil
    }
}

