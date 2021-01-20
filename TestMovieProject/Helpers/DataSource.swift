//
//  DataSource.swift
//
//  Created by Woddi on 6/27/19.
//

import Foundation

/**
 Example:
 
 struct Pen {
 
     let color: String
 }
 
 struct Student: ListValuesObjectData {
 
 //    var values: [Pen] = [Pen(), Pen(), Pen(), Pen(), Pen(), Pen(), Pen()]
 
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   OR  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 
     var values: [Pen] {
         get {
             return pens
         }
         set {
             pens = newValue
         }
     }
 
     var pens: [Pen] = [Pen(), Pen(), Pen(), Pen(), Pen(), Pen(), Pen()]
 }
 
 let allStudents = [Student(), Student(), Student(), Student(), Student()]
 let dataSource = DataSource<Student>(items: allStudents)
 // for use this case Student must conform ListValuesObjectData protocol
 
 dataSource.item(at: IndexPath(row: 3, section: 1))     // return Pen
 dataSource.section(at: 1)                              // return Student
 dataSource.allItemsCount()                             // return 35
 
 let dataSource = DataSource<[Student]>(values: allStudents)
 dataSource.section(at: 0)                              // if section's number will be more than 0 - will crash
                                                        // return Array<Student>
 dataSource.item(at: IndexPath(row: 3, section: 0))     // return Student
 dataSource.allItemsCount()                             // return 5
 */

protocol ListValuesObjectData {
    
    associatedtype Value
    
    var values: [Value] { get set }
}

class DataSource<Item: ListValuesObjectData> {
    
    private var sections: [Item]
    
    init(values: Item) {
        sections = [values]
    }
    
    init(items: [Item]) {
        sections = items
    }
    
    init() {
        sections = []
    }
    
    func removeAll() {
        sections = []
    }
    
    /// Insert section by index if index greater than possible insert to first possible place
    /// - Parameter section: Any 'ListValuesObjectData' object or array with any objects
    /// - Parameter index: Index for placing section
    func insertSection(_ section: Item, at index: Int) {
        let correctIndex = index <= sections.count ? index : sections.count
        sections.insert(section, at: correctIndex)
    }
    
    #warning("TODO - continue here")
    func insertItem(_ item: Item.Value, atIndex: Int, toSectionAt index: Int) {
        exeptionCreateBy(equalCase: sections.count > index, message: "Missing session by index: \(index)")
        sections[index].values.insert(item, at: atIndex)
    }
    
    func appendItem(_ item: Item.Value, toSectionAt index: Int) {
        guard sections.count < index else {
            return
        }
        sections[index].values.append(item)
    }
    
    func appendItems(_ items: [Item.Value], toSectionAt index: Int) {
        if let item = items as? Item, sections.count == index {
            sections.append(item)
        } else if sections.count < index {
            return
        } else {
            sections[index].values.append(contentsOf: items)
        }
    }
    
    func appendSection(_ section: Item) {
        sections.append(section)
    }
    
    func appendSections(contentsOf sections: [Item]) {
        self.sections.append(contentsOf: sections)
    }
    
    func removeItem(at indexPath: IndexPath) {
        sections[indexPath.section].values.remove(at: indexPath.row)
        deleteSectionIfEmpty(at: indexPath.section)
    }
    
    func removeSection(at index: Int) {
        sections.remove(at: index)
    }
    
    func replaceItem(at indexPath: IndexPath, to item: Item.Value) {
        sections[indexPath.section].values[indexPath.row] = item
    }
    
    func replaceSection(at index: Int = 0, to section: Item) {
        if sections.count <= index {
            sections.append(section)
        } else {
            sections[index] = section
        }
    }
    
    func replaceSections(at indexes: [Int], to sections: [Item]) {
        indexes.enumerated().forEach {
            self.sections[$0.element] = sections[$0.offset]
        }
    }
    
    func replaceAllSections(by items: [Item]) {
        sections = items
    }
    
    func item(at indexPath: IndexPath) -> Item.Value {
        return sections[indexPath.section].values[indexPath.row]
    }
    
    func section(at index: Int) -> Item {
        return sections[index]
    }
    
    func items(at indexPaths: [IndexPath]) -> [Item.Value] {
        return indexPaths.compactMap { item(at: $0) }
    }
    
    func allItems() -> [Item.Value] {
        var result = [Item.Value]()
        sections.forEach { result.append(contentsOf: $0.values) }
        return result
    }
    
    func allItemsCount() -> Int {
        return allItems().count
    }
    
    func numberOfItems(in section: Int) -> Int {
        return sections[section].values.count
    }
    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func firstSectionIndex(where predicate: (Item) -> Bool) -> Int? {
        for section in sections.enumerated() where predicate(section.element) {
            return section.offset
        }
        return nil
    }
    
    func firstSection(where predicate: (Item) -> Bool) -> Item? {
        for section in sections where predicate(section) {
            return section
        }
        return nil
    }
    
    func firstIdexPathFor(whereItem: (Item.Value) -> Bool = { _ in true }) -> IndexPath? {
        for sectionObj in sections.enumerated() {
            for itemObj in sectionObj.element.values.enumerated() where whereItem(itemObj.element) {
                return IndexPath(item: itemObj.offset, section: sectionObj.offset)
            }
        }
        return nil
    }
}

extension DataSource: Equatable where Item.Value: Equatable, Item: Equatable {
    
    static func == (lhs: DataSource<Item>, rhs: DataSource<Item>) -> Bool {
        return lhs.sections == rhs.sections
    }
}

extension DataSource: Hashable where Item.Value: Hashable, Item: Hashable {
    
    static func == (lhs: DataSource<Item>, rhs: DataSource<Item>) -> Bool {
        return lhs.sections == rhs.sections
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(sections)
    }

    func allIndexPaths() -> [IndexPath] {
        return allItems().compactMap({ mapedItem in firstIdexPathFor(whereItem: { item in item == mapedItem })})
    }
}

extension DataSource where Item.Value: Equatable {
    
    func idexPathFor(item: Item.Value) -> IndexPath? {
        for sectionObj in sections.enumerated() {
            for itemObj in sectionObj.element.values.enumerated() where itemObj.element == item {
                return IndexPath(item: itemObj.offset, section: sectionObj.offset)
            }
        }
        return nil
    }
}

// MARK: - Private methods

private extension DataSource {
    
    func exeptionCreateBy(equalCase: Bool,
                          message: String,
                          filename: StaticString = #file,
                          line: UInt = #line,
                          funcName: String = #function) {
        guard !equalCase else {
            return
        }
        let errorText =
        """
        \n
        ========================================================================================
        Error message: \(message)
        Date: \(Date().description)
        [\(sourceFileName(filePath: filename))] in line: [\(line)] | function name: [\(funcName)]]
        ========================================================================================

        """
        preconditionFailure(errorText, file: filename, line: line)
    }
    
    func sourceFileName(filePath: StaticString) -> String {
        let components = filePath.description.components(separatedBy: "/")
       return components.last ?? ""
    }
    
    func deleteSectionIfEmpty(at index: Int) {
        if sections[index].values.count == 0 {
            sections.remove(at: index)
        }
    }
}

extension Array: ListValuesObjectData {
    
    typealias Value = Element
    
    var values: [Element] {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    
}
