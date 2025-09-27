//
//  FetchAndWritePostsFromOIC.swift
//  OICHeist
//
//  Created by Kenna Blackburn on 9/29/25.
//

import Foundation

extension Main {
    static func fetchAndWritePostsFromOIC(
        writePostsTo outputURL: URL = .desktopDirectory.appending(path: "OICHeist.json"),
        batchSize: Int = 100,
        batchLimit: Int? = nil,
        maxConnectionsPerHost: Int = 12,
    ) async throws {
        let config = URLSessionConfiguration.ephemeral
        config.httpMaximumConnectionsPerHost = maxConnectionsPerHost
        
        let session = URLSession(configuration: config)
        let api = OICMoviesAPI(session: session)
        let postURLs = try await api.fetchURLsFromSitemaps(matching: /wp-sitemap-posts-post-\d+\.xml/)

        let posts: [OICMoviesAPI.Post] = await {
            var posts = [OICMoviesAPI.Post]()
            
            let batches = postURLs
                .chunked(into: batchSize)
                .prefix(optionalMaxLength: batchLimit)
            
            let batchCount = batches.count
            
            for (batchIndex, batch) in batches.enumerated() {
                print("started  batch \(batchIndex + 1) of \(batchCount)")
                
                let startDate = Date()
                defer {
                    let runtime = Date()
                        .timeIntervalSince(startDate)
                        .formatted(.number.precision(.fractionLength(3)))
                        .appending("s")
                    
                    print("finished batch \(batchIndex + 1) of \(batchCount) in \(runtime)")
                }
                
                await withTaskGroup(of: OICMoviesAPI.Post?.self) { group in
                    for url in batch {
                        group.addTask {
                            do {
                                let post = try await api.fetchPost(from: url)
                                return post
                            } catch {
                                print("failed to fetch '\(url)'")
                                print("\t", "threw '\(error)'", separator: "")
                                
                                return nil
                            }
                        }
                    }
                    
                    for await post in group {
                        guard let post else { continue }
                        posts.append(post)
                    }
                    
                }
            }
            
            return posts
        }()

        let postsData = try JSONEncoder().encode(posts)
        try postsData.write(to: outputURL, options: [.atomic, .completeFileProtection])
    }
}
