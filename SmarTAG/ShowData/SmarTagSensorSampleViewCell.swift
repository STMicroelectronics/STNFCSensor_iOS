 /*
  * Copyright (c) 2018  STMicroelectronics – All rights reserved
  * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
  *
  * Redistribution and use in source and binary forms, with or without modification,
  * are permitted provided that the following conditions are met:
  *
  * - Redistributions of source code must retain the above copyright notice, this list of conditions
  * and the following disclaimer.
  *
  * - Redistributions in binary form must reproduce the above copyright notice, this list of
  * conditions and the following disclaimer in the documentation and/or other materials provided
  * with the distribution.
  *
  * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
  * STMicroelectronics company nor the names of its contributors may be used to endorse or
  * promote products derived from this software without specific prior written permission.
  *
  * - All of the icons, pictures, logos and other images that are provided with the source code
  * in a directory whose title begins with st_images may only be used for internal purposes and
  * shall not be redistributed to any third party or modified in any way.
  *
  * - Any redistributions in binary form shall not include the capability to display any of the
  * icons, pictures, logos and other images that are provided with the source code in a directory
  * whose title begins with st_images.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
  * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
  * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
  * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
  * OF SUCH DAMAGE.
  */
 
import Foundation
import UIKit
import Charts

/// Table cell containing the plot and the details button
public class SmarTagSensorSampleViewCell : UITableViewCell{

    
    /// data used to fill the cell field
    public struct Data{
        
        /// sensor name
        let name:String
        
        /// sensor samples
        let samples:[ChartDataEntry]
        
        /// range to use for the plot
        let plotRange:ClosedRange<Double>
    }
    
    
    /// label containing the sensor name
    @IBOutlet weak var mSensorName: UILabel!
    
    /// view containign the sensor plot
    @IBOutlet weak var mChartView: LineChartView!
    
    
    /// function called when the details button is pressed
    public var onDetailsClick: ()->Void  = {}
    
    /// function called when the details button is pressed
    /// it call the user delegate
    /// - Parameter sender: button pressed
    @IBAction func onDetailsClicked(_ sender: UIButton) {
        onDetailsClick()
    }
    
    
    /// set up the chart parameters
    ///
    /// - Parameter plotRange: range to use for the y axis
    private func setUpChart(plotRange:ClosedRange<Double>){
        mChartView.leftAxis.axisMaximum = plotRange.upperBound
        mChartView.leftAxis.axisMinimum = plotRange.lowerBound
        mChartView.xAxis.labelPosition = .bottom
        mChartView.xAxis.drawLabelsEnabled=false
        mChartView.xAxis.drawGridLinesEnabled=false
        mChartView.rightAxis.enabled=false;
        mChartView.chartDescription?.enabled=false
        mChartView.legend.enabled=false;
        if #available(iOS 13, *){
            mChartView.leftAxis.labelTextColor = UIColor.label
        }
    }
    
    
    /// create the dataSet
    ///
    /// - Parameter data: points to plot
    /// - Returns: line to plot in the chart
    private func createDataSet(data:[ChartDataEntry])->LineChartData{
        let dataSet = LineChartDataSet(entries: data,label: nil)
        dataSet.drawCirclesEnabled=false
        dataSet.drawIconsEnabled=false
        dataSet.drawValuesEnabled=false
        dataSet.setDrawHighlightIndicators(false)
        dataSet.lineWidth=2.0
        dataSet.setColor(NSUIColor(named: "st_accent")!)
        return LineChartData(dataSet: dataSet)
    }
    
    
    /// set the cell with the new data
    ///
    /// - Parameter data: data to display
    public func showData(data: Data){
        mSensorName.text = data.name
        setUpChart(plotRange:data.plotRange)
        mChartView.data = createDataSet(data: data.samples)
    }
    
}
