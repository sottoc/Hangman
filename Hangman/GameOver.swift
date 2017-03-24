/*-------------------------------------

- Hangman! -
created by FV iMMAGINATION ©2015
All Rights reserved

--------------------------------------*/

import UIKit
import GoogleMobileAds
import AudioToolbox
import iAd


class GameOver: UIViewController, GADBannerViewDelegate, ADBannerViewDelegate
{
    @IBOutlet weak var wordNotGuessedLabel: UILabel!
    
    @IBOutlet weak var homeOutlet: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var replayOutlet: UIButton!
    
    var iAdBannerView = ADBannerView()
    var adMobBannerView = GADBannerView()
    
    
    /* Variables */
    var wordNotGuessed = ""
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        wordNotGuessedLabel.text = "SOLUTION: " + wordNotGuessed

        // Init ad banners
        initiAdBanner()
        initAdMobBanner()
    
        if(ALInterstitialAd.isReadyForDisplay()){
            ALInterstitialAd.show()
        }
    
        let f = UIScreen.mainScreen().bounds.size.height;
        if(f == 1024){
            titleLabel.font = UIFont(name: "Manteka", size: 50)
            wordNotGuessedLabel.font = UIFont(name: "Manteka", size: 45)
            homeOutlet.titleLabel?.font = UIFont(name: "Manteka", size: 50)
            replayOutlet.titleLabel?.font = UIFont(name: "Manteka", size: 50)
        }
    }

    // MARK: - IAD + ADMOB BANNER METHODS
    
    // Initialize Apple iAd banner
    func initiAdBanner() {
        iAdBannerView = ADBannerView(frame: CGRectMake(0, self.view.frame.size.height, 0, 0) )
        iAdBannerView.delegate = self
        iAdBannerView.hidden = true
        view.addSubview(iAdBannerView)
    }
    
    // Initialize Google AdMob banner
    func initAdMobBanner() {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            // iPad banner
            adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSizeMake(728, 90))
            adMobBannerView.frame = CGRectMake(0, self.view.frame.size.height, 728, 90)
            
        } else {
            // iPhone banner
            adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSizeMake(320, 50))
            adMobBannerView.frame = CGRectMake(0, self.view.frame.size.height, 320, 50)
        }
        
        adMobBannerView.adUnitID = ADMOB_BANNER_UNIT_ID
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        view.addSubview(adMobBannerView)
        let request = GADRequest()
        adMobBannerView.loadRequest(request)
    }
    
    
    // Hide the banner
    func hideBanner(banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        
        banner.frame = CGRectMake(0, self.view.frame.size.height, banner.frame.size.width, banner.frame.size.height)
        UIView.commitAnimations()
        banner.hidden = true
        
    }
    
    // Show the banner
    func showBanner(banner: UIView) {
        UIView.beginAnimations("showBanner", context: nil)
        
        banner.frame = CGRectMake(view.frame.size.width/2 - banner.frame.size.width/2, self.view.frame.size.height - banner.frame.size.height,
            banner.frame.size.width, banner.frame.size.height);
        
        UIView.commitAnimations()
        banner.hidden = false
        
    }
    
    // iAd banner available
    func bannerViewWillLoadAd(banner: ADBannerView!) {
        print("iAd loaded!")
        hideBanner(adMobBannerView)
        showBanner(iAdBannerView)
    }
    
    // NO iAd banner available
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        print("iAd can't looad ads right now, they'll be available later")
        hideBanner(iAdBannerView)
        let request = GADRequest()
        adMobBannerView.loadRequest(request)
    }
    
    
    // AdMob banner available
    func adViewDidReceiveAd(view: GADBannerView!) {
        print("AdMob loaded!")
        hideBanner(iAdBannerView)
        showBanner(adMobBannerView)
    }
    
    // NO AdMob banner available
    func adView(view: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("AdMob Can't load ads right now, they'll be available later \n\(error)")
        hideBanner(adMobBannerView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clickReplay(sender: AnyObject) {
        replayGame = true
        self.navigationController?.popViewControllerAnimated(true)
    }

}
