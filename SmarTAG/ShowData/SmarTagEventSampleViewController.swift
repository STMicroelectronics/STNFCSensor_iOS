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


/// View controller to display the event samples
public class SmarTagEventSampleViewController : UIViewController{
    
    /// table where show the events
    @IBOutlet weak var mEventTable: UITableView!
    //label to show if no events are present
    @IBOutlet weak var mNoEventsLabel: UILabel!
    
    public var sample:[EventDataSample]?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        mEventTable.dataSource = self;
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let data = sample, !data.isEmpty{
            //show events, hide label
            mEventTable.reloadData()
            mNoEventsLabel.isHidden=true
        }else{
            // hide table, show label
            mEventTable.isHidden=true
            mNoEventsLabel.isHidden=false;
        }
    }
}


// MARK: - UITableViewDataSource
extension SmarTagEventSampleViewController : UITableViewDataSource{
    private static let CELL_ID = "SmarTagEventSampleViewCell"
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sample?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SmarTagEventSampleViewController.CELL_ID) as! SmarTagEventSampleViewCell
        
        if let sample = sample?[indexPath.row]{
            cell.setData(sample)
        }
        
        return cell
    }
    
}

 
/// Table row showing an asyncronous event
public class SmarTagEventSampleViewCell : UITableViewCell{
    
    /// event type
    @IBOutlet weak var mEventTypeIcon: UIImageView!
    
    /// event date
    @IBOutlet weak var mDateLabel: UILabel!
    
    /// acceleration during the event
    @IBOutlet weak var mAccLabel: UILabel!
    
    /// event name
    @IBOutlet weak var mEventListLabel: UILabel!
    
    /// orientation icon
    @IBOutlet weak var mOrientationIcon: UIImageView!
    
    
    /// get the orientation icon from the enum value
    ///
    /// - Parameter orientation: orietation value
    /// - Returns: corrispective orientation image
    private static func getOrientationImage(_ orientation:Orientation) -> UIImage?{
        switch(orientation){
            case .unknown:
                return nil
            case .up_right:
                return #imageLiteral(resourceName: "orientation_top_right")
            case .up_left:
                return #imageLiteral(resourceName: "orientation_top_left")
            case .down_left:
                return #imageLiteral(resourceName: "orientation_bottom_left")
            case .down_right:
                return #imageLiteral(resourceName: "orientation_bottom_right")
            case .top:
                return #imageLiteral(resourceName: "orientation_up")
            case .bottom:
                return #imageLiteral(resourceName: "orientation_down")
        }
    }
    
    
    /// return the first event that has not the value "orientation"
    ///
    /// - Parameter events: list of events
    /// - Returns: first event different from orientation
    private static func selectFirstNotOrientationEvent(_ events:[AccelerationEvent]) -> AccelerationEvent?{
        return events.first{ $0 != AccelerationEvent.orientation}
    }
    
    
    /// retrun the image corrisponding to the acceleration event,
    /// if more events are present the fist event != orientation will be selected
    ///
    /// - Parameter events: list of acceleration events
    /// - Returns: icon of the first acceleration event in the list
    private static func getEventImage(_ events :[AccelerationEvent])->UIImage{
        let event = selectFirstNotOrientationEvent(events) ?? AccelerationEvent.orientation;
        switch event {
        case .wakeUp:
            return #imageLiteral(resourceName: "event_wakeUp")
        case .orientation:
            return #imageLiteral(resourceName: "event_orientation")
        case .singleTap:
            return #imageLiteral(resourceName: "event_singleTap")
        case .doubleTap:
            return #imageLiteral(resourceName: "event_doubleTap")
        case .freeFall:
            return #imageLiteral(resourceName: "event_freefall")
        case .tilt:
            return #imageLiteral(resourceName: "event_tilt")
        }
    }
    
    /// trasform the acceleration event into a string
    ///
    /// - Parameter event: acceleration event
    /// - Returns: string describing the event
    private static func eventToString(_ event :AccelerationEvent) -> String {
        switch event {
            case .wakeUp:
                return SmarTagEventSampleViewCell.EVENT_WAKE_UP
            case .orientation:
                return SmarTagEventSampleViewCell.EVENT_ORIENTATION
            case .singleTap:
                return SmarTagEventSampleViewCell.EVENT_SINGLETAP
            case .doubleTap:
                return SmarTagEventSampleViewCell.EVENT_DOUBLETAP
            case .freeFall:
                return SmarTagEventSampleViewCell.EVENT_FREEFALL
            case .tilt:
                return SmarTagEventSampleViewCell.EVENT_TILT
        }
    }
    
    private func showAcceleration(_ acceleration: Float?) {
        if let acc = acceleration{
            mAccLabel.text = String(format: "\(SmarTagSensorName.ACCELERATION): " +
                "\(SmarTagSensorName.ACCELERATION_FORMAT)", acc)
            mAccLabel.isHidden=false;
        }else{
            mAccLabel.isHidden=true;
        }
    }
    
    private func showAcclerationEvents(_ events: [AccelerationEvent]) {
        let eventStrings = events
            .map(SmarTagEventSampleViewCell.eventToString)
            .joined(separator: ", ")
        mEventListLabel.text = String(format: SmarTagEventSampleViewCell.EVENTS_FORMAT, eventStrings)
    }
    
    private func showOrientationEvent(_ orientation: Orientation) {
        if let image = SmarTagEventSampleViewCell.getOrientationImage(orientation){
            mOrientationIcon.image = image
            mOrientationIcon.isHidden = false
        }else{
            mOrientationIcon.isHidden = true;
        }
    }
    
    public func setData(_ data:EventDataSample){
        mDateLabel.text = SmarTagEventSampleViewCell.DATE_FORMAT.string(from: data.date)
        showAcceleration(data.acceleration)
        showAcclerationEvents(data.accelerationEvents)
        showOrientationEvent(data.currentOrientation)
        mEventTypeIcon.image = SmarTagEventSampleViewCell.getEventImage(data.accelerationEvents)
    }
    
    static let DATE_FORMAT : DateFormatter = {
        let formatter = DateFormatter();
        formatter.dateFormat = "HH:mm:ss dd/MMM/YY"
        return formatter;
    }();
    
    
    private static let EVENTS_FORMAT = {
        return  NSLocalizedString("Events: %@",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagEventSampleViewCell.self),
                                  value: "Events: %@",
                                  comment: "Events: %@");
    }()
        
    private static let EVENT_TILT = {
        return  NSLocalizedString("Tilt",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagEventSampleViewCell.self),
                                  value: "Tilt",
                                  comment: "Tilt");
    }()

    
    private static let EVENT_FREEFALL = {
        return  NSLocalizedString("Free Fall",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagEventSampleViewCell.self),
                                  value: "Free fall",
                                  comment: "Free fall");
    }()
    
    private static let EVENT_DOUBLETAP = {
        return  NSLocalizedString("Double Tap",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagEventSampleViewCell.self),
                                  value: "Double Tap",
                                  comment: "Double Tap");
    }()
    
    private static let EVENT_SINGLETAP = {
        return  NSLocalizedString("Single Tap",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagEventSampleViewCell.self),
                                  value: "Single Tap",
                                  comment: "Single Tap");
    }()
    
    private static let EVENT_WAKE_UP = {
        return  NSLocalizedString("Wake Up",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagEventSampleViewCell.self),
                                  value: "Wake Up",
                                  comment: "Wake Up");
    }()
    
    private static let EVENT_ORIENTATION = {
        return  NSLocalizedString("Orientation",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagEventSampleViewCell.self),
                                  value: "Orientation",
                                  comment: "Orientation");
    }()
}
