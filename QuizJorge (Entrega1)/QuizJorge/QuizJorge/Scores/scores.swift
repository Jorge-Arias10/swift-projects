//
//  scores.swift
//  Quiz1DaniJorge
//
//  Created by e004 DIT UPM on 9/12/25.
//


import Foundation

@Observable class Scores{
    private(set) var acertados: Set<Int> = []
    
    func add(quizId: Int){
        acertados.insert(quizId)
    }
    
    
}
