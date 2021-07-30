//
//  MovieListController.swift
//  MovieDecider
//
//  Created by Richard Centeno on 7/29/21.
//

import Foundation
import UIKit
import CoreData

class MovieListController:UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var AddMovieButton: UIBarButtonItem!
    
    var mainVC = ViewController()
    var movieArray = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMovies()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addMovies(_ sender: UIBarButtonItem) {
        mainVC.addMovies(AddMovieButton)
    }
    
    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        let cell = UITableViewCell(style: .default, reuseIdentifier: "MovieCell")
        let movie = movieArray[indexPath.row]
        
        cell.textLabel?.text = movie.title
        cell.accessoryType = movie.watched ? .checkmark : .none
        return cell
    }
    
    //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        movieArray[indexPath.row].watched = !movieArray[indexPath.row].watched
        
        saveMovies()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func saveMovies() {
        let encoder = PropertyListEncoder()
        
        do{
            try context.save()
            print("Movie Saved!")
        } catch{
            print("Error encoding context \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadMovies(with request: NSFetchRequest<Movie> = Movie.fetchRequest()) {
        let request : NSFetchRequest<Movie> = Movie.fetchRequest()
        do{
            movieArray = try context.fetch(request)
            
        } catch{
            print("Error in request \(error)")
        }
    }
    
}

extension MovieListController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Movie> = Movie.fetchRequest()
        
        request.predicate = NSPredicate(format: "title CONTAINS %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadMovies(with: request)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadMovies()
            
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}
