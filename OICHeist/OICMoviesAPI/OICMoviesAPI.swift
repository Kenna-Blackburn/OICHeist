//
//  OICMoviesAPI.swift
//  OICHeist
//
//  Created by Kenna Blackburn on 9/29/25.
//

import Foundation

final class OICMoviesAPI {
    let session: URLSession
    
    init(
        session: URLSession = .init(configuration: .ephemeral)
    ) {
        self.session = session
    }
}

extension OICMoviesAPI {
    func fetchURLs(
        fromSitemaps sitemapURLs: [URL]
    ) async throws -> [URL] {
        return try await withThrowingTaskGroup(of: [URL].self) { group in
            for url in sitemapURLs {
                group.addTask {
                    let data = try await self.session.data(from: url).0
                    let xmlString = try String(data: data, encoding: .utf8).unwrap(throwing: URLError(.badServerResponse))
                    let urls = xmlString
                        .matches(of: /<loc>(.+?)<\/loc>/)
                        .map(\.output.1.description)
                        .compactMap(URL.init)
                    
                    return urls
                }
            }
            
            var urls = [URL]()
            while let url = try await group.next() {
                urls.append(contentsOf: url)
            }
            
            return urls
        }
    }
}

extension OICMoviesAPI {
    func fetchURLsFromSitemap(
        partialID: String? = nil,
        namespace: String = "wp-sitemap",
        index: Int? = nil,
    ) async throws -> [URL] {
        let fullID = [namespace, partialID, index.map(String.init)]
            .compactMap({ $0 })
            .joined(separator: "-")
        
        let urlString = "https://www.oicmovies.com/\(fullID).xml"
        let url = try URL(string: urlString).unwrap(throwing: URLError(.badURL))
        
        return try await fetchURLs(fromSitemaps: [url])
    }
    
    func fetchURLsFromSitemaps(
        matching regex: some RegexComponent
    ) async throws -> [URL] {
        let mainSitemapURLs = try await fetchURLsFromSitemap()
        let matchingSitemapURLs = mainSitemapURLs
            .filter({ !$0.absoluteString.matches(of: regex).isEmpty })
        
        return try await fetchURLs(fromSitemaps: matchingSitemapURLs)
    }
}
