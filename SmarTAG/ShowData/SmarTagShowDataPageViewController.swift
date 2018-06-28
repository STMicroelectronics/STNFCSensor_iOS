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
 
/// using a UIPageController inside a TabBar controller it is bugged, the UIPageController takes more space
/// than what it is needed and the TabBar background it became darker.
/// our work arround is to isolate the UIPageController inside a container view this view controller
/// just pass the data to the real SmarTagShowDataPageViewController inside its container view
 //  the schema is: TabBarViewController[ ViewController[ ContainerView[SmarTagShowDataPageViewController] ] ]
public class SmarTagShowDataPageViewControllerWorkArround : UIViewController,SmarTagObjectWithTag{
 
    var tagContent: SmarTagNdefParserPotocol?
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        propagateTagContentTo(segue.destination)
    }
}

public class SmarTagShowDataPageViewController: UIPageViewController , SmarTagObjectWithTag{
    
    /// if the parameter is a event sample return it othewise return nil
    ///
    /// - Parameter sample: generic sample
    /// - Returns: the sample if it is a EventDataSample
    private static func extractEventSample(_ sample:DataSample)-> EventDataSample?{
        switch(sample){
        case .event(let data):
            return data
        default:
            return nil
        }//switch
    }
    
    /// extract the sensor sample from a generic data sample
    ///
    /// - Parameter sample: generic data sample
    /// - Returns: the sample if it is a SensorDataSample, or a sample with the acceleration if it is an
    ///  EventDataSample
    private static func extractSensorSample(_ sample:DataSample) -> SensorDataSample?{
        switch(sample){
        case .sensor(let data):
            return data
        case .event(let data):
            if let acc = data.acceleration{
                return SensorDataSample(date: data.date,temperature: nil,humidity: nil,
                                        pressure: nil,acceleration: acc)
            }
            return nil
        }//switch
    }
    
    
    // when set the tagcontent extract the sensor and event sample
    var tagContent: SmarTagNdefParserPotocol?{
        didSet{
            sensorSample = tagContent?.samples
                .compactMap(SmarTagShowDataPageViewController.extractSensorSample)
        
            eventSample = tagContent?.samples
                .compactMap(SmarTagShowDataPageViewController.extractEventSample)
        }
    }
    
    private var sensorSample : [SensorDataSample]?
    private var eventSample : [EventDataSample]?
    
    
    /// List of controller to show in the pageViewController
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        let storyBoard = UIStoryboard(name: "ShowData", bundle: nil)
        return [storyBoard.instantiateViewController(withIdentifier: "SmarTagSensorDataViewController"),
                storyBoard.instantiateViewController(withIdentifier: "SmarTagEventDataViewController")]
    }()
    
    
    /// show the fist view controller
    public override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        setPageDataSample()
        if let firstViewController = orderedViewControllers.first{
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
    
    
    /// pass the sample to render to the child view controller
    private func setPageDataSample(){
        orderedViewControllers.forEach{ viewController in
            switch viewController {
            case let eventsViewController as SmarTagEventSampleViewController:
                eventsViewController.sample = eventSample
                break;
            case let sensorViewController as SmarTagSensorSampleViewController:
                sensorViewController.samples = sensorSample
                break;
            default:
                return
            }
        }
    }
}

// MARK: - UIPageViewControllerDataSource
/// show the page using a circular buffer
extension SmarTagShowDataPageViewController: UIPageViewControllerDataSource {
    
    
    /// set the dots color to use in the UIPageControl
    private func setupPageControl() {
       let appearance = UIPageControl.appearance()
       appearance.pageIndicatorTintColor = UIColor.lightGray
       appearance.currentPageIndicatorTintColor = UIColor(named: "st_accent")!
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of:viewController) else {
            return nil
        }
        
        let previousIndex = ((viewControllerIndex - 1) + orderedViewControllers.count) % orderedViewControllers.count
        
        return orderedViewControllers[previousIndex]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of:viewController) else {
            return nil
        }
        
        let previousIndex = ((viewControllerIndex + 1) + orderedViewControllers.count) % orderedViewControllers.count
        
        return orderedViewControllers[previousIndex]
    }
    
    ////////Start: functions needed to show the UIPageControl ////////////////////////////////
    public func presentationCount(for pageViewController: UIPageViewController) -> Int{
        setupPageControl()
        return orderedViewControllers.count
    }
    
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int{

        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of:firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    //////// End: functions needed to show the UIPageControl ////////////////////////////////
}
