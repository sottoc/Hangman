/*-------------------------------------

- Hangman! -
created by FV iMMAGINATION ©2015
All Rights reserved

--------------------------------------*/


import UIKit
import GoogleMobileAds
import AudioToolbox
import iAd

class GameBoard: UIViewController, GADBannerViewDelegate, ADBannerViewDelegate
{

    /* Views */
    @IBOutlet var letterButtons: [UIButton]!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var hangmanImage: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var iAdBannerView = ADBannerView()
    var adMobBannerView = GADBannerView()
    
    /* Variables */
    var wordToGuess = NSString()
    var attempts = 0
    var genre = ""
    var score = 0
    @IBOutlet weak var constraintLeftHangmanView: NSLayoutConstraint!
    @IBOutlet weak var constraintBackButton: NSLayoutConstraint!
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hangmanImage.image = UIImage(named: "h0")
        score = 0
        scoreLabel.text = "Score: \(score)"
    
        // Init ad banners
        initiAdBanner()
        initAdMobBanner()
    
        getRandomWord()
        
        let f = UIScreen.mainScreen().bounds.size.height;
        if(f <= 568){
            constraintLeftHangmanView.constant = 17
        }else if(f <= 667){
            constraintLeftHangmanView.constant = 40
        }else{
            constraintLeftHangmanView.constant = 50
        }
        
        if(f <= 568){
            titleLabel.font = UIFont(name: "Manteka", size: 14)
        }else if(f <= 667){
            titleLabel.font = UIFont(name: "Manteka", size: 16.3)
        }else if(f == 1024){
            constraintBackButton.constant = 45
            titleLabel.font = UIFont(name: "Manteka", size: 34)
            scoreLabel.font = UIFont(name: "Manteka", size: 37)
            wordLabel.font = UIFont(name: "Manteka", size: 34)
            for butt in letterButtons {
                butt.titleLabel?.font = UIFont(name: "Manteka", size: 37)
            }
        }else{
            titleLabel.font = UIFont(name: "Manteka", size: 18)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if(replayGame){
            replayGame = false
            hangmanImage.image = UIImage(named: "h0")
            score = 0
            scoreLabel.text = "Score: \(score)"
            
            // Init ad banners
            initiAdBanner()
            initAdMobBanner()
            
            getRandomWord()
        }
    }
    
    // MARK: - SETUP RANDOM WORD AND INITIALIZE VARIABLES
    func getRandomWord() {
        let dictRoot = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Words", ofType: "plist")!)
        let wordsArr = dictRoot?.objectForKey(genre) as! NSArray
        let randomWord = Int(arc4random() % UInt32(wordsArr.count))
    
        // Init game variables
        wordToGuess = "\(wordsArr[randomWord])"
        setupWord(wordToGuess)
        attempts = 0
        print("WORD TO GUESS: \(wordToGuess)")
        titleLabel.text = genre
        hangmanImage.image = UIImage(named: "h\(attempts)")
    
        // Round letter buttons corners
        for butt in letterButtons {
            //butt.layer.cornerRadius = butt.bounds.size.width/2
            butt.backgroundColor = UIColor(red: 49.0/255.0, green: 133.0/255.0, blue: 156.0/255.0, alpha: 1.0)
        }
    }
    
    // MARK: - SETUP WORD
    func setupWord(word:NSString) {
        wordLabel.text = ""
        for var i = 0;  i < word.length;  i++ {
            wordLabel.text = wordLabel.text?.stringByAppendingString("•")
        }
        
        // Separate words in case of 2 words
        let whiteSpaceRange = word.rangeOfCharacterFromSet(NSCharacterSet.whitespaceCharacterSet())
        if whiteSpaceRange.location != NSNotFound {
            let location = NSMakeRange(whiteSpaceRange.location, 1)
            let wordStr = wordLabel.text! as NSString
            wordLabel.text = wordStr.stringByReplacingCharactersInRange(location, withString: " ")
        }
    }

    // MARK: - CHECK IF THE CHOOSE LETTER DOES EXIST
    func checkIfLetterExists(letterToCheck:NSString) {
        var match = false
        var letterRange = NSRange()
        let charToCheck = letterToCheck.characterAtIndex(0)

    
        // LETTER EXISTS ---------------------------------------------------
        for var i = 0;  i < wordToGuess.length;  i++ {
            let tempChar = wordToGuess.characterAtIndex(i)
        
            if charToCheck == tempChar {
                Flurry.logEvent("Correct Character Clicked")
                match = true
                letterRange = NSMakeRange(i, 1)
                let wordStr:NSString = wordLabel.text!
            
                wordLabel.text = wordStr.stringByReplacingCharactersInRange(letterRange, withString: String(letterToCheck))
                print("CHECKING WORD: \(wordLabel.text!)")

                if wordLabel.text == wordToGuess  {
                    Flurry.logEvent("Complete Word")
                    titleLabel.text = "BIEN JOUE..."
                    score++
                    scoreLabel.text = "Score: \(score)"
                
                // Save best scores for genres
                /*switch genre {
                    case "History":
                        if bestHistory < score {
                            bestHistory = score
                            defaults.setInteger(bestHistory, forKey: "bestHistory")
                        }
                    break
                    case "Sport":
                        if bestSport < score {
                            bestSport = score
                            defaults.setInteger(bestSport, forKey: "bestSport")
                        }
                    break
                    case "Entertainment":
                        if bestEntertainment < score {
                            bestEntertainment = score
                            defaults.setInteger(bestEntertainment, forKey: "bestEntertainment")
                        }
                    break
                    case "Geography":
                        if bestGeography < score {
                            bestGeography = score
                            defaults.setInteger(bestGeography, forKey: "bestGeography")
                        }
                    break
                case "Science":
                    if bestScience < score {
                        bestScience = score
                        defaults.setInteger(bestScience, forKey: "bestScience")
                    }
                    break
                default:
                    break
                }
                */
                    // Get a new word after 2 seconds
                    NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "getRandomWord", userInfo: nil, repeats: false)
                }
            }
        }
    
    
        // LETTER DOES NOT EXIST --------------------------------------------------
        if !match {
            attempts++
            Flurry.logEvent("Wrong Character Clicked")
            // GAME OVER!
            if attempts > 5 { gameOver() }
            hangmanImage.image = UIImage(named: "h\(attempts)")
        }
    }

    // MARK: - LETTER BUTTON
    @IBAction func letterButt(sender: AnyObject) {
        let butt = sender as! UIButton
        checkIfLetterExists(butt.titleLabel!.text!)
    
        // Change buttons' color to prevent the player to tap it again
        butt.backgroundColor = UIColor.lightGrayColor()
    }

    // MARK: - GAME OVER FUNCTION
    func gameOver() {
        Flurry.logEvent("Hang Man")
        let goVC = storyboard?.instantiateViewControllerWithIdentifier("GameOver") as! GameOver
        goVC.wordNotGuessed = wordToGuess as String
        navigationController?.pushViewController(goVC, animated: true)
    }

    // MARK: - BACK BUTTONS
    @IBAction func backButt(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
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

