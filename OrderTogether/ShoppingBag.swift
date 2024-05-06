import Foundation
import GroupActivities
import UniformTypeIdentifiers
import CoreTransferable

struct ShoppingBag: Codable, Transferable {
    let id: String
    var items: [Item]
    
    public static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.id)
        
        GroupActivityTransferRepresentation { shoppingBag in
            OrderTogether(shoppingBag: shoppingBag)
        }
    }
}

typealias Item = String
