//
//  QuizPlayView.swift
//  Quiz1DaniJorge
//
//  Created by e004 DIT UPM on 26/11/25.
//

import SwiftUI

struct QuizPlayView: View {
    var quizId: Int
    @Environment(QuizzesModel.self) var model
    
    // Variables de estado
    @State private var answer: String = ""
    @State private var showingAlert = false
    @State private var isCorrect = false
    @State private var errorText: String? = nil
    @Environment(Scores.self) var scores
    @State private var animateAnswerFill = false

    
    private var quiz: QuizItem {
        model.quizzes.first(where: { $0.id == quizId }) ?? QuizItem(id: quizId, question: "", author: nil, attachment: nil, favourite: false)
    }
    
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
        
        .alert(isPresented: $showingAlert) {
            if let errorText {
                return Alert(title: Text("Error"), message: Text(errorText), dismissButton: .default(Text("OK"), action: { self.errorText = nil }))
            } else {
                return Alert(title: Text(isCorrect ? "¡Felicidades!" : "¡Oooh, lo siento!"), message: Text(isCorrect ? "¡Has acertado la pregunta! Continua con la siguiente." : "Has fallado la pregunta... Inténtalo de nuevo."), dismissButton: .default(Text("OK")))
            }
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

                Button {
                    Task {
                        await toggleFavourite()
                    }
                } label: {
                    Image(systemName: quiz.favourite ? "star.fill" : "star")
                        .foregroundColor(quiz.favourite ? .yellow : .gray)
                        .font(.title)
                }
                .buttonStyle(.plain)
            }
            .padding(.top)

            HStack(spacing: 6) {
                Text(quiz.author?.username ??
                     quiz.author?.profileName ??
                     "Anónimo")
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
                .contextMenu {

                    Button {
                        answer = ""
                    } label: {
                        Label("Limpiar respuesta", systemImage: "trash")
                    }

                    Button {
                        Task {
                            await fillWithCorrectAnswer()
                        }
                    } label: {
                        Label("Mostrar respuesta", systemImage: "checkmark.circle")
                    }
                }
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
            .scaleEffect(animateAnswerFill ? 1.05 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.6), value: animateAnswerFill)
            .onTapGesture(count: 2) {
                Task {
                    await fillWithCorrectAnswerAnimated()
                }
            }
    }
    func fillWithCorrectAnswerAnimated() async {
        do {
            let correctAnswer = try await model.getAnswer(quizId: quiz.id)

            await MainActor.run {
                withAnimation {
                    animateAnswerFill = true
                    answer = correctAnswer
                }
            }

            // Volvemos al estado normal tras un breve delay
            try? await Task.sleep(nanoseconds: 400_000_000)

            await MainActor.run {
                withAnimation {
                    animateAnswerFill = false
                }
            }

        } catch {
            await MainActor.run {
                errorText = "Error al obtener la respuesta: \(error.localizedDescription)"
                showingAlert = true
            }
        }
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
                    Task {
                        await checkAnswer()
                    }

                }
            
            Button(action: {
                Task {
                    await checkAnswer()
                }   

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
    
  
    func checkAnswer() async {
        do{
            isCorrect = try await model.check(quizId: quiz.id, answer: answer)
        
            if isCorrect{
                scores.add(quizId: quiz.id)
            }
            showingAlert = true
        } catch {
            errorText = "Error al comprobar la respuesta: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    
    private func toggleFavourite() async {
        let desired = !quiz.favourite
        do {
            let result = try await model.setFavourite(quizId: quiz.id, to: desired)
            if result != desired {
                await MainActor.run {
                    self.errorText = "No se pudo actualizar el favorito en el servidor."
                    self.showingAlert = true
                }
            }
        } catch {
            await MainActor.run {
                self.errorText = "Error al actualizar favorito: \(error.localizedDescription)"
                self.showingAlert = true
            }
        }
    }
        func fillWithCorrectAnswer() async {
            do {
                let correctAnswer = try await model.getAnswer(quizId: quiz.id)
                await MainActor.run {
                    self.answer = correctAnswer
                }
            } catch {
                await MainActor.run {
                    self.errorText = "Error al obtener la respuesta: \(error.localizedDescription)"
                    self.showingAlert = true
                }
            }
        }

}

