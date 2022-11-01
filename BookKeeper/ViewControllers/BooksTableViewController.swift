//
//  BooksTableViewController.swift
//  BookKeeper
//
//  Created by Rajai kumar on 24/10/22.
//

import UIKit

class BooksTableViewController: UITableViewController {
    
    // MARK: - Properties
    var book: BookKeeper?
    var bookKeeperService: BookKeeperService?
    @IBOutlet weak var bookNameTextField: UITextField!
    @IBOutlet weak var bookEditionTextField: UITextField!
    @IBOutlet weak var bookVolumeTextField: UITextField!
    @IBOutlet weak var bookPriceTextField: UITextField!
    @IBOutlet weak var bookReleaseYearTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = false
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        if let book = book {
            bookNameTextField.text = book.bookName
            bookEditionTextField.text = String(describing: book.edition)
            bookVolumeTextField.text = String(describing:book.volume)
            bookPriceTextField.text = String(describing:book.price)
            bookReleaseYearTextField.text = String(describing:book.releaseYear)
        }
    }
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func saveAction(_ sender: Any) {
        let bookName = bookNameTextField.text ?? ""
        let bookEdition = bookEditionTextField.text ?? ""
        let bookVolume = Int32(bookVolumeTextField.text ?? "") ?? 0
        let bookPrice = Int32(bookPriceTextField.text ?? "") ?? 0
        let bookReleaseYear = Int32(bookReleaseYearTextField.text ?? "") ?? 0
        
        if let book = book {
            book.bookName = bookName
            book.edition = bookEdition
            book.volume = bookVolume
            book.price = bookPrice
            book.releaseYear = bookReleaseYear
            bookKeeperService?.update(book)
            dismiss(animated: true, completion: nil)
        }else {
            bookKeeperService?.add(bookName, edition: bookEdition, volume: bookVolume, price: bookPrice, releaseYear: bookReleaseYear)
            dismiss(animated: true, completion: nil)
        }
    }
    
}
