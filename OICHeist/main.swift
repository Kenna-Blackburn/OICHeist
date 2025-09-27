//
//  main.swift
//  OICHeist
//
//  Created by Kenna Blackburn on 9/26/25.
//

import Foundation

try! await Main.fetchAndWritePostsFromOIC(
    writePostsTo: .desktopDirectory.appending(path: "OICHeist.json"),
    batchSize: 100,
    batchLimit: nil,
    maxConnectionsPerHost: 12,
)

try! Main.makeAndWriteMarkdownFromFile(
    readPostsFrom: .desktopDirectory.appending(path: "OICHeist.json"),
    writeMarkdownTo: .desktopDirectory.appending(path: "OICHeist.md"),
)
