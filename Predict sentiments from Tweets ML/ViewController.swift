//
//  ViewController.swift
//  Predict sentiments from Tweets ML
//
//  Created by Dhawal Mahajan on 05/03/19.
//  Copyright © 2019 Dhawal Mahajan. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
   let swifter = Swifter(consumerKey: "vSJHrkp0gInPt1RlN9qu442Gl", consumerSecret: "y2Ota3dsy27HjPBOrTJz4hmXbvfdkVM9aaSXPsPpIpzYCTY42e")
    let tweetCount = 100
    let sentimentClassifier = TweetSentimentClassifier()
    @IBOutlet var feelingTextfield: UITextField!
    @IBOutlet var smileyLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
//        let prediciton = try! sentimentClassifier.prediction(text: "@Apple sucks")
//        print(prediciton.label)
      
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func predictButtonPressed(_ sender: UIButton) {
      fetchTweets()
    }
    
    func fetchTweets() {
        if let searchText = feelingTextfield.text {
            swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended ,success: { (result, metadata) in
                var tweets = [TweetSentimentClassifierInput]()
                for i in 0..<self.tweetCount {
                    if let tweet = result[i]["full_text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                self.makePredictions(with: tweets)
            }) { (error) in
                print(error)
            }
        }
    }
    
    func makePredictions(with tweets: [TweetSentimentClassifierInput])  {
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            var sentimentScore = 0
            for pred in predictions {
                if pred.label == "Pos" {
                    sentimentScore += 1
                } else if pred.label == "Neg" {
                    sentimentScore -= 1
                }
            }
            updateUI(with: sentimentScore)
        }
        catch {
            print(error)
        }
    }
    
    func updateUI(with sentimentScore: Int) {
        if sentimentScore > 20 {
            self.smileyLabel.text = "🥰"
        } else if sentimentScore > 10 {
            self.smileyLabel.text = "😄"
        } else if sentimentScore > 0 {
            self.smileyLabel.text = "🙂"
        } else if sentimentScore == 0 {
            self.smileyLabel.text = "🙁"
        } else if sentimentScore > -10 {
            self.smileyLabel.text = "😔"
        } else if sentimentScore > -20 {
            self.smileyLabel.text = "😡"
        } else {
            self.smileyLabel.text = "🤮"
        }
    }
}

