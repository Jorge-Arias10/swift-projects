import Foundation
import SwiftUI

@Observable
class Scores {

    private let userDefaultsKey = "totalQuizzesAcertados"

    private(set) var acertados: Set<Int> = []

    private(set) var totalAcertados: Set<Int>

    init() {
        if let saved = UserDefaults.standard.array(forKey: userDefaultsKey) as? [Int] {
            totalAcertados = Set(saved)
        } else {
            totalAcertados = []
        }
    }

    func add(quizId: Int) {
        acertados.insert(quizId)

        if totalAcertados.insert(quizId).inserted {
            save()
        }
    }

    private func save() {
        UserDefaults.standard.set(
            Array(totalAcertados),
            forKey: userDefaultsKey
        )
    }
}
