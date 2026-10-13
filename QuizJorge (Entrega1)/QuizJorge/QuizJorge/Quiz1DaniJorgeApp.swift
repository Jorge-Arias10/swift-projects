//
//  Quiz1DaniJorgeApp.swift
//  Quiz1DaniJorge
//
//  Created by e004 DIT UPM on 13/11/25.
//

import SwiftUI

@main
struct Quiz1DaniJorgeApp: App {
    
    @State var quizzesModel = QuizzesModel()
    @State var scores = Scores()

    
    var body: some Scene {
        WindowGroup {
            QuizzesView()
                .environment(quizzesModel)
                .environment(scores)

        }
    }
}
