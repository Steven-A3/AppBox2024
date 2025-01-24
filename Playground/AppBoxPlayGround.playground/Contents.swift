//: Playground - noun: a place where people can play

import UIKit

/*

let AbbreviationDatabase =
[
		["abbreviation" : "ADN", "meaning" : "Any Day Now", "tags" : "Business"],
		["abbreviation" : "AEAP", "meaning" : "As Early as Possible"],
		["abbreviation" : "AFAIK", "meaning" : "As Far As I Know", "tags" : "Business"],
		["abbreviation" : "ALAP", "meaning" : "As Late as Possible"],
		["abbreviation" : "ALIWanIsU", "meaning" : "All I Want Is You", "tags" : "Romance"],
		["abbreviation" : "ALOrO", "meaning" : "All Or Nothing", "tags" : "Romance"],
		["abbreviation" : "AML", "meaning" : "All my love", "tags" : "Romance"],
		["abbreviation" : "ASAP", "meaning" : "As Soon as Possible", "tags" : "Business"],
		["abbreviation" : "ASL", "meaning" : "Age / Sex / Location?"],
		["abbreviation" : "ATM", "meaning" : "At The Moment", "tags" : "Business"],
		["abbreviation" : "B2B", "meaning" : "Business To Business", "tags" : "Business"],
		["abbreviation" : "B3", "meaning" : "Blah, Blah, Blah"],
		["abbreviation" : "B4N", "meaning" : "Bye For Now ", "tags" : "Top24"],
		["abbreviation" : "B4YKI", "meaning" : "Before You Know it"],
		["abbreviation" : "BBSD", "meaning" : "Be Back Soon Darling", "tags" : "Romance"],
		["abbreviation" : "BCNU", "meaning" : "Be Seeing You", "tags" : "Top24, Romance"],
		["abbreviation" : "BFF", "meaning" : "Best Friends Forever", "tags" : "Top24"],
		["abbreviation" : "BGWM", "meaning" : "Be Gentle With Me", "tags" : "Top24, Romance"],
		["abbreviation" : "BM&Y", "meaning" : "Between Me and You"],
		["abbreviation" : "BRB", "meaning" : "Be Right Back", "tags" : "Top24"],
		["abbreviation" : "BRT", "meaning" : "Be right There"],
		["abbreviation" : "BTAM", "meaning" : "Be that as it May"],
		["abbreviation" : "BTW", "meaning" : "By The Way or Bring The Wheelchair", "tags" : "Top24, Business"],
		["abbreviation" : "CEO", "meaning" : "Chief Executive Officer", "tags" : "Business"],
		["abbreviation" : "C-P", "meaning" : "Sleepy"],
		["abbreviation" : "CTN", "meaning" : "Cannot talk now"],
		["abbreviation" : "CUIMD", "meaning" : "See You In My Dreams", "tags" : "Romance"],
		["abbreviation" : "CUS", "meaning" : "See You Soon"],
		["abbreviation" : "CW2CU", "meaning" : "Can't wait to see you", "tags" : "Romance"],
		["abbreviation" : "CWOT", "meaning" : "Complete Waste of Time"],
		["abbreviation" : "CYA", "meaning" : "Cover Your Ass or See Ya", "tags" : "Top24"],
		["abbreviation" : "CYT", "meaning" : "See You Tomorrow"],
		["abbreviation" : "DBEYR", "meaning" : "Don't Believe Everything You Read"],
		["abbreviation" : "DC", "meaning" : "Don't Care", "tags" : "Top24"],
		["abbreviation" : "DBAU", "meaning" : "Doing business as usual"],
		["abbreviation" : "DGT", "meaning" : "Don't Go There"],
		["abbreviation" : "DILLIGAS", "meaning" : "Do I Look Like I Give A Sh** "],
		["abbreviation" : "E123", "meaning" : "Easy as 1, 2, 3"],
		["abbreviation" : "EM?", "meaning" : "Excuse Me?"],
		["abbreviation" : "EOD", "meaning" : "End Of Day"],
		["abbreviation" : "EOL", "meaning" : "End Of Life"],
		["abbreviation" : "EVA", "meaning" : "Ever"],
		["abbreviation" : "ETA", "meaning" : "Estimated Time of Arrival"],
		["abbreviation" : "F2F", "meaning" : "Face To Face", "tags" : "Romance"],
		["abbreviation" : "FC", "meaning" : "Fingers Crossed"],
		["abbreviation" : "FOAF", "meaning" : "Friend Of A Friend"],
		["abbreviation" : "FUD", "meaning" : "Fear, Uncertainty, And Disinformation"],
		["abbreviation" : "FYI", "meaning" : "For Your Information", "tags" : "Business"],
		["abbreviation" : "FWIW", "meaning" : "For What It's Worth", "tags" : "Top24"],
		["abbreviation" : "4ever", "meaning" : "Forever", "tags" : "Romance"],
		["abbreviation" : "4EVRYRS", "meaning" : "Forever Yours", "tags" : "Romance"],
		["abbreviation" : "GBU", "meaning" : "God Bless Yu"],
		["abbreviation" : "GD", "meaning" : "Good"],
		["abbreviation" : "GG", "meaning" : "Good Game (online gaming)"],
		["abbreviation" : "GR8", "meaning" : "Great", "tags" : "Top24"],
		["abbreviation" : "GTG", "meaning" : "Good To Go or Got To Go"],
		["abbreviation" : "((H))", "meaning" : "Hug", "tags" : "Romance"],
		["abbreviation" : "H&K", "meaning" : "Hugs And Kisses", "tags" : "Romance"],
		["abbreviation" : "HAK", "meaning" : "Hugs And Kisses"],
		["abbreviation" : "HUB", "meaning" : "Head Up Butt", "tags" : "Top24"],
		["abbreviation" : "HTH", "meaning" : "Hope This Helps", "tags" : "Business"],
		["abbreviation" : "HUYA", "meaning" : "Head Up Your Ass"],
		["abbreviation" : "HV", "meaning" : "Have"],
		["abbreviation" : "HW", "meaning" : "Homework"],
		["abbreviation" : "ICLWYL", "meaning" : "I Can't Live Without Your Love", "tags" : "Romance"],
		["abbreviation" : "IDC", "meaning" : "I Don't Care"],
		["abbreviation" : "IDK", "meaning" : "I Don't Know"],
		["abbreviation" : "ILU", "meaning" : "I Love You"],
		["abbreviation" : "ILY", "meaning" : "I Love You"],
		["abbreviation" : "IMO", "meaning" : "In My Opinion", "tags" : "Business"],
		["abbreviation" : "IMHO", "meaning" : "In My Humble Opinion", "tags" : "Top24"],
		["abbreviation" : "ImT14U", "meaning" : "I'm The One For You", "tags" : "Romance"],
		["abbreviation" : "IMU", "meaning" : "I Miss You"],
		["abbreviation" : "IRL", "meaning" : "In Real Life"],
		["abbreviation" : "ISO", "meaning" : "In Search Of"],
		["abbreviation" : "IU2U", "meaning" : "It's Up To You", "tags" : "Business"],
		["abbreviation" : "JK", "meaning" : "Just Kidding"],
		["abbreviation" : "JC", "meaning" : "Just Checking"],
		["abbreviation" : "JFF", "meaning" : "Just For Fun"],
		["abbreviation" : "JIC", "meaning" : "Just In Case"],
		["abbreviation" : "JTLYK", "meaning" : "Just To Let You Know"],
		["abbreviation" : "K", "meaning" : "OK or Is That OK?"],
		["abbreviation" : "KFY", "meaning" : "Kiss For You"],
		["abbreviation" : "KIT", "meaning" : "Keep In Touch", "tags" : "Romance"],
		["abbreviation" : "KMeQk", "meaning" : "Kiss Me Quick", "tags" : "Romance"],
		["abbreviation" : "KMN", "meaning" : "Kill Me Now"],
		["abbreviation" : "KPC", "meaning" : "Keeping Parents Clueless"],
		["abbreviation" : "L8R", "meaning" : "Later", "tags" : "Top24"],
		["abbreviation" : "LCH", "meaning" : "Lunch", "tags" : "Business"],
		["abbreviation" : "LMK", "meaning" : "Let Me Know", "tags" : "Business"],
		["abbreviation" : "LMAO", "meaning" : "Laughing My Ass Off", "tags" : "Top24"],
		["abbreviation" : "LMK", "meaning" : "Let Me Know"],
		["abbreviation" : "LOL", "meaning" : "Laughing Out Loud or Lots Of Love or Living On Lipitor", "tags" : "Top24"],
		["abbreviation" : "LUV", "meaning" : "Love", "tags" : "Romance"],
		["abbreviation" : "Luv Ya", "meaning" : "Love You", "tags" : "Romance"],
		["abbreviation" : "LYLAS", "meaning" : "Love You Like A Sister"],
		["abbreviation" : "MD", "meaning" : "Managing Director", "tags" : "Business"],
		["abbreviation" : "MHOTY", "meaning" : "My Hat's Off To You"],
		["abbreviation" : "MOB", "meaning" : "Mobile", "tags" : "Business"],
		["abbreviation" : "MoF", "meaning" : "Male or Female"],
		["abbreviation" : "MSG", "meaning" : "Message", "tags" : "Business"],
		["abbreviation" : "MTFBWY", "meaning" : "May The Force Be With You"],
		["abbreviation" : "MTNG", "meaning" : "Meeting", "tags" : "Business"],
		["abbreviation" : "MYOB", "meaning" : "Mind Your Own Business"],
		["abbreviation" : "N-A-Y-L", "meaning" : "In A While"],
		["abbreviation" : "NAGI", "meaning" : "Not A Good Idea", "tags" : "Business"],
		["abbreviation" : "NAZ", "meaning" : "Name, Address, Zip"],
		["abbreviation" : "NC", "meaning" : "No Comment"],
		["abbreviation" : "NIMBY", "meaning" : "Not In My Backyard"],
		["abbreviation" : "NM", "meaning" : "Never Mind / Nothing Much"],
		["abbreviation" : "NP", "meaning" : "No Problem"],
		["abbreviation" : "NSFW", "meaning" : "Not Safe For Work"],
		["abbreviation" : "NTIM", "meaning" : "Not That It Matters"],
		["abbreviation" : "NUB", "meaning" : "New person to a site or game"],
		["abbreviation" : "NVM", "meaning" : "Never Mind"],
		["abbreviation" : "OATUS", "meaning" : "On A Totally Unrelated Subject"],
		["abbreviation" : "OIC", "meaning" : "Oh, I See"],
		["abbreviation" : "OMG", "meaning" : "Oh My God", "tags" : "Top24"],
		["abbreviation" : "OMW", "meaning" : "On My Way"],
		["abbreviation" : "OT", "meaning" : "Off Topic"],
		["abbreviation" : "OTL", "meaning" : "Out To Lunch", "tags" : "Top24"],
		["abbreviation" : "OTP", "meaning" : "On The Phone"],
		["abbreviation" : "P911", "meaning" : "Parent Alert"],
		["abbreviation" : "PAL", "meaning" : "Parents Are Listening"],
		["abbreviation" : "PAW", "meaning" : "Parents Are Watching"],
		["abbreviation" : "PIR", "meaning" : "Parent In Room"],
		["abbreviation" : "POS", "meaning" : "Parent Over Shoulder"],
		["abbreviation" : "POV", "meaning" : "Point Of View", "tags" : "Top24"],
		["abbreviation" : "PROP(S)", "meaning" : "Proper Respect or Proper Recognition"],
		["abbreviation" : "Q4U", "meaning" : "(I have a) Question For You"],
		["abbreviation" : "QIK", "meaning" : "Quick"],
		["abbreviation" : "QOTD", "meaning" : "Quote of the day"],
		["abbreviation" : "QSL", "meaning" : "Reply "],
		["abbreviation" : "QT", "meaning" : "Cutie", "tags" : "Romance"],
		["abbreviation" : "RBTL", "meaning" : "Read Between The Lines"],
		["abbreviation" : "RGDS", "meaning" : "Regards", "tags" : "Business"],
		["abbreviation" : "RN", "meaning" : "Right Now"],
		["abbreviation" : "ROFL", "meaning" : "Rolling On Floor Laughing"],
		["abbreviation" : "ROTFLMAO", "meaning" : "Rolling On The Floor Laughing My Ass Off"],
		["abbreviation" : "R.S.V.P", "meaning" : "Répondez, S'il Vous Plaît, which means \"Please reply.\""],
		["abbreviation" : "RT", "meaning" : "Real Time or ReTweet"],
		["abbreviation" : "RTFM", "meaning" : "Read The F***ing Manual"],
		["abbreviation" : "RTM", "meaning" : "Read The Manual"],
		["abbreviation" : "RU", "meaning" : "Are You"],
		["abbreviation" : "RUOK", "meaning" : "Are You Ok", "tags" : "Romance"],
		["abbreviation" : "SEP", "meaning" : "Someone Else's Problem"],
		["abbreviation" : "SH", "meaning" : "Sh** Happens"],
		["abbreviation" : "SITD", "meaning" : "Still In The Dark"],
		["abbreviation" : "SLAP", "meaning" : "Sounds Like A Plan"],
		["abbreviation" : "SMIM", "meaning" : "Send Me An Instant Message"],
		["abbreviation" : "SO", "meaning" : "Significant Other"],
		["abbreviation" : "SOL", "meaning" : "Sh** Out Of Luck or Sooner Or Later"],
		["abbreviation" : "STBY", "meaning" : "Sucks To Be You"],
		["abbreviation" : "STFU", "meaning" : "Shut The *Freak* Up"],
		["abbreviation" : "SWAK", "meaning" : "Sent With A Kiss", "tags" : "Top24"],
		["abbreviation" : "SWALK", "meaning" : "Sent With A Loving Kiss", "tags" : "Romance"],
		["abbreviation" : "TFH", "meaning" : "Thread From Hell"],
		["abbreviation" : "TIA", "meaning" : "Thanks In Advance", "tags" : "Business"],
		["abbreviation" : "THNX", "meaning" : "Thanks", "tags" : "Top24"],
		["abbreviation" : "THX", "meaning" : "Thanks", "tags" : "Business"],
		["abbreviation" : "TX", "meaning" : "Thanks"],
		["abbreviation" : "TKS", "meaning" : "Thanks"],
		["abbreviation" : "THKS", "meaning" : "Thanks"],
		["abbreviation" : "TLC", "meaning" : "Tender Loving Care", "tags" : "Top24"],
		["abbreviation" : "TMI", "meaning" : "Too Much Information"],
		["abbreviation" : "TOY", "meaning" : "Thinking Of You", "tags" : "Romance"],
		["abbreviation" : "TTYL", "meaning" : "Talk To You Later or Type To You Later", "tags" : "Top24"],
		["abbreviation" : "TYVM", "meaning" : "Thank You Very Much"],
		["abbreviation" : "2moro", "meaning" : "Tomorrow", "tags" : "Top24"],
		["abbreviation" : "2nite", "meaning" : "Tonight", "tags" : "Top24"],
		["abbreviation" : "UCMU", "meaning" : "You Crack Me Up"],
		["abbreviation" : "UGTBK", "meaning" : "You've Got To Be Kidding"],
		["abbreviation" : "UOK", "meaning" : "(Are) You OK?"],
		["abbreviation" : "UR", "meaning" : "Your / You Are"],
		["abbreviation" : "URW", "meaning" : "You Are Welcome"],
		["abbreviation" : "VBG", "meaning" : "Very Big Grin"],
		["abbreviation" : "VFM", "meaning" : "Value For Money"],
		["abbreviation" : "VGC", "meaning" : "Very Good Condition"],
		["abbreviation" : "VM", "meaning" : "Voice Mail"],
		["abbreviation" : "VSF", "meaning" : "Very Sad Face"],
		["abbreviation" : "W8", "meaning" : "Wait"],
		["abbreviation" : "WB", "meaning" : "Welcome Back"],
		["abbreviation" : "WEG", "meaning" : "Wicked Evil Grin"],
		["abbreviation" : "WOTTM", "meaning" : "What Time", "tags" : "Business"],
		["abbreviation" : "WTF", "meaning" : "What The F***", "tags" : "Top24"],
		["abbreviation" : "WYCM", "meaning" : "Will You Call Me?"],
		["abbreviation" : "WYWH", "meaning" : "Wish You Were Here"],
		["abbreviation" : "X", "meaning" : "Kiss"],
		["abbreviation" : "XLNT", "meaning" : "Excellent"],
		["abbreviation" : "XME", "meaning" : "Excuse Me"],
		["abbreviation" : "XOXO", "meaning" : "Hugs And Kisses", "tags" : "Romance"],
		["abbreviation" : "XYZ", "meaning" : "Examine your zipper"],
		["abbreviation" : "Y?", "meaning" : "Why?"],
		["abbreviation" : "YARLY", "meaning" : "Ya, really?"],
		["abbreviation" : "YD", "meaning" : "Yesterday"],
		["abbreviation" : "YTB", "meaning" : "You're The Best"],
		["abbreviation" : "Y2K", "meaning" : "You're Too Kind"],
		["abbreviation" : "Z", "meaning" : "Zero"],
		["abbreviation" : "Z%", "meaning" : "Zoo"],
		["abbreviation" : "ZH", "meaning" : "Sleeping Hour"],
		["abbreviation" : "ZOT", "meaning" : "Zero Tolerance"],
		["abbreviation" : "ZUP", "meaning" : "What's up?"]
]
do {
	let data = try JSONSerialization.data(withJSONObject: AbbreviationDatabase, options: .prettyPrinted)
	if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
		let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/Abbreviation.json"
		try string.write(toFile: filePath, atomically:true, encoding:String.Encoding.utf8.rawValue)
		print(filePath)
		print(string)
	}
} catch let error as NSError {
	
}
*/

// device_information.json 파일을 읽습니다.
// 장치 ID와 이름을 찾고, 해당 device 정보와 battery remaining time 정보가 있는지 확인합니다.
// 파일이 정상적으로 읽혀지는지를 확인할 수 있습니다.
// 필요한 정보가 모두 존재하는지 확인할 수 있습니다.
do {
    let dataURL = #fileLiteral(resourceName: "device_information.json")
    let deviceData = try Data(contentsOf: dataURL)
    let deviceObject = try JSONSerialization.jsonObject(with: deviceData, options: []) as! [String : Any]

    let deviceNames = deviceObject["platform"] as! [String : String]
    let deviceInformation = deviceObject["deviceInformation"] as! [String : Any]
    let remainingTimeInfo = deviceObject["remainingTimeInfo"] as! [String : Any]
    for (identifier, name) in deviceNames {
        if let _  = deviceInformation[name] {
        } else {
            print("Information: \(identifier)/\(name)")
        }
        if let _  = remainingTimeInfo[name] {
        } else {
            print("Battery: \(identifier)/\(name)")
        }
    }
    for (name, _) in deviceInformation {
        let values = [String](deviceNames.values)
        if values.contains(name) {
            
        } else {
            print("\(name)")
        }
    }
    for (name, _) in remainingTimeInfo {
        let values = [String](deviceNames.values)
        if values.contains(name) {
            
        } else {
            print("\(name)")
        }
    }
    
    print("Done")
} catch _ as NSError {
    
}
