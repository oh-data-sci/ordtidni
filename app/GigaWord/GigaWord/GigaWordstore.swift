//
//  GigaWordStore.swift
//  GigaWord
//
//  Created by Borkur Steingrimsson on 21/06/2024.
//

import Foundation


import DuckDB
import Foundation
import TabularData
//import UIKit*

final class GigaWordStore {
    
    static func create() async throws -> GigaWordStore {

        let path = Bundle.main.bundlePath+"/GWData.bundle"
        
        //let sql_1 = "CREATE TABLE GigaWord AS SELECT * FROM read_parquet('\(path)/detail_nouns.parquet' )"
        //let sql_2 = "CREATE table GigaWord_Total AS SELECT * FROM read_parquet('\(path)/total_nouns.parquet')"

        let duckdbfile = URL(fileURLWithPath: path+"/GigaWord.duckdb")
        
        //let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
//        let url = NSURL(fileURLWithPath: path)
//        if let pathComponent = url.appendingPathComponent("GigaWord.duckdb") {
//            let filePath = pathComponent.path
//            let fileManager = FileManager.default
//            if fileManager.fileExists(atPath: filePath) {
//                print("FILE AVAILABLE")
//            } else {
//                print("FILE NOT AVAILABLE")
//            }
//        } else {
//            print("FILE PATH NOT AVAILABLE")
//        }
        
//        var fileSize : UInt64

//        do {
//            return [FileAttributeKey : Any]
//            let attr = try FileManager.default.attributesOfItem(atPath: path+"/GigaWord.duckdb")
//            print(attr)
            
//            fileSize = attr[FileAttributeKey.size] as! UInt64
            
            //print(path)
            //print(fileSize)
//        } catch {
//            print("Error: \(error)")
//        }
        
        //print(duckdbfile.path())
        let db_config = Database.Configuration()
//        try db_config.setValue("READ_WRITE", forKey: "access_mode") // the file in the bundle is 420
        try db_config.setValue("READ_ONLY", forKey: "access_mode")
        let database = try Database(store: .file(at: duckdbfile), configuration: db_config)


        let connection = try database.connect()

        return GigaWordStore(database: database, connection: connection)
    }
    
    let database: Database
    let connection: Connection
    
    private init(database: Database, connection: Connection) {
        self.database = database
        self.connection = connection
    }
    
    func CallGigaWord(l_the_Word: String) throws -> (DataFrame){ //,DataFrame){ //},DataFrame) {

        let l_sql_detail = "select year, occ from GigaWord where lemma='"+l_the_Word.lowercased()+"' order by year"
        //let l_sql_total = "select sum(occ) as occ_total from GigaWord where lemma='"+l_the_Word.lowercased()+"'"
        //let l_sql_total = "select occ as occ_total from GigaWord_Total where lemma='"+l_the_Word.lowercased()+"'"
        //let l_sql_grand_total = "select count(distinct lemma) as lemmas from GigaWord"

        let ret_detail = try connection.query(l_sql_detail)
//        let ret_total = try connection.query(l_sql_total)
        //let ret_grand_total = try connection.query(l_sql_grand_total)
//        if ret_total.isEmpty {
            
//        print(l_sql_total)
//        }

        let year = ret_detail[0].cast(to: Int.self)
        let occurance = ret_detail[1].cast(to: Int.self)
        
//        let occ_total = ret_total[0].cast(to: Int.self)
        
        //let grand_total = ret_grand_total[0].cast(to: Int.self)

        let df_detail = DataFrame(columns: [
            TabularData.Column(year).eraseToAnyColumn(),
            TabularData.Column(occurance).eraseToAnyColumn(),
        ])
        
//        let df_total = DataFrame(columns: [
//            TabularData.Column(occ_total).eraseToAnyColumn(),
//        ])
        
        //let df_grand_total = DataFrame(columns: [
        //    TabularData.Column(grand_total).eraseToAnyColumn(),
        //])
        
        return (df_detail)
    }
}

