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
    
    @State private var showErrorAlert: Bool = false
    @State private var showOnlyUnanswered = false

    @State private var errorMessage: String = "" {
        didSet {
            showErrorAlert = true
        }
    }
    var filteredQuizzes: [QuizItem] {
        if showOnlyUnanswered {
            return quizzesModel.quizzes.filter {
                !scores.acertados.contains($0.id)
            }
        } else {
            return quizzesModel.quizzes
        }
    }

    var body: some View {
        
        NavigationStack {
            VStack {
                Toggle("Mostrar solo no acertados", isOn: $showOnlyUnanswered)
                    .padding(.horizontal)
                    .toggleStyle(.switch)

                List {
                    ForEach(filteredQuizzes) { quizItem in
                        NavigationLink {
                            QuizPlayView(quizId: quizItem.id)
                        } label: {
                            QuizRowView(quiz: quizItem)
                        }
                    }
                }
            }

                        
            .toolbar(content:{
                ToolbarItem(placement: .topBarTrailing) {
                    VStack {
                        Text("Sesión: \(scores.acertados.count)")
                            .font(.caption)

                        Text("Total: \(scores.totalAcertados.count)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

            ToolbarItem (placement: .topBarLeading) {
                Button("Recargar") {
                    Task {
                        do {
                            try await quizzesModel.download()
                        } catch {
                            print("Error descargando los quizzes: \(error)")
                            errorMessage = "No puedo descargar"
                        }
                    }
                }
            }
        })
            
            
            
            .alert("Error", isPresented: $showErrorAlert) {
            } message: {
                Text(errorMessage)
            }
            
            .navigationTitle("Acertar Quizzes")
            .task {
                do {
                    guard quizzesModel.quizzes.isEmpty else { return }
                    
                    try await quizzesModel.download()
                }
                catch {
                    print("Error downloading quizzes: \(error)")
                    errorMessage = "No puedo descargar los quizzes. Asegúrate de estar conectado a internet y vuelve a intentar."
                    
                }
            }
        }
    }
}
    
#Preview {
    
    @Previewable @State var quizzesModel = QuizzesModel()
    
    QuizzesView()
        .environment(quizzesModel)
}
