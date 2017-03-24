/*-------------------------------------

- Hangman! -
created by FV iMMAGINATION ©2015
All Rights reserved

--------------------------------------*/

import UIKit
import GoogleMobileAds
import AudioToolbox
import iAd

class Home: UIViewController, UITableViewDelegate, UITableViewDataSource, ADBannerViewDelegate, GADBannerViewDelegate
{
    /* Views */
    @IBOutlet weak var genresTableView: UITableView!
    @IBOutlet weak var selectLabel: UILabel!
    
    var iAdBannerView = ADBannerView()
    var adMobBannerView = GADBannerView()
    
    
    @IBOutlet weak var constraintTopTblview: NSLayoutConstraint!
    /* Variables */
    var genreStr = ""
    var focusOnPlayButtons = false
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // init ad banners
        initiAdBanner()
        initAdMobBanner()

        // pos
        genresTableView.center = view.center
        
        let f = UIScreen.mainScreen().bounds.size.height;
        if(f == 1024){
            selectLabel.font = UIFont(name: "Manteka", size: 50)
        }
        
        if(f > 667){
            constraintTopTblview.constant = 40
        }else if(f > 568){
            constraintTopTblview.constant = 30
        }
        
    }

  
    // MARK: - TABLEVIEW DELEGATES
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GenresList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    
        let imgItem = cell.viewWithTag(101) as! UIImageView
        let txtItem = cell.viewWithTag(102) as! UILabel
        txtItem.text = "\(GenresList[indexPath.row])"
        imgItem.image = UIImage(named: "\(GenresList[indexPath.row])" )
    
        let f = UIScreen.mainScreen().bounds.size.height;
        if(f <= 480){
            txtItem.font = UIFont(name: "Manteka", size: 15)
        }else if(f <= 568){
            txtItem.font = UIFont(name: "Manteka", size: 18)
        }else if(f <= 667){
            txtItem.font = UIFont(name: "Manteka", size: 22)
        }else if(f == 1024){
            txtItem.font = UIFont(name: "Manteka", size: 42)
        }else{
            txtItem.font = UIFont(name: "Manteka", size: 24)
        }
    
        cell.backgroundColor = UIColor.clearColor()
    
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let f = UIScreen.mainScreen().bounds.size.height;
        if(f <= 568){
            return (f-140)/13
        }else if(f == 1024){
            return 60;
        }else if(f > 667){
            return 44
        }
        return 40
    }
    
    // MARK: -  CELL HAS BEEN TAPPED
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let genresStr = "\(GenresList[indexPath.row])"
    
        Flurry.logEvent("Word Type:"+genresStr)
    
        let gbVC = storyboard?.instantiateViewControllerWithIdentifier("GameBoard") as! GameBoard
        gbVC.genre = genresStr
        navigationController?.pushViewController(gbVC, animated: true)
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

}
