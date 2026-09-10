import Foundation

@main
struct SaveJojoGameStateTests {
    static func main() {
        var game = SaveJojoGameState()
        precondition(game.phase == .onboarding)
        game.dismissOnboarding()
        precondition(game.phase == .aiming)
        precondition(game.throwLifebuoy(alignmentError: 0.05))
        precondition(game.phase == .caught)
        game.beginPulling()
        precondition(game.phase == .pulling)

        precondition(game.pull(at: 0.5))
        precondition(game.successfulPulls == 1)
        precondition(!game.pull(at: 0.1))
        precondition(game.lives == 2)
        precondition(game.pull(at: 0.5))
        precondition(game.pull(at: 0.5))
        precondition(game.phase == .won)

        game.restart()
        precondition(game.phase == .aiming && game.lives == 3)
        precondition(game.throwLifebuoy())
        game.beginPulling()
        precondition(!game.pull(at: 0.9))
        precondition(!game.pull(at: 0.9))
        precondition(!game.pull(at: 0.9))
        precondition(game.phase == .lost)

        game.restart()
        precondition(!game.throwLifebuoy(alignmentError: 0.3))
        precondition(game.phase == .aiming && game.lives == 2)

        game.restart()
        precondition(game.throwLifebuoy())
        game.beginPulling()
        game.failPullAttempt()
        precondition(game.phase == .pulling && game.lives == 2)
        game.beginRescueTransition()
        precondition(game.phase == .rescuing)
        game.completeRescue()
        precondition(game.phase == .won)

        game.restart()
        precondition(!game.throwLifebuoy(alignmentError: 0.3, deferLoss: true))
        precondition(!game.throwLifebuoy(alignmentError: 0.3, deferLoss: true))
        precondition(!game.throwLifebuoy(alignmentError: 0.3, deferLoss: true))
        precondition(game.phase == .aiming && game.lives == 0)
        game.finishFailedThrow()
        precondition(game.phase == .lost)

        print("Save Jojo game state tests passed")
    }
}
