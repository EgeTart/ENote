//
//  StatisticsViewController.swift
//  ENote
//
//  Created by min-mac on 16/12/2.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

import UIKit
import Charts

class StatisticsViewController: UIViewController {

    @IBOutlet weak var barChartView: BarChartView!
    
    let databaseManager = DatabaseManager.sharedManager
    
    var notesStatistics: [DailyNotesStatistics]!
    
    var timeLabels: [String]!
    var finishedStates: [Double]!
    var unfinishedStates: [Double]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setChart()
    }
    
    func generateChartData() -> BarChartData {
        
        let beginTime = Date(timeInterval: -24 * 60 * 60 * 12.0, since: Date())
        let endTime = Date(timeInterval: -24 * 60 * 60 * 2.0, since: Date())
        
        notesStatistics = databaseManager.historyDataStatistics(beginTime: beginTime, endTime: endTime)
        
        timeLabels = notesStatistics.map({ (statistics: DailyNotesStatistics) -> String in
            return statistics.date
        })
        
        finishedStates = notesStatistics.map({ (statistics: DailyNotesStatistics) -> Double in
            return Double(statistics.finishedCount)
        })
        
        unfinishedStates = notesStatistics.map({ (statistics: DailyNotesStatistics) -> Double in
            return Double(statistics.unfinishedCount)
        })
        
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
        finishedDataSet.colors = [UIColor(red: 42.0 / 255.0, green: 133.0 / 255.0, blue: 211.0 / 255.0, alpha: 1.0)]
        finishedDataSet.axisDependency = .left
        finishedDataSet.valueFormatter = chartValueFormatter
        
        let unfinishedDataSet = BarChartDataSet(values: unfinishedEntries, label: "未完成")
        unfinishedDataSet.colors = [UIColor(red: 237.0 / 255.0, green: 186.0 / 255.0, blue: 17.0 / 255.0, alpha: 1.0)]
        unfinishedDataSet.axisDependency = .left
        unfinishedDataSet.valueFormatter = chartValueFormatter
        
        
        let chartData = BarChartData(dataSets: [finishedDataSet, unfinishedDataSet])
        chartData.barWidth = 0.45
        chartData.groupBars(fromX: -0.2, groupSpace: 0.1, barSpace: 0.05)
        
        return chartData
    }

    func setChart() {
        
        let chartData = generateChartData()
        barChartView.data = chartData
        
        barChartView.chartDescription?.text = ""
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.valueFormatter = self
        barChartView.xAxis.drawGridLinesEnabled = false
        
        barChartView.rightAxis.enabled = false
        
        barChartView.leftAxis.forceLabelsEnabled = true
        barChartView.leftAxis.axisMinimum = 0
        barChartView.leftAxis.axisMaximum = 10
        barChartView.leftAxis.labelCount = 10
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.maximumFractionDigits = 0
        barChartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        
    
        barChartView.scaleYEnabled = false
    }
    
}


extension StatisticsViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return timeLabels[Int(value)]
    }
}
