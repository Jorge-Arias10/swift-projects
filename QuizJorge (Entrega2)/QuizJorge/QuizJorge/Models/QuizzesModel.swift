//
//  QuizzesModel.swift
//  Quiz
//
//  Created by Santiago Pavón Gómez on 18/10/24.
//


import Foundation
import SwiftUI


enum QuizzesModelError: LocalizedError {
    case internalError(msg: String)
    case corruptedDataError
    case unknownError

    var errorDescription: String? {
        switch self {
        case .internalError(let msg):
            return "Error interno: \(msg)"
        case .corruptedDataError:
            return "Recibidos datos corruptos"
        case .unknownError:
            return "No chungo ha pasado"
       }
    }
}

@Observable class QuizzesModel {
    
    // Los datos
    private(set) var quizzes = [QuizItem]()
    
    
    func load() {
        do {
            guard let jsonURL = Bundle.main.url(forResource: "quizzes", withExtension: "json") else {
                throw QuizzesModelError.internalError(msg: "No encuentro quizzes.json")
            }
            
            let data = try Data(contentsOf: jsonURL)
            
            guard let quizzes = try? JSONDecoder().decode([QuizItem].self, from: data)  else {
                throw QuizzesModelError.corruptedDataError
            }
            
            self.quizzes = quizzes
            
            print("Quizzes cargados")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func download() async throws {
        do {
            let url = try Endpoints.random10()
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw QuizzesModelError.internalError(msg: "Recibido un código distinto de 200")
            }
            
            //No utilizamos el json en esta práctica
            //guard let jsonURL = Bundle.main.url(forResource: "quizzes", withExtension: "json") else {
               // throw QuizzesModelError.internalError(msg: "No encuentro quizzes.json")
            //}
            
            guard let quizzes = try? JSONDecoder().decode([QuizItem].self, from: data)  else {
                throw QuizzesModelError.corruptedDataError
            }
            
            self.quizzes = quizzes
            
            print("Quizzes cargados")
        }
    }

    func check(quizId: Int, answer: String) async throws -> Bool {

        let escapedAnswer = answer.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? ""

        let url = try Endpoints.check(
            quizId: quizId,
            answer: escapedAnswer
        )

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw QuizzesModelError.internalError(msg: "Código HTTP incorrecto")
        }

        struct CheckResponse: Codable {
            let quizId: Int
            let answer: String
            let result: Bool
        }

        let decoded = try JSONDecoder().decode(CheckResponse.self, from: data)
        return decoded.result
    }

    struct FavouriteServerResponse: Decodable {
        let id: Int
        let favourite: Bool
    }

    func setFavourite(quizId: Int, to newValue: Bool) async throws -> Bool {
        let request = try Endpoints.favouriteRequest(quizId: quizId, shouldBeFavourite: newValue)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw QuizzesModelError.internalError(msg: "Código HTTP incorrecto al actualizar favorito")
        }
        let decoded = try JSONDecoder().decode(FavouriteServerResponse.self, from: data)
        
        if let idx = self.quizzes.firstIndex(where: { $0.id == decoded.id }) {
            var item = self.quizzes[idx]
            
            let updated = QuizItem(id: item.id,
                                   question: item.question,
                                   author: item.author,
                                   attachment: item.attachment,
                                   favourite: decoded.favourite)
            self.quizzes[idx] = updated
        }
        return decoded.favourite
    }
    func getAnswer(quizId: Int) async throws -> String {
        let url = try Endpoints.answer(quizId: quizId)
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw QuizzesModelError.internalError(msg: "Código HTTP incorrecto al obtener respuesta")
        }
        
        struct AnswerResponse: Decodable {
            let quizId: Int
            let answer: String
        }
        
        let decoded = try JSONDecoder().decode(AnswerResponse.self, from: data)
        return decoded.answer
    }


}
