//
//  ViewController.swift
//  MovieDecider
//
//  Created by Richard Centeno on 7/29/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var DecideButton: UIButton!
    @IBOutlet weak var ViewMovies: UIBarButtonItem!
    @IBOutlet weak var AddMovieButton: UIBarButtonItem!
    
    var movieArray = [Movie]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadMovies()
    }

    @IBAction func decideMovie(_ sender: Any) {
        print("Deciding movie...")
    }
    
    
    @IBAction func addMovies(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a Movie to your Watchlist", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Movie", style: .default) { (action) in
            // when user clicks Add item button to UIAlert
            
            
            let newMovie = Movie(context: self.context)
            newMovie.title = textField.text!
            newMovie.watched = false
//            self.movieArray.append(newMovie)
            
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

    }
    
    func saveMovies() {
        let encoder = PropertyListEncoder()
        
        do{
            try context.save()
            print("Movie Saved!")
        } catch{
            print("Error encoding context \(error)")
        }
        //self.tableView.reloadData()
    }
    
    func loadMovies() {
        let request : NSFetchRequest<Movie> = Movie.fetchRequest()
        do{
            movieArray = try context.fetch(request)
            
        } catch{
            print("Error in request \(error)")
        }
    }
    
    @IBAction func movieListButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "GoToMovieList", sender: self)
    }
    
}

