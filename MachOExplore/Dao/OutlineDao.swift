// MachOExplore
// Created by: resse

import Foundation
import MachOKit

struct OutlineVoidInfo { }

struct OutlineItem: Hashable, Identifiable {
    typealias ID = UUID
    
    var description: String
    var info: Any
    var children: [OutlineItem]?
    
    var id: UUID = UUID()
    
    static func == (lhs: OutlineItem, rhs: OutlineItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class MachoAccesser: ObservableObject {
    var url: URL? {
        didSet {
            if oldValue == url {
                return
            }
            self.objectWillChange.send()
        }
    }
    
    func processUrl() async throws -> [OutlineItem] {
        guard let url = self.url else {
            throw "no fileurl"
        }
        return try await self.load(fileUrl: url)
    }
    
    func load(fileUrl: URL) async throws -> [OutlineItem] {
        let result = Task(priority: .high) {
            let file = try MachOKit.loadFromFile(url: fileUrl)
            switch file {
            case .machO(let machOfile):
                let header = OutlineItem(
                    description: "MachO Header",
                    info: machOfile.header
                )
                
                let subLoadCommands = machOfile.loadCommands.map { loadcommand in
                    var desc = loadcommand.type.description
                    var children: [OutlineItem]? = nil
                    if let command = loadcommand.info as? LoadCommandDescription {
                        
                        desc.append("(\(command.desc(from: machOfile)))")
                        children = command.children(in: machOfile)
                    }
                    return OutlineItem(
                        description: desc,
                        info: loadcommand.info,
                        children: children
                    )
                }
                
                let loadCommands = OutlineItem(
                    description: "LoadCommands",
                    info: OutlineVoidInfo(),
                    children: subLoadCommands
                )
                var machoItems = [header, loadCommands]
                
                // sections
                let sections = machOfile.sections.map { sp in
                    return OutlineItem(
                        description: "Section (\(sp.segmentName),\(sp.sectionName))",
                        info: sp
                    )
                }
                
                machoItems.append(contentsOf: sections)
                
                let dyldInfo = try await self.processLoaderInfo(machOFile: machOfile)
                machoItems.append(contentsOf: dyldInfo)
                
                let result =  [
                    OutlineItem(
                        description: machOfile.header.fileType?.description ?? "Unkown",
                        info: machOfile.header,
                        children: machoItems
                    )
                ]
                
                
                
                return result
            case .fat(let fatfile):
                print(try fatfile.machOFiles())
                return []
            }
        }
        return try await result.value
    }
    
    func processLoaderInfo(machOFile: MachOFile) async throws -> [OutlineItem] {
        var result: [OutlineItem] = []
        // dyldInfo info
        var dyldInfoChildren: [OutlineItem] = []
        if let rebaseOperations = machOFile.rebaseOperations {
            dyldInfoChildren.append(OutlineItem(description: "Rebase Info", info: rebaseOperations))
        }
        if let bindOperations = machOFile.bindOperations {
            dyldInfoChildren.append(OutlineItem(description: "Binding Info", info: bindOperations))
        }
        if let weakBindOperations = machOFile.weakBindOperations {
            dyldInfoChildren.append(OutlineItem(description: "Weak Binding Info", info: weakBindOperations))
        }
        if let lazyBindOperations = machOFile.lazyBindOperations {
            dyldInfoChildren.append(OutlineItem(description: "Lazy Binding Info", info: lazyBindOperations))
        }
        if let exportTrieEntries = machOFile.exportTrieEntries {
            dyldInfoChildren.append(OutlineItem(description: "Weak Binding Info", info: exportTrieEntries))
        }
        
        result.append(OutlineItem(description: "Dynamic Loader Info", info: OutlineVoidInfo(), children: dyldInfoChildren))
        
        if let functionStarts = machOFile.functionStarts {
            result.append(OutlineItem(description: "Function Starts", info: functionStarts))
        }
        
        if let dataInCode = machOFile.dataInCode {
            result.append(OutlineItem(description: "Data in Code", info: dataInCode))
        }
        
        result.append(OutlineItem(description: "String Tables", info: machOFile.allCStringTables))
        
        
        if let symbolStrings = machOFile.symbolStrings {
            result.append(OutlineItem(description: "Symbol Table", info: symbolStrings))
        }
        
        if let indirectSymbols = machOFile.indirectSymbols {
            result.append(OutlineItem(description: "Indirect Symbol Table", info: indirectSymbols))
        }
        
        return result
    }
}
