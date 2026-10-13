//
//  QuizPlayView.swift
//  Quiz1DaniJorge
//
//  Created by e004 DIT UPM on 26/11/25.
//

import SwiftUI

struct QuizPlayView: View {
    // Variables que recibe la vista
    var quiz: QuizItem
    var model: QuizzesModel
    
    // Variables de estado
    @State private var answer: String = ""
    @State private var showingAlert = false
    @State private var isCorrect = false
    @Environment(Scores.self) var scores
    
    var body: some View {
        GeometryReader { geometry in
            // Detectamos si estamos en horizontal
            let isLandscape = geometry.size.width > geometry.size.height
            
            ScrollView {
                if isLandscape {
                    
                    HStack(alignment: .center, spacing: 20) {
                        // Columna Izquierda: Pregunta, Autor e Imagen
                        VStack(spacing: 10) {
                            headerView // Pregunta y Autor
                            imageView(size: 150)
                        }
                        .frame(width: geometry.size.width * 0.45)
                        
                        // Columna Derecha: Input y Botón
                        VStack {
                            inputArea
                        }
                        .frame(width: geometry.size.width * 0.45)
                    }
                    .padding()
                    .frame(minHeight: geometry.size.height)
                    
                } else {
                    
                    VStack(spacing: 15) {
                        headerView
                        imageView(size: 250)
                        inputArea
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Pregunta")
        .navigationBarTitleDisplayMode(.inline)
        
        .alert(isCorrect ? "¡Felicidades!" : "¡Oooh, lo siento!", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(isCorrect ? "¡Has acertado la pregunta! Continua con la siguiente." : "Has fallado la pregunta... Inténtalo de nuevo.")
        }
    }
    
   
    
    // Pregunta, Estrella y Autor
    var headerView: some View {
        VStack(spacing: 15) {
            HStack {
                Text(quiz.question)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                Image(systemName: quiz.favourite ? "star.fill" : "star")
                    .foregroundColor(quiz.favourite ? .yellow : .gray)
                    .font(.title)
            }
            .padding(.top)
            
            HStack(spacing: 6) {
                Text(quiz.author?.username ?? quiz.author?.profileName ?? "Anónimo")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                AsyncImage(url: quiz.author?.photo?.url) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 20, height: 20)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 0.5))
            }
            .padding(.bottom, 10)
        }
    }
    
    // Imagen de la pregunta
    func imageView(size: CGFloat) -> some View {
        EasyAsyncImage(url: quiz.attachment?.url)
            .frame(width: size, height: size)
            .aspectRatio(1, contentMode: .fit)
            .easyRoundedRectangle()
    }
    
    // respuesta y botón
    var inputArea: some View {
        VStack(alignment: .leading) {
            Text("Tu respuesta:")
                .font(.caption)
                .foregroundStyle(.gray)
            
            TextField("Escribe aquí tu respuesta...", text: $answer)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .onSubmit {
                    checkAnswer()
                }
            
            Button(action: {
                checkAnswer()
            }) {
                Text("Comprobar")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .padding(.horizontal)
    }
    
  
    func checkAnswer() {
        isCorrect = answer.trimmingCharacters(in: .whitespacesAndNewlines)
            .localizedCaseInsensitiveCompare(quiz.answer) == .orderedSame
        if isCorrect{
            scores.add(quizId: quiz.id)
        }
        showingAlert = true
    }
}
