//
//  ContentView.swift
//  Quiz1DaniJorge
//
//  Created by e004 DIT UPM on 13/11/25.
//

import SwiftUI

struct QuizzesView: View {
    
    @Environment(QuizzesModel.self) var quizzesModel
    @Environment(Scores.self) var scores

    @State var model = QuizzesModel()
    
    var body: some View {
        
        NavigationStack {
            List {
                ForEach(quizzesModel.quizzes) { quizItem in
                    
                    
                    NavigationLink {
                        QuizPlayView(quiz:quizItem, model: model)
                            
                    } label: {
                        QuizRowView(quiz: quizItem)
                    }
                    
                }
            }
            
            .toolbar(content:{
                ToolbarItem {
                    Text("\(scores.acertados.count)")
                }
            })
            .navigationTitle("Acertar Quizzes")
            .onAppear {
                guard quizzesModel.quizzes.isEmpty else { return }
                
                quizzesModel.load()
            }
        }
    }
}
#Preview {
    
    @Previewable @State var quizzesModel = QuizzesModel()
    
    QuizzesView()
        .environment(quizzesModel)
}
