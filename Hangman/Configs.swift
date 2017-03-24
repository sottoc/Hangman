/*-------------------------------------

- Hangman! -

created by FV iMMAGINATION ©2015
All Rights reserved

--------------------------------------*/

import Foundation
import UIKit

// IMPORTANT: REPLACE THE RED STRING BELOW WITH THE UNIT ID YOU'VE GOT BY REGISTERING YOUR APP IN http://www.apps.admob.com
let ADMOB_BANNER_UNIT_ID = "ca-app-pub-5256348154508329/5724880896"

// MARK: - GENRES ARRAY
let GenresList = [
    "Animaux",
    "Couleurs",
    "Pays",
    "Parties du Corps",
    "Fameux Films",
    "Fruits et Legumes",
    "Astronomie",
    "Prenoms Populaires",
    "Marques de Voitures",
    "Villes Francaises",
    "Le Foot",
    "Marques de Vetements",
    "Aleatoire",
]

var replayGame = false

// BEST SCORE INSTANCES -> THEY GET LOADED AT APP STARTUP
let defaults = NSUserDefaults.standardUserDefaults()
var bestHistory = defaults.integerForKey("bestHistory")
var bestSport = defaults.integerForKey("bestSport")
var bestEntertainment = defaults.integerForKey("bestEntertainment")
var bestGeography = defaults.integerForKey("bestGeography")
var bestScience = defaults.integerForKey("bestScience")


/* If you've adde a new Genre into GenresList array above, you must add a new bests core instance here.

 Example: Let's pretend you've added "Arts", so your new instance to save/retrieve its best score will look like this:
 var bestArts = defaults.integerForKey("bestArts")

Also, don't forget to add the same Array called "Arts" into the Words.plist file and add its strings with the words you wish to use for this Genre
Lastly, add a thumbnail image for this new Genre into Assets.xcassets folder as well (check the existing ones into GENRES THUMBNAILS folder)
*/