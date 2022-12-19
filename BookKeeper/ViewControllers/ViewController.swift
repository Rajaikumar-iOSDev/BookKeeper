//
//  ViewController.swift
//  BookKeeper
//
//  Created by Rajai kumar on 18/10/22.
//

import UIKit
import CoreData
class ViewController: UIViewController{
    
    
    @IBOutlet weak var booksTableView: UITableView!
    private lazy var coreDataStack = CoreDataStack()
    private lazy var bookKeeperService = BookKeeperService(
        managedObjectContext: coreDataStack.mainContext,
        coreDataStack: coreDataStack)
    private var books: [BookKeeper]?
    private let segueIdentifier = "showDetail"
    private let cellIdentifier = "Cell"
    override func viewDidLoad() {
        super.viewDidLoad()
        batchInsertToCoredata()
        booksTableView.delegate = self
        booksTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    fileprivate func batchInsertToCoredata() {
        var booksArray = [BookKeeperModel]()
        var book = BookKeeperModel()
        book.bookName = "JuJutsu Kaisen"
        book.edition = "Second"
        book.price = 699
        book.volume = 1
        book.releaseYear = 2018
        booksArray.append(book)
        bookKeeperService.syncBooks(with: booksArray)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        books = bookKeeperService.getBooks()
        booksTableView.reloadData()
    }
    
    
    @IBAction func addBookAction(_ sender: Any) {
        
        performSegue(withIdentifier: segueIdentifier, sender: nil)
        
        
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == segueIdentifier,
            let navigationController = segue.destination as? UINavigationController,
            let controller = navigationController.topViewController as? BooksTableViewController
        else {
            return
        }
        
        navigationController.modalPresentationStyle = .fullScreen
        controller.bookKeeperService = bookKeeperService
        if let indexPath = booksTableView.indexPathForSelectedRow, let existingBook = books?[indexPath.row] {
            controller.book = existingBook
        }
    }
    
    
    
}
// MARK: - UITableViewDataSource
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: segueIdentifier, sender: nil)
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.booksTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        guard let book = books?[indexPath.row] else {
            return cell
        }
        cell.textLabel?.text = book.bookName
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard
            let book = books?[indexPath.row],
            editingStyle == .delete
        else {
            return
        }
        books?.remove(at: indexPath.row)
        bookKeeperService.delete(book)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
