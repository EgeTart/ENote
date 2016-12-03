//
//  StatisticsViewController.swift
//  ENote
//
//  Created by min-mac on 16/12/2.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

import UIKit
import Charts

enum DisplayModel {
    case Day
    case Week
    case Month
}

class StatisticsViewController: UIViewController {

    @IBOutlet weak var barChartView: CombinedChartView!
    
    @IBOutlet weak var modelSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var beginTimeButton: UIButton!
    @IBOutlet weak var endTimeButton: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerBottomConstraint: NSLayoutConstraint!
    
    let databaseManager = DatabaseManager.sharedManager
    
    var notesStatistics: [DailyNotesStatistics]!
    
    var timeLabels: [String]!
    var finishedStates: [Double]!
    var unfinishedStates: [Double]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePickerBottomConstraint.constant = -220.0
        datePicker.maximumDate = Date(timeInterval: -24 * 60 * 60 * 1.0, since: Date())
        
        let beginTime = Date(timeInterval: -24 * 60 * 60 * 9.0, since: Date())
        let endTime = Date(timeInterval: -24 * 60 * 60 * 2.0, since: Date())
        
        notesStatistics = databaseManager.historyDataStatistics(beginTime: beginTime, endTime: endTime)
        
        timeLabels = notesStatistics.map({ (statistics: DailyNotesStatistics) -> String in
            let index = statistics.date.index(statistics.date.startIndex, offsetBy: 5)
            return statistics.date.substring(from: index)
        })
        
        finishedStates = notesStatistics.map({ (statistics: DailyNotesStatistics) -> Double in
            return Double(statistics.finishedCount)
        })
        
        unfinishedStates = notesStatistics.map({ (statistics: DailyNotesStatistics) -> Double in
            return Double(statistics.unfinishedCount)
        })

        setChart()
    }
    
    func generateBarChartData() -> BarChartData {
        
        var finishedEntries = [BarChartDataEntry]()
        var unfinishedEntries = [BarChartDataEntry]()
        
        for i in 0..<timeLabels.count {
            let finishedEntry = BarChartDataEntry(x: Double(i), y: finishedStates[i])
            let unfinishedEntry = BarChartDataEntry(x: Double(i), y: unfinishedStates[i])
            
            finishedEntries.append(finishedEntry)
            unfinishedEntries.append(unfinishedEntry)
        }
        
        let valueFormatter = NumberFormatter()
        valueFormatter.maximumFractionDigits = 0
        let chartValueFormatter = DefaultValueFormatter(formatter: valueFormatter)
        
        let finishedDataSet = BarChartDataSet(values: finishedEntries, label: "完成")
        finishedDataSet.colors = [UIColor(red: 103.0 / 255.0, green: 195.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)]
        finishedDataSet.axisDependency = .left
        finishedDataSet.valueFormatter = chartValueFormatter
        finishedDataSet.drawValuesEnabled = false
        
        let unfinishedDataSet = BarChartDataSet(values: unfinishedEntries, label: "未完成")
        unfinishedDataSet.colors = [UIColor(red: 255.0 / 255.0, green: 210.0 / 255.0, blue: 70.0 / 255.0, alpha: 1.0)]
        unfinishedDataSet.axisDependency = .left
        unfinishedDataSet.valueFormatter = chartValueFormatter
        unfinishedDataSet.drawValuesEnabled = false
        
        let barChartData = BarChartData(dataSets: [finishedDataSet, unfinishedDataSet])
        barChartData.barWidth = 0.45
        barChartData.groupBars(fromX: 0.0, groupSpace: 0.12, barSpace: 0.0)
        
        return barChartData
    }
    
    func generateLineChartData() -> LineChartData {
        
        let lineChartData = LineChartData()
        
        var finishedEntries = [ChartDataEntry]()
        var unfinishedEntries = [ChartDataEntry]()
        
        for i in 0..<finishedStates.count {
            let finishedEntry = ChartDataEntry(x: Double(i), y: finishedStates[i])
            let unfinishedEntry = ChartDataEntry(x: Double(i), y: unfinishedStates[i])
            
            finishedEntries.append(finishedEntry)
            unfinishedEntries.append(unfinishedEntry)
        }
        
        let finishedChartDataSet = LineChartDataSet(values: finishedEntries, label: "完成")
        let unfinishedChartDataSet = LineChartDataSet(values: unfinishedEntries, label: "未完成")
        
        let finishedLineColor = UIColor(red: 240.0 / 255.0, green: 238.0 / 255.0, blue: 70.0 / 255.0, alpha: 1.0)
        let unfinishedLineColor = UIColor(red: 197.0 / 255.0, green: 124.0 / 255.0, blue: 196.0 / 255.0, alpha: 1.0)
        
        configureLineDataSet(dataSet: finishedChartDataSet, color: finishedLineColor)
        configureLineDataSet(dataSet: unfinishedChartDataSet, color: unfinishedLineColor)
        
        lineChartData.addDataSet(finishedChartDataSet)
        lineChartData.addDataSet(unfinishedChartDataSet)
        
        return lineChartData
    }
    
    func configureLineDataSet(dataSet: LineChartDataSet, color: UIColor) {
        dataSet.colors = [color]
        dataSet.lineWidth = 2.5
        dataSet.circleColors = [color]
        dataSet.circleRadius = 3.0
        dataSet.fillColor = color
        dataSet.mode = .linear
        dataSet.drawValuesEnabled = true
        //dataSet.axisDependency = .left
        dataSet.drawValuesEnabled = false
    }

    func setChart() {
        
        let barChartData = generateBarChartData()
        //let lineChartData = generateLineChartData()
        
        let combinedChartData = CombinedChartData()
        combinedChartData.barData = barChartData
        //combinedChartData.lineData = lineChartData
        
        barChartView.data = combinedChartData
        
        barChartView.chartDescription?.text = ""
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.valueFormatter = self
        barChartView.xAxis.drawGridLinesEnabled = false
        
        barChartView.rightAxis.enabled = false
        
        barChartView.leftAxis.forceLabelsEnabled = true
        barChartView.leftAxis.axisMinimum = 0
        
        let maxCount = max(finishedStates.max() ?? 0.0, unfinishedStates.max() ?? 0.0)
        barChartView.leftAxis.axisMaximum = maxCount
        barChartView.leftAxis.labelCount = Int(maxCount)
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.maximumFractionDigits = 0
        barChartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        
        barChartView.xAxis.forceLabelsEnabled = true
        barChartView.xAxis.axisMinimum = 0
        barChartView.xAxis.axisMaximum = Double(timeLabels.count) + 0.5
        barChartView.xAxis.labelCount = timeLabels.count
        
        barChartView.scaleYEnabled = false
        barChartView.xAxis.wordWrapEnabled = true
        barChartView.xAxis.granularity = 1.0
        barChartView.highlightFullBarEnabled = false
        barChartView.xAxis.centerAxisLabelsEnabled = true
        
        barChartView.animate(yAxisDuration: 2.5)
    }
    
    func setDatePickerButtonConstraint(constraint: CGFloat) {
        datePickerBottomConstraint.constant = constraint
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    
    // MARK: - IBAction
    
    @IBAction func selectDisplayModel(_ sender: UISegmentedControl) {
    }
    
    @IBAction func selectTime(_ sender: UIButton) {
        setDatePickerButtonConstraint(constraint: 20.0)
    }
    
    @IBAction func conform(_ sender: UIButton) {
        setDatePickerButtonConstraint(constraint: -220.0)
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        setDatePickerButtonConstraint(constraint: -220.0)
    }
}


// MARK: - IAxisValueFormatter 协议
extension StatisticsViewController: IAxisValueFormatter {
    
    // 控制x轴的显示
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        var labelIndex = Int(value) % timeLabels.count
        
        if labelIndex == 0 && value > 0 {
            return ""
        }
        
        if labelIndex < 0 {
            labelIndex = 0
        }

        return timeLabels[labelIndex]
    }
}
