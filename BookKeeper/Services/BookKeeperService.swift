//
//  BookKeeperService.swift
//  BookKeeper
//
//  Created by Rajai kumar on 22/10/22.
//

import Foundation
import CoreData

public final class BookKeeperService {
    // MARK: - Properties
    let managedObjectContext: NSManagedObjectContext
    let coreDataStack: CoreDataStack
    
    // MARK: - Initializers
    public init(managedObjectContext: NSManagedObjectContext, coreDataStack: CoreDataStack) {
        self.managedObjectContext = managedObjectContext
        self.coreDataStack = coreDataStack
    }
}

// MARK: - Public
extension BookKeeperService {
    @discardableResult
    public func add(_ bookName: String, edition: String, volume: Int32, price: Int32, releaseYear: Int32) -> BookKeeper {
        let book = BookKeeper(context: managedObjectContext)
        book.bookName = bookName
        book.edition = edition
        book.volume = volume
        book.price = price
        book.releaseYear = releaseYear
        
        coreDataStack.saveContext(managedObjectContext)
        return book
    }
    
    fileprivate func toDictionary(_ books: [BookKeeperModel], _ reportsArray: inout [[String : Any]]) {
        do{
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(books)
            reportsArray = try JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.mutableContainers ) as! [[String:Any]]
        } catch {
            print(error)
        }
    }
    
    public func syncBooks(with books: [BookKeeperModel]) {
        let bgContext = coreDataStack.newDerivedContext
        bgContext().mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let mainContext = coreDataStack.mainContext
        var booksArray = [[String:Any]]()
        toDictionary(books, &booksArray)
        bgContext().performAndWait {
            let insertRequest = NSBatchInsertRequest(entity: BookKeeper.entity(), objects: booksArray)
            insertRequest.resultType = NSBatchInsertRequestResultType.objectIDs
            let result = try? bgContext().execute(insertRequest) as? NSBatchInsertResult
            
            if let objectIDs = result?.result as? [NSManagedObjectID], !objectIDs.isEmpty {
                let save = [NSInsertedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: save, into: [mainContext])
            }
        }
    }
    
    public func getBooks() -> [BookKeeper]? {
        let bookFetch: NSFetchRequest<BookKeeper> = BookKeeper.fetchRequest()
        do {
            let results = try managedObjectContext.fetch(bookFetch)
            return results
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        return nil
    }
    
    @discardableResult
    public func update(_ book: BookKeeper) -> BookKeeper {
        coreDataStack.saveContext(managedObjectContext)
        return book
    }
    
    public func delete(_ book: BookKeeper) {
        managedObjectContext.delete(book)
        coreDataStack.saveContext(managedObjectContext)
    }
}
