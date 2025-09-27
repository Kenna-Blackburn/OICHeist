//
//  OICPost.swift
//  OICHeist
//
//  Created by Kenna Blackburn on 9/29/25.
//

import Foundation

extension OICMoviesAPI {
    struct Post: Codable {
        let postURL: URL
        
        let title: String
        let captions: String
        
        let videoURL: URL
        let thumbnailURL: URL
        let vttCaptionsURL: URL
        let xmlCaptionsURL: URL
        
        init(
            _ postURL: URL,
            withAPI api: OICMoviesAPI
        ) async throws {
            let postData = try await api.session.data(from: postURL).0
            let postHTML = try String(data: postData, encoding: .utf8).unwrap(throwing: URLError(.badServerResponse))
            
            if postHTML.contains("youtube.com") {
                print("post contains youtube link; fetch may fail")
            }
            
            let title = try postHTML
                .firstMatch(of: /<title>\n?(.+?)\n?<\/title>/)
                .unwrap(throwing: URLError(.badServerResponse))
                .output.1.description
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            let videoURLString = try postHTML
                .firstMatch(of: /<meta property="og:video" content="(.+?\.mp4)"\s*\/>/)
                .unwrap(throwing: URLError(.badServerResponse))
                .output.1.description
            
            let videoURL = try URL(string: videoURLString).unwrap(throwing: URLError(.badURL))
            
            let thumbnailURLString = videoURLString.replacing(".mp4", with: "_thumb0-270x134.jpg")
            let thumbnailURL = try URL(string: thumbnailURLString).unwrap(throwing: URLError(.badURL))
            
            let vttCaptionsURLString = videoURLString.replacing(".mp4", with: ".vtt")
            let vttCaptionsURL = try URL(string: vttCaptionsURLString).unwrap(throwing: URLError(.badURL))
            
            let xmlCaptionsURLString = videoURLString.replacing(".mp4", with: ".xml")
            let xmlCaptionsURL = try URL(string: xmlCaptionsURLString).unwrap(throwing: URLError(.badURL))
            
            let captionsData = try await api.session.data(from: xmlCaptionsURL).0
            let captionsXML = try String(data: captionsData, encoding: .utf8).unwrap(throwing: URLError(.badServerResponse))
            let captions = captionsXML
                .matches(of: /<p.+?>\n?(.+?)\n?<\/p>/)
                .map(\.output.1.description)
                .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
                .joined(separator: " ")
            
            self.postURL = postURL
            self.title = title
            self.captions = captions
            self.videoURL = videoURL
            self.thumbnailURL = thumbnailURL
            self.vttCaptionsURL = vttCaptionsURL
            self.xmlCaptionsURL = xmlCaptionsURL
        }
    }
    
    func fetchPost(from url: URL) async throws -> Post {
        try await Post(url, withAPI: self)
    }
}
