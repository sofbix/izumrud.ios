//
//  StatisticsViewController.swift
//  Izumrud
//
//  Created by Sergey Balalaev on 07.05.2023.
//  Copyright © 2023 Byterix. All rights reserved.
//

import Foundation
import BxInputController
import Charts

class StatisticsViewController: BxInputController, ChartViewDelegate {

    @IBOutlet var electricChartView: CombinedChartView!

    var chartView: CombinedChartView! {
        electricChartView
    }

    var firstColor: UIColor {
        .blue
    }

    var secondColor: UIColor {
        .red
    }

    var firstBarColor: UIColor {
        .blue.withAlphaComponent(0.5)
    }

    var secondBarColor: UIColor {
        .red.withAlphaComponent(0.5)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        //isEstimatedContent = false

        chartView.delegate = self
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true

        let l = chartView.legend
        l.form = .line
        l.font = .systemFont(ofSize: 14)
        l.textColor = UIColor.gray
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false

        let xAxis = chartView.xAxis
        xAxis.labelFont = .systemFont(ofSize: 16)
        xAxis.labelTextColor = UIColor.gray
        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = false
        xAxis.valueFormatter = self


        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 14)
        leftAxis.labelTextColor = Settings.Color.brand
        leftAxis.axisMinimum = 0
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = true
        leftAxis.valueFormatter = self

        let rightAxis = chartView.rightAxis
        rightAxis.labelFont = .systemFont(ofSize: 14)
        rightAxis.labelTextColor = Settings.Color.secondAccent
        rightAxis.axisMinimum = 0
        rightAxis.drawGridLinesEnabled = true
        rightAxis.granularityEnabled = true
        rightAxis.valueFormatter = self

        updateData()

    }

    private func updateData() {
        let lineCharts : [LineChartDataSet] = electricLines()

        let lineChart = LineChartData(dataSets: lineCharts)
        lineChart.setValueTextColor(.gray)
        lineChart.setValueFont(.systemFont(ofSize: 14))

        let barChart = BarChartData(dataSets: electricBars())
        //barChart.setValueTextColor(.gray)
        //barChart.setValueFont(.systemFont(ofSize: 14))
        barChart.barWidth = 2000000

        let combineData = CombinedChartData()
        combineData.lineData = lineChart
        combineData.barData = barChart

        chartView.data = combineData

        sections = [
            BxInputSection(headerText: "Электрический счётчик:", rows: []),
            BxInputSection(headerView: electricChartView, rows: [])
        ]
    }

    private func electricLines() -> [LineChartDataSet]
    {
        let flatEntities = DatabaseManager.shared.commonRealm.objects(FlatEntity.self).filter("sentDate != nil").sorted(byKeyPath: "sentDate")

        var dayElectricCountData: [ChartDataEntry] = []
        var nightElectricCountData: [ChartDataEntry] = []
        var totalY = 0.0
        for entities in flatEntities {
            let x = entities.sentDate?.timeIntervalSinceReferenceDate ?? Settings.startCompanyDate.timeIntervalSinceReferenceDate
            //let y =
            //totalY = totalY + Double(y)
            dayElectricCountData.append(ChartDataEntry(x: Double(x), y: Double(entities.dayElectricCount) ?? 0.0))
            nightElectricCountData.append(ChartDataEntry(x: Double(x), y: Double(entities.nightElectricCount) ?? 0.0))
        }

        let dayElectricCountSet = LineChartDataSet(entries: dayElectricCountData, label: "Общее дневное потребление")
        dayElectricCountSet.axisDependency = .left
        dayElectricCountSet.setColor(firstColor)
        dayElectricCountSet.setCircleColor(firstColor)
        dayElectricCountSet.lineWidth = 2
        dayElectricCountSet.circleRadius = 3
        dayElectricCountSet.fillAlpha = 65/255
        dayElectricCountSet.fillColor = firstColor
        dayElectricCountSet.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        dayElectricCountSet.drawCircleHoleEnabled = false
        dayElectricCountSet.drawValuesEnabled = false
        dayElectricCountSet.mode = .horizontalBezier
        dayElectricCountSet.valueTextColor = Settings.Color.brand

        let nightElectricCountSet = LineChartDataSet(entries: nightElectricCountData, label: "Общее ночное потребление")
        nightElectricCountSet.axisDependency = .left
        nightElectricCountSet.setColor(secondColor)
        nightElectricCountSet.setCircleColor(secondColor)
        nightElectricCountSet.lineWidth = 2
        nightElectricCountSet.circleRadius = 3
        nightElectricCountSet.fillAlpha = 65/255
        nightElectricCountSet.fillColor = secondColor
        nightElectricCountSet.highlightColor = Settings.Color.secondAccent
        nightElectricCountSet.drawCircleHoleEnabled = false
        nightElectricCountSet.drawValuesEnabled = false
        nightElectricCountSet.mode = .horizontalBezier
        nightElectricCountSet.valueTextColor = Settings.Color.brand

        return [dayElectricCountSet, nightElectricCountSet]
    }

    private func electricBars() -> [BarChartDataSet]
    {
        let flatEntities = DatabaseManager.shared.commonRealm.objects(FlatEntity.self).filter("sentDate != nil").sorted(byKeyPath: "sentDate")

        var allCountData: [BarChartDataEntry] = []

        var dayElectricCountData: [BarChartDataEntry] = []
        var nightElectricCountData: [BarChartDataEntry] = []

        var lastDayElectricCount: Double = 0.0
        var lastNightElectricCount: Double = 0.0

        for entity in flatEntities {
            let x = entity.sentDate?.timeIntervalSinceReferenceDate ?? Settings.startCompanyDate.timeIntervalSinceReferenceDate
            let dayElectricCount = Double(entity.dayElectricCount) ?? 0.0
            let nightElectricCount = Double(entity.nightElectricCount) ?? 0.0

            dayElectricCountData.append(BarChartDataEntry(x: Double(x), y: dayElectricCount - lastDayElectricCount))
            nightElectricCountData.append(BarChartDataEntry(x: Double(x), y: nightElectricCount - lastNightElectricCount))


            allCountData.append(BarChartDataEntry(x: Double(x), yValues: [nightElectricCount - lastNightElectricCount, dayElectricCount - lastDayElectricCount]))

            lastDayElectricCount = dayElectricCount
            lastNightElectricCount = nightElectricCount
        }

//        let dayElectricCountSet = BarChartDataSet(entries: dayElectricCountData, label: "Дневное потребление")
//        dayElectricCountSet.axisDependency = .right
//        dayElectricCountSet.setColor(dayColor)
//        dayElectricCountSet.stackLabels = ["day"]
//        dayElectricCountSet.colors = [ dayColor ]
//        dayElectricCountSet.valueTextColor = UIColor(red: 61/255, green: 165/255, blue: 255/255, alpha: 1)
//        //dayElectricCountSet.valueFont = Settings.Font.chartLabel
//
//
//        let nightElectricCountSet = BarChartDataSet(entries: nightElectricCountData, label: "Ночное потребление")
//        nightElectricCountSet.axisDependency = .right
//        nightElectricCountSet.setColor(nightColor)
//        dayElectricCountSet.stackLabels = ["night"]
//        dayElectricCountSet.colors = [ nightColor ]
//        dayElectricCountSet.valueTextColor = UIColor(red: 61/255, green: 165/255, blue: 255/255, alpha: 1)
//
//        return [dayElectricCountSet, nightElectricCountSet]

        let allCountSet = BarChartDataSet(entries: allCountData, label: "")
        allCountSet.axisDependency = .right
        allCountSet.stackLabels = ["Частота ночного потребления", "Частота дневного потребления"]
        allCountSet.colors = [secondBarColor, firstBarColor]
        allCountSet.valueTextColor = Settings.Color.secondAccent
        return [allCountSet]
    }


}

extension StatisticsViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if axis == chartView.xAxis {
            return Settings.shortDateFormatter.string(from: Date(timeIntervalSinceReferenceDate: value))
        } else if axis == chartView.leftAxis {
            return String(value)
        } else {
            return String(value)
        }
    }
}
