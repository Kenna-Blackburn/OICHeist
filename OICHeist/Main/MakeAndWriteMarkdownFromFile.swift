//
//  MakeAndWriteMarkdownFromFile.swift
//  OICHeist
//
//  Created by Kenna Blackburn on 9/29/25.
//

import Foundation

extension Main {
    static func makeAndWriteMarkdownFromFile(
        readPostsFrom inputURL: URL = .desktopDirectory.appending(path: "OICHeist.json"),
        writeMarkdownTo outputURL: URL = .desktopDirectory.appending(path: "OICHeist.md"),
    ) throws {
        let postsData = try Data(contentsOf: inputURL)
        let posts = try JSONDecoder().decode([OICMoviesAPI.Post].self, from: postsData)
        
        let markdown = """
        
        # OICMovies.com
        
        > [!IMPORTANT]
        > GitHub is truncating this file. To see all posts you'll have to download README.md or View Raw.
        
        > [!NOTE]
        > Thumbnail sizes are inconsistently named and not directly included in post HTML. Many videos also lack thumnails entirely. If the defaulting thumbnail is invalid or a video does not have one a placeholder will be shown client-side instead (typically a dashed questionmark box). This can still be clicked to open the MP4. If your client displays no placeholder (note it might take several seconds to load) you can find the MP4 URL under each post's Metadata.
        
        \(
            posts
                .map { post in
                    """
                    ## \(post.title)
                    
                    [![\(post.title) Video MP4](\(post.thumbnailURL))](\(post.videoURL))
                    
                    <details>
                    <summary>Captions</summary>
                    
                    \(post.captions)
                    
                    </details>
                    
                    <details>
                    <summary>Metadata</summary>
                    
                    * [Source Post](\(post.postURL))
                    * [Video MP4](\(post.videoURL))
                    * [Thumbnail JPEG](\(post.thumbnailURL))
                    * [XML Captions](\(post.xmlCaptionsURL))
                    * [VTT Captions](\(post.vttCaptionsURL))
                    
                    </details>
                    """
                }
                .joined(separator: "\n\n")
        )
        """
        
        try markdown.write(to: outputURL, atomically: true, encoding: .utf8)
    }
}
