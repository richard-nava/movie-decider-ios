//
//  ViewController.swift
//  MovieDecider
//
//  Created by Richard Centeno on 7/29/21.
//

import UIKit
import CoreData

let movieStatusChanged = "co.navadev.changeMovieStatus"
let addedNewMovie = "co.navadev.addedNewMovie"
let movieDeleted = "co.navadev.moviedDeleted"

class ViewController: UIViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var DecideButton: UIButton!
    @IBOutlet weak var ViewMovies: UIBarButtonItem!
    @IBOutlet weak var AddMovieButton: UIBarButtonItem!
    @IBOutlet weak var TitleLabel: UILabel!
    
    let updateStatus = Notification.Name(rawValue: movieStatusChanged)
    let newMovie = Notification.Name(rawValue: addedNewMovie)
    let deletedMovie = Notification.Name(rawValue: movieDeleted)

    
    var timer:Timer?
    var timeLeft = 4.0
    
    var movieArray = [Movie]()
    var unwatchedMovies = [Movie]()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadMovies()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        loadMovies()
//    }

    @IBAction func decideMovie(_ sender: Any) {
        
        
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(decideNewTitle), userInfo: nil, repeats: true)

        timeLeft = 4
        
        print(unwatchedMovies)
        
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
        _ = PropertyListEncoder()
        
        do{
            try context.save()
            print("Movie Saved!")
        } catch{
            print("Error encoding context \(error)")
        }
        //self.tableView.reloadData()
    }
    
    @objc func loadMovies() {
        let request : NSFetchRequest<Movie> = Movie.fetchRequest()
        do{
            movieArray = try context.fetch(request)
            
        } catch{
            print("Error in request \(error)")
        }
    }
    
    func createUnwatchedList(){
        
        unwatchedMovies = []
        for movie in movieArray {
            if movie.watched == false {
                unwatchedMovies.append(movie)
            }
        }
    }
    
    @objc func decideNewTitle()
     {
        createUnwatchedList()
        timeLeft -= 0.3
        TitleLabel.text = unwatchedMovies.randomElement()?.title
        
        if timeLeft <= 0 {
                timer?.invalidate()
                timer = nil
            }
     }
    
    @IBAction func movieListButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "GoToMovieList", sender: self)
    }
    
    // set up a listener for changes in the movie array (managed object context)
    
    func createObservers(){
        
        // Movie Watched Status was changed
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadMovies), name: updateStatus, object: nil)
        
        // Movie was added from list
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadMovies), name: newMovie, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadMovies), name: deletedMovie, object: nil)
        
    }
}

