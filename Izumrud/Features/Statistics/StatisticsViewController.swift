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

    @IBOutlet var waterChartView: CombinedChartView!


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

    func updateChart(_ chartView: CombinedChartView) {
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
        xAxis.labelFont = .systemFont(ofSize: 14)
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //isEstimatedContent = false

        updateChart(electricChartView)
        updateChart(waterChartView)

        updateData()

    }

    private func updateData() {

        updateData(electricChartView, lines: electricLines(), bars: electricBars())

        updateData(waterChartView, lines: waterLines(), bars: waterBars())

        sections = [
            BxInputSection(headerText: "Электрический счётчик:", rows: []),
            BxInputSection(headerView: electricChartView, rows: []),
            BxInputSection(headerText: "Водные счётчики:", rows: []),
            BxInputSection(headerView: waterChartView, rows: [])
        ]
    }

    private func updateData(_ chartView: CombinedChartView, lines: [LineChartDataSet], bars: [BarChartDataSet]) {
        let lineChart = LineChartData(dataSets: lines)
        lineChart.setValueFont(.systemFont(ofSize: 10))

        let barChart = BarChartData(dataSets: bars)
        barChart.setValueFont(.systemFont(ofSize: 10))
        barChart.barWidth = 2000000 //  magic number ~ half month in second

        let combineData = CombinedChartData()
        combineData.lineData = lineChart
        combineData.barData = barChart

        chartView.data = combineData
    }

    private func electricLines() -> [LineChartDataSet]
    {
        let flatEntities = DatabaseManager.shared.commonRealm.objects(FlatEntity.self).filter("sentDate != nil").sorted(byKeyPath: "sentDate")

        var dayElectricCountData: [ChartDataEntry] = []
        var nightElectricCountData: [ChartDataEntry] = []
        for entities in flatEntities {
            let x = entities.sentDate?.timeIntervalSinceReferenceDate ?? Settings.startCompanyDate.timeIntervalSinceReferenceDate
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
        dayElectricCountSet.highlightColor = Settings.Color.brand
        dayElectricCountSet.drawCircleHoleEnabled = false
        dayElectricCountSet.drawValuesEnabled = true
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
        nightElectricCountSet.highlightColor = Settings.Color.brand
        nightElectricCountSet.drawCircleHoleEnabled = false
        nightElectricCountSet.drawValuesEnabled = true
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

        let allCountSet = BarChartDataSet(entries: allCountData, label: "")
        allCountSet.axisDependency = .right
        allCountSet.stackLabels = ["Частота ночного потребления", "Частота дневного потребления"]
        allCountSet.colors = [secondBarColor, firstBarColor]
        allCountSet.valueTextColor = Settings.Color.secondAccent
        return [allCountSet]
    }

    private func waterLines() -> [LineChartDataSet]
    {
        let flatEntities = DatabaseManager.shared.commonRealm.objects(FlatEntity.self).filter("sentDate != nil").sorted(byKeyPath: "sentDate")

        var coldWaterCountData: [ChartDataEntry] = []
        var hotWaterCountData: [ChartDataEntry] = []
        for entities in flatEntities {
            let x = entities.sentDate?.timeIntervalSinceReferenceDate ?? Settings.startCompanyDate.timeIntervalSinceReferenceDate
            var coldWaterCount = 0.0
            var hotWaterCount = 0.0
            for waterCounter in entities.waterCounters {
                coldWaterCount +=  Double(waterCounter.coldCount) ?? 0.0
                hotWaterCount +=  Double(waterCounter.hotCount) ?? 0.0
            }
            coldWaterCountData.append(ChartDataEntry(x: Double(x), y: coldWaterCount))
            hotWaterCountData.append(ChartDataEntry(x: Double(x), y: hotWaterCount))
        }

        let coldWaterCountSet = LineChartDataSet(entries: coldWaterCountData, label: "Общее потребление холодной воды")
        coldWaterCountSet.axisDependency = .left
        coldWaterCountSet.setColor(firstColor)
        coldWaterCountSet.setCircleColor(firstColor)
        coldWaterCountSet.lineWidth = 2
        coldWaterCountSet.circleRadius = 3
        coldWaterCountSet.fillAlpha = 65/255
        coldWaterCountSet.fillColor = firstColor
        coldWaterCountSet.highlightColor = Settings.Color.brand
        coldWaterCountSet.drawCircleHoleEnabled = false
        coldWaterCountSet.drawValuesEnabled = true
        coldWaterCountSet.mode = .horizontalBezier
        coldWaterCountSet.valueTextColor = Settings.Color.brand

        let hotWaterCountSet = LineChartDataSet(entries: hotWaterCountData, label: "Общее ночное горячей воды")
        hotWaterCountSet.axisDependency = .left
        hotWaterCountSet.setColor(secondColor)
        hotWaterCountSet.setCircleColor(secondColor)
        hotWaterCountSet.lineWidth = 2
        hotWaterCountSet.circleRadius = 3
        hotWaterCountSet.fillAlpha = 65/255
        hotWaterCountSet.fillColor = secondColor
        hotWaterCountSet.highlightColor = Settings.Color.brand
        hotWaterCountSet.drawCircleHoleEnabled = false
        hotWaterCountSet.drawValuesEnabled = true
        hotWaterCountSet.mode = .horizontalBezier
        hotWaterCountSet.valueTextColor = Settings.Color.brand

        return [coldWaterCountSet, hotWaterCountSet]
    }

    private func waterBars() -> [BarChartDataSet]
    {
        let flatEntities = DatabaseManager.shared.commonRealm.objects(FlatEntity.self).filter("sentDate != nil").sorted(byKeyPath: "sentDate")

        var allCountData: [BarChartDataEntry] = []

        var coldWaterCountData: [BarChartDataEntry] = []
        var hotWaterCountData: [BarChartDataEntry] = []

        var lastColdWaterCount: Double = 0.0
        var lastHotWaterCount: Double = 0.0

        for entity in flatEntities {
            let x = entity.sentDate?.timeIntervalSinceReferenceDate ?? Settings.startCompanyDate.timeIntervalSinceReferenceDate
            var coldWaterCount = 0.0
            var hotWaterCount = 0.0
            for waterCounter in entity.waterCounters {
                coldWaterCount +=  Double(waterCounter.coldCount) ?? 0.0
                hotWaterCount +=  Double(waterCounter.hotCount) ?? 0.0
            }
            coldWaterCountData.append(BarChartDataEntry(x: Double(x), y: coldWaterCount - lastColdWaterCount))
            hotWaterCountData.append(BarChartDataEntry(x: Double(x), y: hotWaterCount - lastHotWaterCount))


            allCountData.append(BarChartDataEntry(x: Double(x), yValues: [hotWaterCount - lastHotWaterCount, coldWaterCount - lastColdWaterCount]))

            lastColdWaterCount = coldWaterCount
            lastHotWaterCount = hotWaterCount
        }

        let allCountSet = BarChartDataSet(entries: allCountData, label: "")
        allCountSet.axisDependency = .right
        allCountSet.stackLabels = ["Частота потребления горячей воды", "Частота потребления холодной воды"]
        allCountSet.colors = [secondBarColor, firstBarColor]
        allCountSet.valueTextColor = Settings.Color.secondAccent
        return [allCountSet]
    }


}

extension StatisticsViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if axis is XAxis {
            return Settings.shortDateFormatter.string(from: Date(timeIntervalSinceReferenceDate: value))
        } else {
            return String(value)
        }
    }
}
