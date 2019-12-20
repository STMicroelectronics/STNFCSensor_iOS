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

class STTheme{

    //0x39A9DC
    static let primaryColor = UIColor(red: 0x39/255.0, green: 0xA9/255.0, blue: 0xDC/255.0, alpha: 1.0)
    //0x002052
    static let primaryDarkColor = UIColor(red: 0x00/255.0, green: 0x20/255.0, blue: 0x52/255.0, alpha: 1.0)
    //D4007A
    static let accentColor = UIColor(red: 0xD4/255.0, green: 0x00/255.0, blue: 0x7A/255.0, alpha: 1.0)
    
    static func applayAll(){
        applyUINavigatorBarTheme(UINavigationBar.appearance())
        applyTabBarTheme(UITabBar.appearance())
        applyButtonTheme(UIButton.appearance())
    }
        
    public static func applyUINavigatorBarTheme(_ navigatiorBar: UINavigationBar){
        navigatiorBar.barTintColor = primaryColor
        navigatiorBar.tintColor = primaryDarkColor
        
        navigatiorBar.titleTextAttributes = [
            .foregroundColor : [primaryColor]
        ]
        
        let navigationBarButton = UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self] )
        navigationBarButton.tintColor = primaryDarkColor
        navigationBarButton.setTitleColor(primaryDarkColor, for: .normal)
    }
    
    public static func applyTabBarTheme(_ tabBar: UITabBar){
        tabBar.barTintColor = primaryColor
        tabBar.tintColor = primaryDarkColor
        tabBar.unselectedItemTintColor = UIColor.white
    }
    
    public static func applyButtonTheme(_ button: UIButton ){
        button.tintColor = accentColor
        button.setTitleColor(accentColor, for: .normal)
    }
        
}
