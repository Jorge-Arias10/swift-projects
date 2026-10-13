//
//  QuizRow.swift
//  Quiz1DaniJorge
//
//  Created by e004 DIT UPM on 26/11/25.
//

import SwiftUI

struct QuizRowView: View {
    var quiz: QuizItem
    
    var body: some View {
        HStack(spacing: 15) {
            
            EasyAsyncImage(url: quiz.attachment?.url)
                .easyCircle()
                .frame(width: 50, height: 50)
            
            
            VStack(alignment: .leading, spacing: 5) {
                Text(quiz.question)
                    .font(.headline)
                    .lineLimit(2)
                
                
                                    
                    
                    HStack {
                        Text(quiz.author?.profileName ?? quiz.author?.username ?? "Anónimo")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        // Foto del autor
                        AsyncImage(url: quiz.author?.photo?.url) { img in
                            img.resizable().scaledToFill()
                        } placeholder: {
                            Color.clear
                        }
                        .frame(width: 20, height: 20)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 0.5))
                    }
                
                
                
                Spacer()
                
                // Estrella
                Image(systemName: quiz.favourite ? "star.fill" : "star")
                    .foregroundColor(quiz.favourite ? .yellow : .gray)
            }
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            
            
        }
        .background(
                    // Fondo color
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.1), // Color inicio suave
                            Color.purple.opacity(0.15) // Color fin
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(15)
        
        
    }
}
