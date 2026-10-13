//
//  EasyAsyncImage.swift
//  Quiz
//
//  Created by Santiago Pavón Gómez on 18/10/24.
//

import SwiftUI

struct EasyAsyncImage: View {
    
    var url: URL?
    var transaction: Transaction =
    Transaction(animation: .easeIn(duration: 0.3))
    
    var body: some View {
        CachedAsyncImage(url: url, transaction: transaction) { phase in
            if url == nil {
                Color.white
            } else if let image = phase.image {
                image.resizable()
            } else if let error = phase.error {
                let _ = print("Error en AsyncImage = \(error.localizedDescription)")
                Color.red
            } else {
                ProgressView()
            }
        }
        .scaledToFill()
    }
}

struct EasyCircle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .clipShape(Circle())
            .contentShape(Circle())
            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
            .shadow(radius: 10)
   }
}

struct EasyRoundedRectangle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .contentShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.yellow, lineWidth: 2))
            .shadow(radius: 20)
    }
}

extension View {
    func easyCircle() -> some View {
        self.modifier(EasyCircle())
    }
    func easyRoundedRectangle() -> some View {
        self.modifier(EasyRoundedRectangle())
    }
}

#Preview("Solo") {
    let url = URL(string: "https://www.etsit.upm.es/fileadmin/user_upload/banner_portada_escuela.jpg")!
    
    return EasyAsyncImage(url: url)
     .frame(width: 300, height: 300)

}

#Preview("Circle") {
    let url = URL(string: "https://www.etsit.upm.es/fileadmin/user_upload/banner_portada_escuela.jpg")!
    
    return EasyAsyncImage(url: url)
        .frame(width: 300, height: 300)
        .easyCircle()
}

#Preview("RR") {
    let url = URL(string: "https://www.etsit.upm.es/fileadmin/user_upload/banner_portada_escuela.jpg")!
    
   // let _ = URLCache.shared.removeAllCachedResponses()
    
    EasyAsyncImage(url: url,
                   transaction: Transaction(animation: .easeIn(duration: 4)))
    .frame(width: 300, height: 300)
    .easyRoundedRectangle()
}

