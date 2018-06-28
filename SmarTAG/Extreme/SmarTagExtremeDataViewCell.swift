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
 
 class SmarTagExtremeDataViewCell : UITableViewCell{
    
    public struct Data{
        let name :String
        let icon :UIImage
        let dataFormat:String
        let extremes:DataExtreme
    }
    
    
    @IBOutlet weak var mIcon: UIImageView!
    
    @IBOutlet weak var mSensorName: UILabel!
    @IBOutlet weak var mMaxDateLablel: UILabel!
    @IBOutlet weak var mMaxValueLabel: UILabel!
    @IBOutlet weak var mMinValueLabel: UILabel!
    @IBOutlet weak var mMinDateLabel: UILabel!
    @IBOutlet weak var mMinView: UIView!
    @IBOutlet weak var mMaxView: UIView!
    
    
    public func setData(_ data:Data){
        mIcon.image = data.icon
        mSensorName.text = data.name
        
        if let max = data.extremes.maxValue,
            let maxDate = data.extremes.maxDate{
            mMaxValueLabel.text = String(format: data.dataFormat, max)
            mMaxDateLablel.text = SmarTagExtremeDataViewCell.DATE_FORMAT.string(for: maxDate)
            
            mMaxView.isHidden=false;
        }else{
            mMaxView.isHidden=true;
        }
        
        if let min = data.extremes.minValue,
            let minDate = data.extremes.minDate{
            mMinValueLabel.text = String(format: data.dataFormat, min)
            mMinDateLabel.text = SmarTagExtremeDataViewCell.DATE_FORMAT.string(for: minDate)
            mMinView.isHidden=false;
        }else{
            mMinView.isHidden=true;
        }
    }
    
    static let DATE_FORMAT : DateFormatter = {
        let formatter = DateFormatter();
        formatter.dateFormat = "HH:mm:ss dd/MMM"
        return formatter;
    }();
 }
