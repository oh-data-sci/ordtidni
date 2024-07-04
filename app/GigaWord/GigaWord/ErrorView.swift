//
//  ErrorView.swift
//  GigaWord
//
//  Created by Borkur Steingrimsson on 21/06/2024.
//

import SwiftUI

struct ErrorView: View {
  
  let title: String
  let error: Error
  let retryAction: (() -> Void)?
  
  init(title: String, error: Error, retryAction: (() -> Void)? = nil) {
    self.title = title
    self.error = error
    self.retryAction = retryAction
  }
  
  var body: some View {
      VStack(spacing: 8) {
        Text("☠️")
          .font(.largeTitle)
        Text(title)
          .font(.subheadline)
          .foregroundColor(.gray)
          .fontWeight(.bold)
        Text(error.localizedDescription)
          .font(.caption)
          .foregroundColor(.gray)
        if let retryAction {
          Button("Retry") { retryAction() }
            .buttonStyle(.borderedProminent)
            .padding()
        }
      }
      .multilineTextAlignment(.center)
  }
}
