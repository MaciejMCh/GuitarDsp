//
//  DecadeViewController.swift
//  WaveMapCreator
//
//  Created by Maciej Chmielewski on 17.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

import Foundation
import UIKit

class DecadeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var windowHeightConstraint: NSLayoutConstraint!
    private var tableViews: [UITableView] = []
    private let tableViewLength = 1000
    private var cellHeight: CGFloat {
        return self.view.frame.height / 9
    }
    private var values: [Int: Int] = [:]
    
    private var powers: Range<Int>!
    private var initialValue: Double!
    private var update: ((Double) -> Void)?
    
    func setup(initialValue: Double, powers: Range<Int>, update: @escaping (Double) -> Void) {
        self.powers = powers
        self.initialValue = initialValue
        self.update = update
    }
    
    private func setValue(_ value: Double) {
        let digits: (Double, Range<Int>) -> [Int] = { (value, powers) in
            let intValue = pow(10, Double(-powers.lowerBound)) * value
            var stringValue = String(format: "%.0f", intValue)
            for _ in 0..<(powers.upperBound - powers.lowerBound) - stringValue.count {
                stringValue = "0" + stringValue
            }
            return stringValue.map{Int(String($0))!}
        }
        
        let newDigits = digits(value, powers)
        for i in 0..<tableViews.count {
            let tableView = tableViews[tableViews.count - i - 1]
            let digit = newDigits[i]
            tableView.scrollToRow(at: IndexPath(row: digit + (tableViewLength / 2) - 2, section: 0), at: .top, animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.transform = .init(scaleX: -1, y: 1)
        valueLabel.transform = .init(scaleX: -1, y: 1)
        
        windowHeightConstraint.constant = cellHeight + 10
        
        for i in powers.lowerBound..<powers.upperBound {
            values[i] = 0
            let tableView = UITableView()
            if i == 0 {
                tableView.backgroundColor = .gray
            }
            tableView.transform = .init(scaleX: -1, y: 1)
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            tableView.separatorInset = .zero
            tableView.separatorColor = .black
            tableView.delegate = self
            tableView.dataSource = self
            tableViews.append(tableView)
            tableView.scrollToRow(at: IndexPath(row: (tableViewLength / 2) - 2, section: 0), at: .top, animated: false)
            stackView.addArrangedSubview(tableView)
        }
        
        setValue(initialValue)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewLength
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UITableViewCell
        cell.textLabel?.text = String(valueForRow(indexPath.row))
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let tableView: UITableView = scrollView as! UITableView
        
        guard let indexPath = tableView.indexPathForRow(at: CGPoint(x: 0, y: scrollView.contentOffset.y + (cellHeight / 2))) else {return}
        picker(index: tableViews.index(of: tableView)!, focusedAt: (indexPath.row + 2) % 10)
    }
    
    private var lastChange: (pickerIndex: Int, row: Int) = (0, 0)
    func picker(index pickerIndex: Int, focusedAt row: Int) {
        if lastChange.pickerIndex == pickerIndex && lastChange.row == row {return}
        let currentState = (pickerIndex: pickerIndex, row: row)
        defer {
            lastChange = currentState
        }
        let newValue = currentValue()
        valueLabel.text = String(newValue)
        update?(newValue)
    }
    
    private func pickersConfiguration() -> [Int] {
        return tableViews.map{(($0.indexPathForRow(at: CGPoint(x: 0, y: $0.contentOffset.y + (cellHeight / 2)))?.row ?? 0) + 2) % 10}
    }
    
    private func valueForRow(_ row: Int) -> Int {
        return row % 10
    }
    
    private func rowForValue(_ value: Int) -> Int {
        return value
    }
    
    private func currentValue() -> Double {
        var result = 0.0
        var i = 0.0
        for digit in pickersConfiguration() {
            defer {
                i += 1
            }
            result += Double(digit) * pow(10, i)
        }
        return Double(result) * pow(10, Double(powers.lowerBound))
    }
    
}
