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
        
        let sql_1 = "CREATE TABLE GigaWord AS SELECT * FROM read_parquet('\(path)/detail_nouns.parquet' )"
        let sql_2 = "CREATE table GigaWord_Total AS SELECT * FROM read_parquet('\(path)/total_nouns.parquet')"
       
        let database = try Database(store: .inMemory)
        let connection = try database.connect()

        
//        let _ = try connection.query("CREATE TABLE GigaWord AS SELECT * FROM read_parquet('\(path)');")
        let _ = try connection.query(sql_1)
        let _ = try connection.query(sql_2)

        return GigaWordStore(database: database, connection: connection)
    }
    
    let database: Database
    let connection: Connection
    
    private init(database: Database, connection: Connection) {
        self.database = database
        self.connection = connection
    }
    
    func CallGigaWord(l_the_Word: String) throws -> (DataFrame,DataFrame) {

        let l_sql = "select year, occ from GigaWord where lemma='"+l_the_Word.lowercased()+"' order by year"
        let l_sql_total = "select occ as occ_total from GigaWord_Total where lemma='"+l_the_Word.lowercased()+"'"
        
        let result = try connection.query(l_sql)
        let ret_total = try connection.query(l_sql_total)
        
        //Is this actually fucking upp the aggreagates?? what does this do?

        let year = result[0].cast(to: String.self)
        let occurance = result[1].cast(to: Int.self)
        
        let occ_total = ret_total[0].cast(to: Int.self)

        let df = DataFrame(columns: [
            TabularData.Column(year).eraseToAnyColumn(),
            TabularData.Column(occurance).eraseToAnyColumn(),
        ])
        
        let df_total = DataFrame(columns: [
            TabularData.Column(occ_total).eraseToAnyColumn(),
        ])
        
        return (df,df_total)
    }
}

