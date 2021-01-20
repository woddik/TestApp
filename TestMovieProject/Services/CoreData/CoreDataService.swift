//
//  CoreDataService.swift
//  TestProjectForShell
//
//  Created by Woddi on 5/28/19.
//  Copyright © 2019 Woddi. All rights reserved.
//

import Foundation
import CoreData
import UIKit

final class CoreDataService {
    
    enum DataType: Int, Hashable {
        case loginUpdate
        case timeUpdate
    }
    
    typealias DataClosure = (DataType) -> Void
    
    // MARK: - Public properties
    
    static var context: NSManagedObjectContext {
        return shared.managedObjectContext
    }
    
    static var privateContext: NSManagedObjectContext {
        return shared.privateManagedObjectContext
    }
    
    static var defaultThreadContext: NSManagedObjectContext {
        return Thread.isMainThread ? CoreDataService.context : CoreDataService.privateContext
    }
    
    // MARK: - Private properties
    
    private static let shared: CoreDataService = CoreDataService()
    
    private var dataBaseWasUpdatedClosures: [UUID: DataClosure] = [:]
    private var initalLoadCoompleted: Set<DataType> = []

    private var modelFileName: String {
        let url = Bundle.main.url(forResource: "", withExtension: "momd")
        return url?.lastPathComponent.components(separatedBy: ".").first ?? ""
    }
    
    // MARK: - Initialization
    
    init() {
        setupNotificationHandling()
    }
    
    // MARK: - Core Data Stack
    
    private lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        managedObjectContext.parent = privateManagedObjectContext
        
        return managedObjectContext
    }()
    
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: modelFileName, withExtension: "momd") else {
            preconditionFailure("Unable to Find Data Model\n")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            preconditionFailure("Unable to Find Data Model\n")
        }
        
        return managedObjectModel
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let fileManager = FileManager.default
        let storeName = "\(modelFileName).sqlite"
        
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        
        do {
            let options = [NSInferMappingModelAutomaticallyOption: true,
                           NSMigratePersistentStoresAutomaticallyOption: true]
            
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: persistentStoreURL,
                                                              options: options)
        } catch {
            preconditionFailure("Unable to Load Persistent Store\n")
        }
        
        return persistentStoreCoordinator
    }()
    
    static func fetchResultController<T: NSManagedObject>(for type: T.Type,
                                                          sortDescriptorParametr key: String,
                                                          ascending: Bool,
                                                          delegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<T> {
        let fetchRequest = NSFetchRequest<T>(entityName: "\(T.self)")
        let sortDescriptor = NSSortDescriptor(key: key, ascending: ascending)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController<T>(fetchRequest: fetchRequest,
                                                                     managedObjectContext: privateContext,
                                                                     sectionNameKeyPath: nil,
                                                                     cacheName: nil)
        fetchedResultsController.delegate = delegate
        return fetchedResultsController
    }
    
    static func getObjectsWith<T: NSManagedObject>(predicate: NSPredicate? = nil,
                                                   from context: NSManagedObjectContext = defaultThreadContext) -> [T] {
        return T.getObjectsWith(predicate: predicate, from: context)
    }
    
    static func getObjects<T: NSManagedObject>(from context: NSManagedObjectContext = defaultThreadContext,
                                               where predicate: (T) -> Bool) -> [T] {
        return T.getObjectsWith(from: context).filter(predicate)
    }
    
    static func first<T: NSManagedObject>(predicate: NSPredicate? = nil,
                                          from context: NSManagedObjectContext = defaultThreadContext) -> T? {
        return T.getObjectsWith(predicate: predicate, from: context).first
    }
    
    static func first<T: NSManagedObject>(from context: NSManagedObjectContext = defaultThreadContext,
                                          where predicate: (T) -> Bool) -> T? {
        return T.getObjectsWith(from: context).first(where: predicate)
    }
    
    static func removeObject<T: NSManagedObject>(_ object: T,
                                                 from context: NSManagedObjectContext = defaultThreadContext) -> Bool {
        context.performAndWait {
            context.delete(object)
        }
        return isExistObject(object, in: context)
    }
    
    static func isExistObject<T: NSManagedObject>(_ object: T,
                                                  in context: NSManagedObjectContext = defaultThreadContext) -> Bool {
        return getObjectsWith(predicate: NSPredicate(format: "SELF == %@", object), from: context).count > 0
    }
    
    static func saveAllContexts() {
        shared.saveChanges()
    }
    
    static func saveAndWait() {
        context.performAndWait {
            self.context.saveIfNeed()
            self.privateContext.performAndWait {
                self.privateContext.saveIfNeed()
            }
        }
    }
    
    static func updateMovie(by identifier: Int, with model: MovieDetail) {
        guard let cdMovie = CDMovie.findFirst(by: NSPredicate(format: "id == %i", identifier)) else {
            return
        }
        cdMovie.overview = model.overview
        cdMovie.release_date = model.releaseDate
        cdMovie.managedObjectContext?.saveIfNeed()
    }
    
    static func getMovieDetail(by identifier: Int) -> MovieDetail? {
        guard let cdMovie = CDMovie.findFirst(by: NSPredicate(format: "id == %i", identifier)) else {
            return nil
        }
        return cdMovie.convert(to: MovieDetail.self)
    }
}

// MARK: - IBAction

private extension CoreDataService {
    
    @IBAction func saveChanges(_ notification: NSNotification? = nil) {
        managedObjectContext.perform {
            self.managedObjectContext.saveIfNeed()
            self.privateManagedObjectContext.perform {
                self.privateManagedObjectContext.saveIfNeed()
            }
        }
    }
    
    func saveContextIfNeed(_ context: NSManagedObjectContext) {
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            debugPrint("Unable to Save Changes of Managed Object Context")
            debugPrint("\(error), \(error.localizedDescription)")
        }
    }
}

// MARK: - Private methods

private extension CoreDataService {
    
    func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(saveChanges(_:)),
                                       name: UIApplication.willTerminateNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(saveChanges(_:)),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)
    }
}

// MARK: - Observer

extension CoreDataService {
    
    static func notifyObseerversToUpdate(dataType: DataType) {
        shared.initalLoadCoompleted.insert(dataType)
        shared.dataBaseWasUpdatedClosures.forEach({ $0.value(dataType) })
    }
    
    static func isDataLoaded(by type: DataType) -> Bool {
        return shared.initalLoadCoompleted.contains(type)
    }
}

private extension CoreDataService {
    
    func dataBaseWasUpdatedClosures(by identifier: UUID, completion: @escaping DataClosure) {
        dataBaseWasUpdatedClosures[identifier] = completion
    }
    
    func removeObseerving(by identifier: UUID) {
        dataBaseWasUpdatedClosures[identifier] = nil
    }
}

extension CoreDataService {
    final class Observer {
        
        private let identifier = UUID()

        deinit {
            removeObseerving()
        }
    }
}

// MARK: - CoreDataService.Observer

extension CoreDataService.Observer {
    
    @discardableResult
    func dataBaseWasUpdated(completion: @escaping CoreDataService.DataClosure) -> CoreDataService.Observer {
        CoreDataService.shared.dataBaseWasUpdatedClosures(by: identifier, completion: completion)
        return self
    }

    func removeObseerving() {
        CoreDataService.shared.removeObseerving(by: identifier)
    }
}

// MARK: - NSManagedObject

extension NSManagedObject: CDGeneration { }

protocol CDGeneration where Self: NSManagedObject { }

extension CDGeneration {
    
    private static var entityName: String {
        return "\(Self.self)"
    }
    
    static func getObjectsWith(predicate: NSPredicate? = nil,
                               from context: NSManagedObjectContext = CoreDataService.defaultThreadContext) -> [Self] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            return try context.fetch(request) as? [Self] ?? []
        } catch {
            preconditionFailure(error.localizedDescription)
        }
    }
    
    static func findFirst(by predicate: NSPredicate? = nil,
                          in context: NSManagedObjectContext = CoreDataService.defaultThreadContext) -> Self? {
        if let obj = getObjectsWith(predicate: predicate, from: context).first {
            return obj
        }
        return nil
    }
    
    static func findFirstOrCreate(by predicate: NSPredicate? = nil,
                                  in context: NSManagedObjectContext = CoreDataService.defaultThreadContext) -> Self? {
        return findFirst(by: predicate, in: context) ?? create(in: context)
    }
    
    static func create(in context: NSManagedObjectContext = CoreDataService.defaultThreadContext) -> Self? {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            return nil
        }
        var obj: Self?
        context.performAndWait {
            obj = Self(entity: entity, insertInto: context)
        }
        return obj
    }
    
    static func removeAll(in context: NSManagedObjectContext = CoreDataService.defaultThreadContext) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            for managedObject in results {
                if let managedObjectData = managedObject as? NSManagedObject {
                    context.delete(managedObjectData)
                }
            }
        } catch {
            debugPrint("Delete all data in \(entityName) error : \(error) \(error.localizedDescription)")
        }
    }
    
    func remove() {
        managedObjectContext?.perform {
            self.managedObjectContext?.delete(self)
        }
    }
}

extension NSManagedObjectContext {
    
    /// If context has changes, method try to save and describ if something wrong
    func saveIfNeed() {
        do {
            if hasChanges {
                try save()
            }
        } catch {
            debugPrint("Unable to Save Changes of Managed Object Context")
            debugPrint("\(error), \(error.localizedDescription)")
        }
    }
}

extension NSSet {
    
    func allObjects<T>(by type: T.Type) -> [T]? {
        return allObjects as? [T]
    }
    
}

extension Array where Element: NSManagedObject {
    
    func convert<M: Decodable>(to object: M.Type) -> [M]? {
        return toJSON.compactMap({ $0.convert(to: object) })
    }
    
    var toJSON: [[String: Any]] {
        return compactMap({ $0.toJSON })
    }
}

extension Dictionary {

    func convert<M: Decodable>(to object: M.Type) -> M? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return try JSONDecoder().decode(object, from: jsonData)
        } catch {
            print("Dictionary convert error: \(error)")
            return nil
        }
    }
}

extension NSManagedObject {
    
    var toJSON: [String: Any] {
        var dict: [String: Any] = [:]
        entity.propertiesByName.forEach({
            let object = value(forKey: $0.key)
            if let item = object as? NSManagedObject {
                dict[$0.key] = item.toJSON
            } else if let item = object as? NSSet {
                dict[$0.key] = (item.allObjects as? [NSManagedObject])?.toJSON
            } else if let item = object as? URL {
                dict[$0.key] = item.absoluteString
            } else if let item = object as? Date {
                dict[$0.key] = DateFormatter.yyyyMMdd.string(from: item)
            } else if let item = object {
                dict[$0.key] = item
            }
        })
        return dict
    }
    
    func convert<M: Decodable>(to object: M.Type) -> M? {
        return toJSON.convert(to: object)
    }
}
