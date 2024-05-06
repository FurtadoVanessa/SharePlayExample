import Foundation
import UIKit
import GroupActivities

final class OrderTogetherViewController: UIViewController {
    
    private var customView: OrderTogetherViewProtocol
    private var orderTogetherModel: OrderTogetherModelProtocol
    
    init(
        orderTogetherModel: OrderTogetherModelProtocol,
        customView: OrderTogetherViewProtocol
    ) {
        self.orderTogetherModel = orderTogetherModel
        self.customView = customView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        isModalInPresentation = false
        view = customView as? UIView
    }
    
    override func viewDidLoad() {
        let shoppingBag = orderTogetherModel.getItems()
        customView.displayedCells = shoppingBag.items
        customView.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        edgesForExtendedLayout = .top
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupSharePlayCapability(ShoppingBag(id: "id", items: customView.displayedCells))
    }
    
    private func setupSharePlayCapability(_ shoppingBag: ShoppingBag) {
        let activity = OrderTogether(shoppingBag: shoppingBag)
        let itemProvider = NSItemProvider()
        itemProvider.registerGroupActivity(activity)
        let config = UIActivityItemsConfiguration(itemProviders: [itemProvider])
        config.previewProvider = { _, key, _ in
            if key == .fullSize {
                return itemProvider
            }
            return nil
        }
        config.perItemMetadataProvider = { _, key in
            if key == .title {
                return activity.metadata.title
            } else if key == .messageBody {
                return NSAttributedString(string: activity.metadata.subtitle ?? "")
            }
            return nil
        }
        activityItemsConfiguration = config
    }
}

extension OrderTogetherViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        customView.displayedCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellValue = customView.displayedCells[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = cellValue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
          customView.displayedCells.remove(at: indexPath.row)
          orderTogetherModel.deleteItem(at: indexPath.row)
          tableView.deleteRows(at: [indexPath], with: .fade)
      }
    }
}

extension OrderTogetherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let item = textField.text else { return false }
        let items = orderTogetherModel.addItem(item)
        customView.displayedCells = items
        textField.text = nil
        customView.tableView.reloadData()
        return false
    }
}

extension OrderTogetherViewController: OrderTogetherViewDelegate {
    func didTapSharePlay() {
        let activity = OrderTogether(shoppingBag: ShoppingBag(id: "id", items: customView.displayedCells))
        let itemProvider = NSItemProvider()
        itemProvider.registerGroupActivity(activity)
        
        let shareSheet = UIActivityViewController(activityItems: [itemProvider, "Order together with others"], applicationActivities: nil)
        shareSheet.allowsProminentActivity = true
        shareSheet.popoverPresentationController?.sourceView = view
                
        present(shareSheet, animated: true)
    }
}

extension OrderTogetherViewController: OrderTogetherModelDelegate {
    func didUpdateItems(_ items: [Item]) {
        DispatchQueue.main.async { [weak self] in
            self?.customView.displayedCells.append(contentsOf: items)
            self?.customView.tableView.reloadData()
        }
    }
}
