/**
 Admob
 
 Admobのバナーを管理するクラス
 
 - Author: fuku
 - Copyright: Copyright (c) 2016 fuku. All rights reserved.
 - Date: 2016/6/18
 - Version: 2.0
 */

import UIKit
import GoogleMobileAds

final class Admob: NSObject, GADBannerViewDelegate, GADInterstitialDelegate {
    let AdMobBannerID:       String = ""
    let AdMobInterstitialId: String = ""
    
    static let shared = Admob()
    
    /**
     createAndLoadBanner
     
     AdmobViewの初期化を実施する
     */
    func createAndLoadBanner(viewController: UIViewController) ->  GADBannerView{
        let admobView                = GADBannerView()
        admobView.adUnitID           = AdMobBannerID
        admobView.delegate           = self
        admobView.rootViewController = viewController
        admobView.frame.origin       = CGPointMake(0, 0)
        admobView.adSize             = GADAdSizeFromCGSize(CGSizeMake(viewController.view.frame.width, 50))
        let request = GADRequest()
        if TARGET_OS_SIMULATOR != 0 {
            request.testDevices = [kGADSimulatorID]
        }
        admobView.loadRequest(request)
        return admobView
    }
    
    /**
     createAndLoadInterstitial
     
     AInterstitialの初期化を実施する
     */
    func createAndLoadInterstitial() -> GADInterstitial{
        let interstitial      = GADInterstitial(adUnitID: AdMobInterstitialId)
        interstitial.delegate = self
        interstitial.loadRequest(GADRequest())
        return interstitial
    }
}
