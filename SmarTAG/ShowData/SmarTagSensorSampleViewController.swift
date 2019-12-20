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
import SmarTagLib

/// show the plot with the sensor samples
public class SmarTagSensorSampleViewController :UIViewController{
    
    public var samples:[SensorDataSample]?
    
    /// create a chart data entry from a SensorDataSample
    ///
    /// - Parameters:
    ///   - sample: sample where extract the data
    ///   - extractData: function that select the sample data
    /// - Returns: A chartDataEntry containing the sensor data or nil if the data is not available.
    private func createChartDataEntry(sample:SensorDataSample, extractData:((_ sample:SensorDataSample)->Float?))->ChartDataEntry?{
        if let data = extractData(sample){
            return ChartDataEntry(x: sample.date.timeIntervalSinceReferenceDate,
                                  y: Double(data))
        }else{
            return nil
        }
    }
    
    /// list of chart entry containing the temperature samples
    private lazy var temperatureData:[ChartDataEntry]? = {
        return samples?.compactMap{ createChartDataEntry(sample: $0){ $0.temperature} } }()
    
    /// list of chart entry containing the pressure samples
    private lazy var pressureData:[ChartDataEntry]? = {
        return samples?.compactMap{ createChartDataEntry(sample: $0){ $0.pressure} } }()
    
    /// list of chart entry containing the humidity samples
    private lazy var humidityData:[ChartDataEntry]? = {
        return samples?.compactMap{ createChartDataEntry(sample: $0){ $0.humidity} } }()
    
    /// list of chart entry containing the accekeration samples
    private lazy var accelerationData:[ChartDataEntry]? = {
        return samples?.compactMap{ createChartDataEntry(sample: $0){ $0.acceleration} } }()
    
    private var tableData:[SmarTagSensorSampleViewCell.Data] = []
    private var detailsData:[SmarTagSensorDetailsViewController.Data] = []
    
    @IBOutlet weak var mPlotTable: UITableView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        mPlotTable.dataSource = self
    }
    
    
    /// create the cell and the details data to display
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableData = [];
        let titleFormat = "%@ (%@)"
        if let pressure = pressureData, !pressure.isEmpty{
            let title = String(format: titleFormat, SmarTagSensorName.PRESSURE,SmarTagSensorName.PRESSURE_UNIT)
            tableData.append(SmarTagSensorSampleViewCell.Data(name: title,
                                                              samples: pressure,
                                                              plotRange:SmarTagSensorSampleViewController.PRESSURE_EXTREME))
            
            detailsData.append(SmarTagSensorDetailsViewController.Data(title: SmarTagSensorName.PRESSURE,
                                                                       dataFormat: SmarTagSensorName.PRESSURE_FORMAT,
                                                                       samples:pressure))
        }
        if let humidity = humidityData, !humidity.isEmpty{
            let title = String(format: titleFormat, SmarTagSensorName.HUMIDITY,SmarTagSensorName.HUMIDITY_UNIT)
            tableData.append(SmarTagSensorSampleViewCell.Data(name: title,
                                                              samples: humidity,
                                                              plotRange: SmarTagSensorSampleViewController.HUMIDITY_EXTREME))
            detailsData.append(SmarTagSensorDetailsViewController.Data(title: SmarTagSensorName.HUMIDITY,
                                                                       dataFormat: SmarTagSensorName.HUMIDITY_FORMAT,
                                                                       samples:humidity))
        }
        if let acceleration = accelerationData, !acceleration.isEmpty{
            let title = String(format: titleFormat, SmarTagSensorName.ACCELERATION,SmarTagSensorName.ACCELERATION_UNIT)
            tableData.append(SmarTagSensorSampleViewCell.Data(name: title,
                                                              samples: acceleration,
                                                              plotRange: SmarTagSensorSampleViewController.ACCELERATION_EXTREME))
            detailsData.append(SmarTagSensorDetailsViewController.Data(title: SmarTagSensorName.ACCELERATION,
                                                                       dataFormat:SmarTagSensorName.ACCELERATION_FORMAT,
                                                                       samples:acceleration))
        }
        if let temperature = temperatureData, !temperature.isEmpty{
            let title = String(format: titleFormat, SmarTagSensorName.TEMPERATURE,SmarTagSensorName.TEMPERATURE_UNIT)
            tableData.append(SmarTagSensorSampleViewCell.Data(name: title,
                                                              samples: temperature,
                                                              plotRange: SmarTagSensorSampleViewController.TEMPERATURE_EXTREME))
            detailsData.append(SmarTagSensorDetailsViewController.Data(title: SmarTagSensorName.TEMPERATURE,
                                                                       dataFormat: SmarTagSensorName.TEMPERATURE_FORMAT,
                                                                       samples:temperature))
        }
        mPlotTable.reloadData()
    }
    
    
    /// pass the data to the details view controller
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? SmarTagSensorDetailsViewController,
            let data = sender as? SmarTagSensorDetailsViewController.Data{
            viewController.data = data;
        }
    }
    
    /// plot temperature range
    private static let TEMPERATURE_EXTREME = -5.0...45.0
    
    /// plot pressure range
    private static let PRESSURE_EXTREME = 950.0...1150.0
    
    /// plot humidity range
    private static let HUMIDITY_EXTREME = 0.0...100.0
    
    /// plot acceleration range
    private static let ACCELERATION_EXTREME = 600.0...63.0*256.0
}

extension SmarTagSensorSampleViewController:UITableViewDataSource{
    private static let CELL_ID = "SmarTagSensorSampleViewCell"
    private static let DETAILS_SEGUE_ID = "SmarTagSensorDetailsSegue"
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SmarTagSensorSampleViewController.CELL_ID) as! SmarTagSensorSampleViewCell
        
        cell.showData(data:tableData[indexPath.row])
        let data = detailsData[indexPath.row]
        cell.onDetailsClick = {
            self.performSegue(withIdentifier: SmarTagSensorSampleViewController.DETAILS_SEGUE_ID, sender: data)
        }
        return cell;
    }
    
    
}
