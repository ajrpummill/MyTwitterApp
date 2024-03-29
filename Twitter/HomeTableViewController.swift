//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Anthony Pummill on 10/27/19.
//  Copyright © 2019 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {

    var tweetArray = [NSDictionary]()
    var numOfTweets: Int!
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
        loadTweets()
        
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
    
    }
    
    @objc func loadTweets()
    {
        numOfTweets = 20
        let homeURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParameters = ["count": numOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: homeURL, parameters: myParameters, success:
            { (tweets: [NSDictionary]) in
                self.tweetArray.removeAll()
                for tweet in tweets
                {
                    self.tweetArray.append(tweet)
                }
                self.tableView.reloadData()
                self.myRefreshControl.endRefreshing()
            }, failure:
            { (Error) in
            print("Could not get tweets!")
            })
    }
    
    func loadMoreTweets()
    {
        let homeURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numOfTweets = numOfTweets + 20
        let myParameters = ["count": numOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: homeURL, parameters: myParameters, success:
        { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            for tweet in tweets
            {
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
        }, failure:
        { (Error) in
        print("Could not get tweets!")
        })
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if indexPath.row + 1 == tweetArray.count
        {
            loadMoreTweets()
        }
    }
    
    @IBAction func onLogout(_ sender: Any)
    
    {
        print("See you later!")
        
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetsCellTableViewCell", for: indexPath) as! TweetsCellTableViewCell
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        
        cell.userNameLabel.text = (user["name"] as! String)
        cell.tweetContent.text = (tweetArray[ indexPath.row]["text"] as! String)
        let imageUrl = URL(string: (user["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageUrl!)
        if let imageData = data
           {
              cell.profileImageView.image = UIImage(data: imageData)
           }
        return cell
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }

   
}
