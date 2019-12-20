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
import WebKit

 public class SmarTagAboutViewController : UIViewController {
    
    @IBOutlet weak var mAboutContent: WKWebView!
    @IBOutlet weak var mVersionLabel: UILabel!
    @IBOutlet weak var mAppNameLabel: UILabel!
    
    /// Display app name and version
    private func setUpAppDetails(){
        let bundle = Bundle.main;
        let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String;
        let appName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String;
        mAppNameLabel.text = appName;
        mVersionLabel.text?.append(version);
    }
    
    public override func viewDidLoad() {
        setUpAppDetails()
        setUpAboutDetails()
    }
    
    /// display the main page if needed
    private func setUpAboutDetails() {
        //mAboutContent.delegate=self;
        mAboutContent.navigationDelegate = self;
        mAboutContent.scrollView.isScrollEnabled=false
        let aboutUrl = Bundle.main.path(forResource: "about", ofType: "html");
        do{
            let pageContent = try String(contentsOfFile: aboutUrl!, encoding: .utf8)
            mAboutContent.loadHTMLString(pageContent, baseURL: nil);

        } catch {
            print("SmarTagAboutViewController: Impossible open \(aboutUrl!)");
        }//do - catch
    }// setUpAboutDetails
    
 }
 
 extension SmarTagAboutViewController : WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //we have a url and the user cliked on a link
        if let url = navigationAction.request.url,
            navigationAction.navigationType == .linkActivated{
            decisionHandler(.cancel)
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }else{
            decisionHandler(.allow)
        }
    }
 }
 
 
 

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
