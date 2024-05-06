import Cartography
import Foundation
import UIKit

protocol OrderTogetherViewProtocol {
    func deleteRows(at indexPath: [IndexPath])
    
    var displayedCells: [String] { get set }
    var tableView: UITableView { get set }
    var delegate: OrderTogetherViewDelegate? { get }
}

protocol OrderTogetherViewDelegate: AnyObject {
    func didTapSharePlay()
}

final class OrderTogetherView: UIView, OrderTogetherViewProtocol {
    
    public lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8.0
        return stackView
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "shareplay"), for: .normal)
        button.addTarget(self, action: #selector(didTapSharePlay), for: .touchUpInside)
        return button
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .default
        textField.returnKeyType = .search
        textField.clearButtonMode = .always
        textField.enablesReturnKeyAutomatically = true
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.layer.cornerRadius = 6.0
        textField.placeholder = "Type here your item to be added"

        return textField
    }()
    
    public lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsSelection = true
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.estimatedSectionFooterHeight = 80
        tableView.layer.cornerRadius = 6.0
        tableView.backgroundColor = .white
        return tableView
    }()
    
    var displayedCells: [String] = []
    weak var delegate: OrderTogetherViewDelegate?
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)

        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        nil
    }
    
    func setupDelegatesAndDataSources(dataSourceDelegate: UITableViewDataSource & UITableViewDelegate, textFieldDelegate: UITextFieldDelegate?, delegate: OrderTogetherViewDelegate) {
        tableView.dataSource = dataSourceDelegate
        tableView.delegate = dataSourceDelegate
        textField.delegate = textFieldDelegate
        self.delegate = delegate
    }

    private func setup() {
        backgroundColor = .systemOrange
        stackView.addArrangedSubview(button)
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(tableView)
        
        addSubview(stackView)
        
        constrain(self, stackView) { superview, stackView in
            stackView.top == superview.safeAreaLayoutGuide.top
            stackView.leading == superview.leading + 20
            stackView.trailing == superview.trailing - 20
            stackView.bottom == superview.safeAreaLayoutGuide.bottom - 20
        }
    }
    
    @objc private func didTapSharePlay() {
        delegate?.didTapSharePlay()
    }
    
    func deleteRows(at indexPath: [IndexPath]) {
        displayedCells.remove(at: indexPath[0].row)
        tableView.reloadData()
    }
}
