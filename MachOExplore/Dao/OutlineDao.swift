// MachOExplore
// Created by: resse

import Foundation
import MachOKit

/**
 header.build,
 loadCommands.build,
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
 [[self.class _sectionsFieldBuilder] build],
 [[self.class _functionStartsFieldBuilder] build],
 [[self.class _rebaseInfoFieldBuilder] build],
 [[self.class _dataInCodeFieldBuilder] build],
 [[self.class _splitSegmentInfoFieldBuilder] build],
 [[self.class _bindingsInfoFieldBuilder] build],
 [[self.class _weakBindingsInfoFieldBuilder] build],
 [[self.class _lazyBindingsInfoFieldBuilder] build],
 [[self.class _exportsInfoFieldBuilder] build],
 [[self.class _stringTableFieldBuilder] build],
 [[self.class _symbolTableFieldBuilder] build],
 [[self.class _indirectSymbolTableFieldBuilder] build],
 */

struct OutlineVoidInfo { }

struct OutlineItem: Hashable, Identifiable {
    typealias ID = UUID
    
    var description: String
    var info: Any
    var subchild: [OutlineItem]?
    
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
                        subchild: children
                    )
                }
                
                let loadCommands = OutlineItem(
                    description: "LoadCommands",
                    info: OutlineVoidInfo(),
                    subchild: subLoadCommands
                )
                var machoItems = [header, loadCommands]
                
                let sections = machOfile.sections.map { sp in
                    return OutlineItem(
                        description: "Section (\(sp.segmentName),\(sp.sectionName))",
                        info: sp
                    )
                }
                
                machoItems.append(contentsOf: sections)
                
                let result =  [
                    OutlineItem(
                        description: machOfile.header.fileType?.description ?? "Unkown",
                        info: machOfile.header,
                        subchild: machoItems
                    )
                ]
                
                return result
                
//                machOfile.functionStarts
//                machOfile.rebaseOperations
//                machOfile.dataInCode
//                machOfile.bindingSymbols
//                machOfile.weakBindOperations
//                machOfile.lazyBindingSymbols
//                machOfile.lazyBindOperations
//                machOfile.exportedSymbols
//                machOfile.symbolStrings
//                machOfile.allCStringTables
//                machOfile.indirectSymbols
                
//                [[self.class _bindingsInfoFieldBuilder] build],
//                [[self.class _weakBindingsInfoFieldBuilder] build],
//                [[self.class _lazyBindingsInfoFieldBuilder] build],
//                [[self.class _exportsInfoFieldBuilder] build],
//                [[self.class _stringTableFieldBuilder] build],
//                [[self.class _symbolTableFieldBuilder] build],
//                [[self.class _indirectSymbolTableFieldBuilder] build],
            case .fat(let fatfile):
                print(try fatfile.machOFiles())
                return []
            }
        }
        return try await result.value
    }
}
