// MachOExplore
// Created by: resse

import Foundation
import AppKit
import Combine

private class DelegateHelper: NSObject, NSOpenSavePanelDelegate {
    static let shared = DelegateHelper()
    
    private override init() {
        super.init()
    }
    
    func panel(_ sender: Any, shouldEnable url: URL) -> Bool {
        return true
        if url.hasDirectoryPath {
            return true
        }
        
        guard let values = try? url.resourceValues(forKeys: [.isDirectoryKey, .isRegularFileKey]) else {
            return false
        }
        // 如果是文件夹
        if values.isDirectory == true {
            return true
        }
        // skip regular file
        if values.isRegularFile == false {
            return false
        }
        
        do {
            let fh = try FileHandle.init(forReadingFrom: url)
            let _magicData = try fh.read(upToCount: 8)
            try fh.close()
            
            guard let magicData = _magicData else {
                return false
            }
            
            if magicData.count < MemoryLayout<UInt32>.size {
                return false
            }
            
            if magicData.count < MemoryLayout<UInt64>.size {
                return false
            }
            
            // !<arch>\n
            let arMagic: UInt64 = 0x21_3C_61_72_63_68_3E_0A
            if magicData.withUnsafeBytes({ $0.load(as: UInt64.self) }) == arMagic {
                return true
            }
        } catch let error {
//            print(error)
            _ = error
            return false
        }
        
        return false
    }
}

func openPanel() -> URL? {
    let panel = NSOpenPanel()
    panel.delegate = DelegateHelper.shared
    panel.canChooseDirectories = false
    panel.canChooseFiles = true
    panel.allowsMultipleSelection = false
    let resp = panel.runModal()
    if resp == .OK {
        guard panel.url?.startAccessingSecurityScopedResource() == true else {
            return nil
        }
        return panel.url
    }
    return nil
}
