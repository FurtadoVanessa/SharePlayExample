import Combine
import UIKit
import Foundation
import GroupActivities

protocol OrderTogetherModelProtocol {
    func getItems() -> ShoppingBag
    func deleteItem(at index: Int)
    func addItem(_ item: String) -> [Item]
}

protocol OrderTogetherModelDelegate: AnyObject {
    func didUpdateItems(_ items: [Item])
}

final class OrderTogetherModel: OrderTogetherModelProtocol {
    private var shoppingBag: ShoppingBag
    private var groupSession: GroupSession<OrderTogether>?
    private var messenger: GroupSessionMessenger?
    private var subscriptions = Set<AnyCancellable>()
    private var tasks = Set<Task<Void, Never>>()
    weak var delegate: OrderTogetherModelDelegate?
    
    init(shoppingBag: ShoppingBag) {
        self.shoppingBag = shoppingBag
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: UIApplication.willTerminateNotification, object: .none)
        manageSessions()
    }
    
    @objc private func appWillTerminate() {
        messenger = nil
        tasks.forEach { $0.cancel() }
        tasks = []
        subscriptions = []
        if let participants = groupSession?.activeParticipants.count, participants <= 2 {
            groupSession?.end()
        }
        if groupSession != nil {
            groupSession?.leave()
            groupSession = nil
        }
    }
    
    func getItems() -> ShoppingBag {
        shoppingBag
    }
    
    func deleteItem(at index: Int) {
        shoppingBag.items.remove(at: index)
        
        Task {
            do {
                let message = RemoveItem(itemIndex: index)
                try await messenger?.send(message)
            } catch {
                print("[SharePlay] Failed to send remove item message")
            }
        }
    }
    
    func addItem(_ item: String) -> [Item] {
        shoppingBag.items.append(item)
        
        Task {
            do {
                let message = ShareItems(items: [item])
                try await messenger?.send(message)
            } catch {
                print("[SharePlay] Failed to send share items message")
            }
        }
        
        return shoppingBag.items
    }
    
    func addItems(_ items: [Item]) {
        shoppingBag.items.append(contentsOf: items)
        delegate?.didUpdateItems(items)
    }
    
    private func manageSessions() {
        Task {
          // an observer to listen to new sessions
            for await groupSession in OrderTogether.sessions() {
                self.groupSession = groupSession
                let sessionMessenger = GroupSessionMessenger(session: groupSession)
                self.messenger = sessionMessenger

                let task = Task {
                  for await (message, _) in sessionMessenger.messages(of: ShareItems.self) {
                      self.addItems(message.items)
                  }
                }
                
                let task1 = Task {
                  for await (message, _) in sessionMessenger.messages(of: RemoveItem.self) {
                      self.deleteItem(at: message.itemIndex)
                  }
                }
                
                tasks.insert(task)
                tasks.insert(task1)
                
                groupSession.$activeParticipants
                    .sink { [weak self] activeParticipants in
                        guard let self = self else { return }
                        let newParticipants = activeParticipants.subtracting(groupSession.activeParticipants)

                        Task {
                            let message = ShareItems(items: self.shoppingBag.items)
                            try? await sessionMessenger.send(message, to: .only(newParticipants))
                        }
                    }
                    .store(in: &subscriptions)
                groupSession.join()
            }
         }
    }
}


