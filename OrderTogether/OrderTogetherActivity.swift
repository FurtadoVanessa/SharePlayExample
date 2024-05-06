import GroupActivities
import UIKit
import Foundation

// The app's custom activity to be shared
struct OrderTogether: GroupActivity {
    // the necessary data so the activity works
    let shoppingBag: ShoppingBag
    // the fallback URL is used when a user doesn't have your app installed in systems where your app is not supported.
    var fallbackURL = "https://www.ifood.com.br"

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Order Together"
        metadata.previewImage = UIImage(named: "ifoodLogo")?.cgImage
        metadata.type = .generic
        metadata.fallbackURL = URL(string: fallbackURL)
        return metadata
    }
    
    init(shoppingBag: ShoppingBag) {
        self.shoppingBag = shoppingBag
    }
}
