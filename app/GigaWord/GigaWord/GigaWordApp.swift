//
//  GigaWordApp.swift
//  GigaWord
//
//  Created by Borkur Steingrimsson on 18/06/2024.
//

import SwiftUI

@main
struct GigaWordApp: App {
    
    private enum ViewState {
      case loading(Error?)
      case ready(GigaWordStore)
    }
    

    @State private var state = ViewState.loading(nil)
    
    var body: some Scene {
        WindowGroup {
            Group {
              switch state {
              case .ready(let gigawordStore):
                  ContentView( gigawordStore: gigawordStore)
//                ContentView()
              case .loading(nil):
                ProgressView { Text("Loading Gigawords") }
              case .loading(let error?):
                ErrorView(title: "Failed To Load Gigawords", error: error) {
                  Task { await prepareGigaWordStore() }
                }
              }
            }
            .task {
              await prepareGigaWordStore()
            }
            
        }
    }
    
    private func prepareGigaWordStore() async {
      guard case .loading(_) = state else { return }
      self.state = .loading(nil)
      do {
        self.state = .ready(try await GigaWordStore.create())
      }
      catch {
        self.state = .loading(error)
      }
    }
    

}


