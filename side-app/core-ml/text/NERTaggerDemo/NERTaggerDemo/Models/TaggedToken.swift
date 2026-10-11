import Foundation

struct TaggedToken: Identifiable {
    let id = UUID()
    let token: String
    /// Salah satu dari: O (bukan entitas), ORG, QTY, TIM, DAT, PER, EVT, FAC,
    /// GPE, PRD, PRC, MON, LOC, LAW, LAN.
    let tag: String

    var isEntity: Bool { tag != "O" }
}
