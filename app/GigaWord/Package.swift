//
//  Package.swift
//  GigaWord
//
//  Created by Ragnar Örn Ólafsson on 13.8.2024.
//

import PackageDescription

let package = Package(
    name: "duck-db",
    dependencies: [
        .package(url: "https://github.com/duckdb/duckdb-swift", from: "1.0.1")
    ],
    targets: [
        .target(name: "duck-db", dependencies: [
          .product(name: "DuckDB", package: "duckdb-swift"),
        ]),
    ]
)
