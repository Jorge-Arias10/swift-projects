//
//  Endpoint.swift
//  Quiz1DaniJorge
//
//  Created by e004 DIT UPM on 10/12/25.
//

import Foundation


let URL_BASE = "https://quiz.dit.upm.es"

let token = "TU_TOKEN_AQUI"

struct Endpoints {
    static func random10() throws -> URL{
        let str="\(URL_BASE)/api/quizzes/random10?token=\(token)"
        guard let url = URL(string: str) else {
            throw QuizzesModelError.internalError(msg:"No puedo crear URL")
        }
        return url
    }

    static func check(quizId: Int, answer: String) throws -> URL {
        guard let answerQuery = answer.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed) else {
            throw QuizzesModelError.internalError(msg: "Query inválida")
        }
        let surl = "\(URL_BASE)/api/quizzes/\(quizId)/check?answer=\(answerQuery)&token=\(token)"
        guard let url = URL(string: surl) else {
            throw QuizzesModelError.internalError(msg: "URL incorrecto: \(surl)")
        }
        return url
    }
    
    static func answer(quizId: Int) throws -> URL {
        let surl = "\(URL_BASE)/api/quizzes/\(quizId)/answer?token=\(token)"
        
        guard let url = URL(string: surl) else {
            throw QuizzesModelError.internalError(msg: "URL incorrecto: \(surl)")
        }
        
    return url
    }
    
    static func favourite(quizId: Int) throws -> URL {
        
        let surl = "\(URL_BASE)/api/users/tokenOwner/favourites/\(quizId)?token=\(token)"
        
        guard let url = URL(string: surl) else {
            throw QuizzesModelError.internalError(msg: "URL incorrecto: \(surl)")
        }
        return url
        
    }
    
    // Marcar favorito
    static func favouriteURL(quizId: Int) throws -> URL {
        let surl = "\(URL_BASE)/api/users/tokenOwner/favourites/\(quizId)?token=\(token)"
        guard let url = URL(string: surl) else {
            throw QuizzesModelError.internalError(msg: "URL incorrecto: \(surl)")
        }
        return url
    }

    /// favorito
    static func favouritePUTRequest(quizId: Int) throws -> URLRequest {
        let url = try favouriteURL(quizId: quizId)
        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return req
    }
    /// Eliminar favorito
    static func favouriteDELETERequest(quizId: Int) throws -> URLRequest {
        let url = try favouriteURL(quizId: quizId)
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        return req
    }

    static func favouriteRequest(quizId: Int, shouldBeFavourite: Bool) throws -> URLRequest {
        return try (shouldBeFavourite ? favouritePUTRequest(quizId: quizId)
                                      : favouriteDELETERequest(quizId: quizId))
    }
}

