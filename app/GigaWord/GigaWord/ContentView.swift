//
//  ContentView.swift
//  GigaWord
//
//  Created by Borkur Steingrimsson on 18/06/2024.
//

import SwiftUI
import Charts
@preconcurrency import TabularData

  
struct ContentView: View {
    @State private var l_searchword: String = ""
//    @State private var l_GW_Reply: DataFrame = DataFrame.init() //["lemma": ["total"], "occ": [0]]
    @State private var l_GW_Reply: DataFrame = ["year": [0], "lemma": ["Öll orð"], "occ": [301537309]] //that number comes from the final parquet file.
    @State private var l_GW_Total: DataFrame = ["lemma": ["samtals"], "occ": [1]] //total count

    private enum ViewState {
        case fetching(Error?)
        case loaded(DataFrame)
    }
    
    let gigawordStore: GigaWordStore
    @State private var state = ViewState.fetching(nil)
    
    var body: some View {
        Group {
            switch state {
            case .loaded(_):
                VStack {
                    
                    HStack{
                        Image("GigaWordBird")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    
                    TextField(
                        "Enter an Icelandic noun",
                        text: $l_searchword
                    )
                    .onSubmit {
                        do {
                            (l_GW_Reply,l_GW_Total) = try gigawordStore.CallGigaWord(l_the_Word: l_searchword)
                            self.state = .loaded(l_GW_Reply)
                        }
                        catch {
                            self.state = .fetching(error)
                        }
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .border(.secondary)
                    
//                    Image(systemName: "globe")
//                        .imageScale(.large)
//                        .foregroundStyle(.tint)

                    Button{
                        do {
                            (l_GW_Reply,l_GW_Total) = try gigawordStore.CallGigaWord(l_the_Word: l_searchword)
                            self.state = .loaded(l_GW_Reply)
                        }
                        catch {
                            self.state = .fetching(error)
                        }
                    }
                    label: {
                        Text("Search GW ").padding(20)
                    }
                .contentShape(Rectangle())
                    
                    
                    //If something has been typed
                    if(!l_searchword.isEmpty){
                        Text(l_searchword)
                            .font(.title)
                            .fontDesign(.default)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        RenderDiscovery(detailFrame: l_GW_Reply, totalFrame: l_GW_Total)
                    }
                    
                    
                }
            case .fetching(nil):
                ProgressView { Text("Fetching Data") }
            case .fetching(let error?):
                ErrorView(title: "Query Failed", error: error)
            }
        }    .padding()
               .task {
                   do {
                       //This happens only when we load the screen for the first time
                       //Makes the app search for the init value of l_searchword
                       
                       (l_GW_Reply,l_GW_Total) = try  gigawordStore.CallGigaWord(l_the_Word: l_searchword)
                       self.state = .loaded(l_GW_Reply)
                   }
                   catch {
                       self.state = .fetching(error)
                   }

            
        }
    }
}
    
struct RenderDiscovery: View {
    
    let detailFrame: DataFrame
    let totalFrame: DataFrame
    
    private struct ChartRow {
        let year: Date
        let occ: Int
    }
    
    private struct TotalRow {
        let total: Int
    }
    
    private var rows: [ChartRow] {
//        let yearColumn = detailFrame.columns[0].assumingType(String.self) //.filled(with: 9999)
        let yearColumn = detailFrame.columns[0].assumingType(String.self) //.filled(with: 9999)
        let occColumn = detailFrame.columns[1].assumingType(Int.self).filled(with: -1)
        let calendar = Calendar(identifier: .gregorian)
        
        var rows = [ChartRow]()
        for (year, count) in zip(yearColumn, occColumn) {
            let the_year = Int(year!) ?? 0
            let dateComponents = DateComponents(calendar: calendar, year: the_year)
            let date = dateComponents.date ?? .distantPast
            rows.append(ChartRow(year: date , occ: count))
        }
        return rows
    }
    
    private var total: [TotalRow] {
        let totalColumn = totalFrame.columns[0].assumingType(Int.self).filled(with: 9999)

        
        var rows = [TotalRow]()
        for (count) in totalColumn {
            rows.append(TotalRow(total: count))
        }
        return rows
    }
        
    var body: some View {
        Chart(rows, id: \.year) { row in
            BarMark(
                x: .value("Year", row.year, unit: .year),
                y: .value("Count", row.occ)
            )
        }
        
        if (totalFrame.isEmpty){
            Text("No results")
        }
        else {
//            if (!l_searchword.isEmpty){
            Text("Total: " + " \(total[0].total.formatted(.number.notation(.compactName)))"
            )
//            }
        }
        
    }
}
