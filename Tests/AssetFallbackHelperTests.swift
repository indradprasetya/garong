import Foundation

@main
struct AssetFallbackHelperTests {
    static func main() {
        let actions = [
            "action_apologize",
            "action_approach",
            "action_ask_quiet",
            "action_asking",
            "action_attention_reset",
            "action_blaming",
            "action_candy",
            "action_crayon",
            "action_give_bandage",
            "action_lecture",
            "action_paper",
            "action_toy"
        ]

        precondition(actions.allSatisfy { AssetFallbackHelper.actionImageName(for: $0) == $0 })
        precondition(AssetFallbackHelper.actionImageName(for: "action_lollipop") == "action_candy")
        precondition(AssetFallbackHelper.imageName(for: "jojo_happy") == "jojo_happy")
        precondition(AssetFallbackHelper.imageName(for: "jojo_unknown_emotion") == "jojo_happy")
        precondition(AssetFallbackHelper.imageName(for: "rhodey_calm") == "rhodey_calm")
        precondition(AssetFallbackHelper.imageName(for: "rhodey_unknown_emotion") == "rhodey_happy")
        precondition(AssetFallbackHelper.imageName(for: "unknown") == "fallback_globe")
        precondition(AssetFallbackHelper.backgroundImageName(for: "background_classroom") == "classroom_background")
        precondition(AssetFallbackHelper.hasAsset(named: "rhodey_happy"))
        precondition(AssetFallbackHelper.hasAsset(named: "jojo_happy"))
        precondition(AssetFallbackHelper.hasAsset(named: "action_toy"))
        precondition(AssetFallbackHelper.hasAsset(named: "gameplay_background"))
        precondition(AssetFallbackHelper.hasAsset(named: "container"))
        precondition(AssetFallbackHelper.hasAsset(named: "container_drag"))
        precondition(AssetFallbackHelper.hasAsset(named: "container_lock"))
        precondition(AssetFallbackHelper.hasAsset(named: "blue_selector_full"))
        precondition(AssetFallbackHelper.hasAsset(named: "blue_selector_half"))
        precondition(AssetFallbackHelper.hasAsset(named: "green_selector_full"))
        precondition(AssetFallbackHelper.hasAsset(named: "green_selector_half"))
        precondition(AssetFallbackHelper.hasAsset(named: "bubble_respond"))
        precondition(!AssetFallbackHelper.hasAsset(named: "non_existent_asset"))

        print("AssetFallbackHelperTests passed")
    }
}
