//
//  BookKeeper.swift
//  BookKeeper
//
//  Created by Rajai kumar on 22/10/22.
//

import Foundation
public struct BookKeeperModel: Codable {
    
    var bookName: String
    var edition: String
    var price: Int32
    var releaseYear: Int32
    var volume: Int32
    
    init() {
        bookName = ""
        edition = ""
        price = 0
        releaseYear = 0
        volume = 0
        
    }
}
