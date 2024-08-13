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

    @State private var l_GW_Reply: DataFrame = ["year": [Int](), "occ": [Int]()]
//    @State private var l_GW_Total: DataFrame = ["lemma": ["samtals"], "occ": [1]] //total count

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
                    
                    Image("GigaWordBird")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    
                    TextField(
                        "Nafnorð í eintölu, nefnifalli", //noun, singular and nominative
                        text: $l_searchword
                    )
                    .onSubmit {
                        do {
                            (l_GW_Reply) = try gigawordStore.CallGigaWord(l_the_Word: l_searchword)
                            self.state = .loaded(l_GW_Reply)
                        }
                        catch {
                            self.state = .fetching(error)
                        }
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .border(.secondary)
                    
                    Button{
                        do {
                            (l_GW_Reply) = try gigawordStore.CallGigaWord(l_the_Word: l_searchword)
                            self.state = .loaded(l_GW_Reply)
                            
                        }
                        catch {
                            self.state = .fetching(error)
                        }
                    }
                label: {
                    Text("Leitum!").padding(0)
                }
                .contentShape(Rectangle())
                                        
                //If something has been typed
                    if(!l_searchword.isEmpty && !l_GW_Reply.isEmpty){
                    Text(l_searchword)
                        .font(.title)
                        .fontDesign(.default)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                        RenderDiscovery(detailFrame: l_GW_Reply)
                }
            }
            case .fetching(nil):
                ProgressView { Text("Les inn gagnasafn") }
            case .fetching(let error?):
                ErrorView(title: "Eitthvað fór úrskeiðis", error: error)
            }
        }.padding()
        .task {
            do {
                //This happens only when we load the screen for the first time
                //Makes the app search for the init value of l_searchword
                
                self.state = .loaded(l_GW_Reply)
            }
        }
    }
}
    
struct RenderDiscovery: View {
    
    let detailFrame: DataFrame
//    let totalFrame: DataFrame

    private struct ChartRow {
        let year: Date
        let occ: Int
    }
    
    private struct TotalRow {
        let total: Int
    }
    
    private var rows: [ChartRow] {

        let yearColumn = detailFrame.columns[0].assumingType(Int.self).filled(with: 9999)
        let occColumn = detailFrame.columns[1].assumingType(Int.self).filled(with: -1)
        let calendar = Calendar(identifier: .gregorian)
        
        var rows = [ChartRow]()
        for (year, count) in zip(yearColumn, occColumn) {
            let the_year = Int(year) //?? 1900
            let dateComponents = DateComponents(calendar: calendar, year: the_year)
            let date = dateComponents.date ?? .distantPast
            rows.append(ChartRow(year: date , occ: count))
        }
        return rows
    }
    
//    private var total: [TotalRow] {
//        let totalColumn = detailFrame.columns[1].assumingType(Int.self).filled(with: 9999)

//        var totals = [TotalRow]()
//        for (count) in totalColumn {
//            totals.append(TotalRow(total: count))
//        }

//
//        return total
//    }
        
    var body: some View {
        Chart(rows, id: \.year) { row in
            BarMark(
                x: .value("Year", row.year, unit: .year),
                y: .value("Count", row.occ)
            )
        }
        
//        if (totalFrame.isEmpty){
//            Text("Fann ekkert")
//        }
//        else {
//            Text("Alls: " + " \(total[0].total.formatted(.number.notation(.compactName))) tilfelli" )
//        }
        
    }
}
