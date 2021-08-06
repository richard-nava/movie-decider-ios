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
       //mainVC.addMovies(AddMovieButton)
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a Movie to your Watchlist", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Movie", style: .default) { (action) in
            // when user clicks Add item button to UIAlert
            
            
            let newMovie = Movie(context: self.context)
            newMovie.title = textField.text!
            newMovie.watched = false
            self.movieArray.append(newMovie)
            
            // self.defaults.set(self.itemArray, forKey: "TodoListArray")
            
            self.saveMovies()

    }
    
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            print(alertTextField.text as Any)
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
        // Let listener know
        let name = Notification.Name(rawValue: addedNewMovie)
        NotificationCenter.default.post(name: name, object: nil)
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
        let name = Notification.Name(rawValue: movieStatusChanged)
        NotificationCenter.default.post(name: name, object: nil)
        changeMovieStatus(movie: movieArray[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    // delete movie
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let name = Notification.Name(rawValue: movieDeleted)
        NotificationCenter.default.post(name: name, object: nil)
        
        if editingStyle == .delete {
            context.delete(movieArray[indexPath.row])
            movieArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            saveMovies()
        } else if editingStyle == .insert {
            
        }
        
    }
    
    func saveMovies() {
        _ = PropertyListEncoder()
        
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
        tableView.reloadData()
    }
    
    func changeMovieStatus(movie: Movie){
        movie.watched = !movie.watched
        saveMovies()
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
