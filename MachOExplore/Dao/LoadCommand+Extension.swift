// MachOExplore
// Created by: resse

import Foundation
import MachOKit

extension MachHeader {
    
}

protocol LoadCommandDescription {
    func desc(from machofile: MachOFile) -> String
    
    func children(in file: MachOFile) -> [OutlineItem]?
}

extension LoadCommandDescription {
    func children(in file: MachOFile) -> [OutlineItem]? {
        nil
    }
}

extension SegmentCommand: LoadCommandDescription {
    func desc(from machofile: MachOFile) -> String {
        segmentName
    }
    
    func children(in file: MachOFile) -> [OutlineItem]? {
        let sections = self.sections(in: file).map { section in
            OutlineItem(
                description: "Section Header(\(section.sectionName))",
                info: section
            )
        }
        return sections.count == 0 ? nil : sections
    }
}

extension DylibCommand: LoadCommandDescription {
    func desc(from machofile: MachOFile) -> String {
        String(self.dylib(in: machofile).name.split(separator: "/").last ?? "")
    }
}

extension DylinkerCommand: LoadCommandDescription {
    func desc(from machoFile: MachOFile) -> String {
        self.name(in: machoFile)
    }
}

extension SegmentCommand64: LoadCommandDescription {
    func desc(from machofile: MachOFile) -> String {
        self.segmentName
    }
    
    func children(in file: MachOFile) -> [OutlineItem]? {        
        let sections = self.sections(in: file).map { section in
            OutlineItem(
                description: "Section Header(\(section.sectionName))",
                info: section
            )
        }
        return sections.count == 0 ? nil : sections
    }
}

extension RpathCommand: LoadCommandDescription {
    func desc(from machofile: MachOFile) -> String {
        self.path(in: machofile)
    }
}
