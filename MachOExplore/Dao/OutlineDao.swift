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

struct OutlineItem: Hashable, Identifiable {
    typealias ID = UInt64
    
    var description: String
    var offset: UInt64
    var subchild: [OutlineItem]?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(offset)
    }
    
    var id: UInt64 {
        self.offset
    }
}

class MachoAccesser: ObservableObject {
    var url: URL?
    
    
    func processUrl() async throws {
        guard let url = self.url else {
            throw "no fileurl"
        }
        try await self.load(fileUrl: url)
        
    }
    
    func load(fileUrl: URL) async throws {
        let result = Task(priority: .high) {
            let file = try MachOKit.loadFromFile(url: fileUrl)
            switch file {
            case .machO(let machOfile):
                print(machOfile)
                
                let header = OutlineItem(description: machOfile.header.fileType?.description ?? "Unkown", offset: 0)
                
                let loadCommands = OutlineItem(description: "LoadCommands", offset: UInt64(machOfile.headerStartOffset + machOfile.headerSize), subchild: [
                ])
                
                machOfile.loadCommands.forEach { command in
                    print(command.type)
                }
                
                
                machOfile.sections
                machOfile.functionStarts
                machOfile.rebaseOperations
                machOfile.dataInCode
                machOfile.bindingSymbols
                machOfile.weakBindOperations
                machOfile.lazyBindingSymbols
                machOfile.lazyBindOperations
                machOfile.exportedSymbols
                machOfile.symbolStrings
                machOfile.allCStringTables
                machOfile.indirectSymbols
                
//                [[self.class _bindingsInfoFieldBuilder] build],
//                [[self.class _weakBindingsInfoFieldBuilder] build],
//                [[self.class _lazyBindingsInfoFieldBuilder] build],
//                [[self.class _exportsInfoFieldBuilder] build],
//                [[self.class _stringTableFieldBuilder] build],
//                [[self.class _symbolTableFieldBuilder] build],
//                [[self.class _indirectSymbolTableFieldBuilder] build],
                
                
            case .fat(let fatfile):
                print(try fatfile.machOFiles())
            }
        }
        try await result.value
    }
}

extension LoadCommand {
    var description: String {
        let desc: String
        
        return ""
    }
}
