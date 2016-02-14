//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, FiltersViewControllerDelegate, UIScrollViewDelegate {

    var businesses: [Business]!
    var searchController : UISearchController!
    var searchContent : String!
    var isMoreDataLoading = false
    var offsetCounter = 10
    var currentCategories: [String]!
    var currentTerm: String!
    var loadingMoreView:InfiniteScrollActivityView?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        // Navigation bar color
        let nav = self.navigationController?.navigationBar
        nav!.barTintColor = UIColor(red:0.7, green:0.03, blue:0.02, alpha:1.0)        
        // Configure Search bar
        self.searchController = UISearchController(searchResultsController:  nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.navigationItem.titleView = searchController.searchBar
        self.definesPresentationContext = true
        self.searchController.searchBar.placeholder = "Restaurants"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120

        currentTerm = "Restaurants"
        Business.searchWithTerm(currentTerm, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        })
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        currentTerm = searchController.searchBar.text
        offsetCounter = 0
        requestData()
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.text = ""
        searchController.searchBar.resignFirstResponder()
    }
    
    func requestData() {
            Business.searchWithTerm(offsetCounter, term: currentTerm, sort: YelpSortMode.Distance, categories: currentCategories ?? nil, deals: nil, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        if businesses == nil {
            return 0
        } else {
            return businesses!.count
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "map") {
            print("Prepare for segue")
            let navigationController = segue.destinationViewController as! UINavigationController
            let mapController = navigationController.topViewController as! DetailViewController
            mapController.businessToDisplay = businesses
        }
        if segue.identifier == "settings" {
            print("Prepare for segue of settings")
            let navigationController = segue.destinationViewController as! UINavigationController
            let filtersViewController = navigationController.topViewController as! FiltersViewController
            filtersViewController.delegate = self
        }
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        currentCategories = filters["categories"] as? [String]
        Business.searchWithTerm(0, term: "Restaurants", sort: YelpSortMode.Distance, categories: currentCategories ?? nil, deals: nil, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        })
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                isMoreDataLoading = true
                loadMoreData()
            }
        }
    }
    
    func loadMoreData() {
        offsetCounter += 10
        Business.searchWithTerm(offsetCounter, term: "Restaurants", sort: YelpSortMode.Distance, categories: currentCategories ?? nil, deals: nil, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses.appendContentsOf(businesses)
            self.isMoreDataLoading = false;
            self.loadingMoreView!.stopAnimating()
            self.tableView.reloadData()
        })
    }

}
