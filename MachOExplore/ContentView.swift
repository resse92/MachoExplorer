// MachOExplore
// Created by: resse

import SwiftUI
import Combine
import MachOKit

struct LaunchView: View {
    
    @Binding var url: URL?
    
    var body: some View {
        VStack {
            Text("Welcome To MachO-Explore")
                .fontWeight(.semibold)
                .font(.title)

            Button {
                self.url = openPanel()
                saveBookmarkData(for: url!)
            } label: {
                HStack {
                    Image(systemName: "arrowshape.right").frame(width: 50, height: 50).font(.system(size: 30))
                    Text("Click To Open File").font(.callout)
                }.padding(.init(top: 10, leading: 50, bottom: 10, trailing: 50))
            }
            .overlay {
                RoundedRectangle(cornerSize: .init(width: 5, height: 5))
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [2], dashPhase: 1))
                    .foregroundStyle(.gray)
            }
        }
        .frame(minWidth: 500, minHeight: 300).fixedSize()
        .background(.white)
    }
}

struct ContentView: View {
    
    @State var machoFileUrl: URL? = restoreFileAccessFromUserdefaults()
    
    var body: some View {
        if self.machoFileUrl != nil {
            ExplorerView(url: $machoFileUrl)
        } else {
            if machoFileUrl?.isFileURL == true {
                ExplorerView(url: $machoFileUrl)
            } else {
                LaunchView(url: $machoFileUrl)
            }
        }
    }
}

let kBookmarkDataKey: String = "workingDirectoryBookmark"

private func saveBookmarkData(for workDir: URL) {
    do {
        let bookmarkData = try workDir.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        UserDefaults.standard.set(bookmarkData, forKey: kBookmarkDataKey)
    } catch {
        print("Failed to save bookmark data for \(workDir)", error)
    }
}

private func restoreFileAccessFromUserdefaults() -> URL? {
    do {
        var isStale = false
        guard let bookmarkData = UserDefaults.standard.data(forKey: kBookmarkDataKey) else {
            return nil
        }
        
        let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
        if isStale {
            // bookmarks could become stale as the OS changes
            print("Bookmark is stale, need to save a new one... ")
            saveBookmarkData(for: url)
            return nil
        }
        guard url.startAccessingSecurityScopedResource() else {
            throw "Could not start accessing security scoped resource: \(url.path)"
        }
        return url
    } catch {
        print("Error resolving bookmark:", error)
        return nil
    }
}

extension String: Error { }


#Preview {
    ContentView()
}
