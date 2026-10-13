//
//  CachedAsyncImage.swift
//  Quiz
//
//  Created by Santiago Pavón Gómez on 18/8/25.
//

import SwiftUI

struct CachedAsyncImage<Content: View>: View {

    var url: URL?
    var transaction: Transaction = Transaction()
    
    @ViewBuilder var content: (AsyncImagePhase) -> Content
    
    enum UIImageError: Error {
        case dataCorrupted
    }

    @State private var phase: AsyncImagePhase = .empty
    
    var body: some View {
        content(phase)
            .transition(.opacity)
            .task() {
                 await self.loadImage()
            }
    }
    
    private func loadImage() async {
                
        guard let url else { return }
        
        let request = URLRequest(url: url)

        if let cached = URLCache.shared.cachedResponse(for: request) {
            if let image = UIImage(data: cached.data) {
                withAnimation(transaction.animation) {
                    phase = .success(Image(uiImage: image))
                }
                return
            } else {
                URLCache.shared.removeCachedResponse(for: request)
            }
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let response = response as? HTTPURLResponse, (200...300 ~= response.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            guard let image = UIImage(data: data) else {
                throw UIImageError.dataCorrupted
            }
            
            URLCache.shared.storeCachedResponse(.init(response: response, data: data), for: request)
            
            withAnimation(transaction.animation) {
                phase = .success(Image(uiImage: image))
            }
        } catch {
            withAnimation(transaction.animation) {
                phase = .failure(error)
            }
        }
    }

}

