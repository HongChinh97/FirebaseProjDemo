//
//  ViewController.swift
//  FirebaseProjDemo
//
//  Created by admin on 1/17/19.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import Firebase


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var artistNameTextField: UITextField!
    @IBOutlet weak var artistGenreTextField: UITextField!
    @IBOutlet weak var labelMessenger: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var refArtists: DatabaseReference!
    var artistList = [ArtistModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        FirebaseApp.configure()
        refArtists = Database.database().reference().child("artists")
        fetchingValue()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func fetchingValue() {
        refArtists.observe(DataEventType.value, with: { (snapshot) in
            //if the reference have some values
            if snapshot.childrenCount > 0 {
            //clearing the list
                self.artistList.removeAll()
                //iterating through all the values
                for artist in snapshot.children.allObjects as! [DataSnapshot] {
                // getting values
                    let artistObject = artist.value as? [String: AnyObject]
                    let artistName = artistObject?["artistName"]
                    let artistGenre = artistObject?["artistGenre"]
                    let artistId = artistObject?["id"]
                    //creating artist object with model and fetched values
                    let artist = ArtistModel(id: artistId as? String, name: artistName as? String, genre: artistGenre as? String)
                    //appending it to list
                    self.artistList.append(artist)
                }
                //reloading the tableView
                self.tableView.reloadData()
            }
        })
    }

    //MARK: write operation - Firebase Realtime Database
    @IBAction func btnAddArtist(_ sender: UIButton) {
        //and also getting the generated key
        let key = refArtists.childByAutoId().key
        if (artistNameTextField.text == "" || artistGenreTextField.text == "") {
            labelMessenger.text = "Please Insert Infomation"
        } else {
        //creating artist with the given values
            let artist = [
                "id" : key,
            "artistName": artistNameTextField.text! as String,
            "artistGenre": artistGenreTextField.text! as String
            ]
            //adding the artist inside the generated unique key
            refArtists.child(key!).setValue(artist)
            //displaying messeger
            labelMessenger.text = "Artist Added"
        }
        artistNameTextField.text = ""
        artistGenreTextField.text = ""
    }
    
    @IBAction func cancelBtn(_ sender: UIButton) {
        artistGenreTextField.text = ""
        artistNameTextField.text = ""
        labelMessenger.text = ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artistList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = artistList[indexPath.row].name
        cell.detailTextLabel?.text = artistList[indexPath.row].genre
        return cell
    }
    //MARk: edit operation - firebase realtime database
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //getting the selected artist
        let artist = artistList[indexPath.row]
        //building an alert
        let alertCotroller = UIAlertController(title: artist.name, message: "Give new values to update", preferredStyle: .alert)
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            //Getting artist id
            let id = artist.id
            //Getting new values
            let name = alertCotroller.textFields![0].text
            let genre = alertCotroller.textFields![1].text
            if (name == artist.name || genre == artist.genre) {
                self.labelMessenger.text = "Nothing To Do"
            } else {
                //calling the update method to update artist
                self.updateArtist(id: id!, name: name!, genre: genre!)
            }
        }
        
        //The cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in }
        //the delete action
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (_) in
        //Delete artist
        self.deleteartist(id: artist.id!)
        }
         //Add two textfields to alert
        alertCotroller.addTextField(configurationHandler: { (textField) in
            textField.text = artist.name
        })
        alertCotroller.addTextField(configurationHandler: { (textField) in
            textField.text = artist.genre
        })
        //adding action
        alertCotroller.addAction(confirmAction)
        alertCotroller.addAction(deleteAction)
        alertCotroller.addAction(cancelAction)
        //presenting dialog
        present(alertCotroller, animated: true, completion: nil)
    }
    //MARK: -update operation - Firebase Realtime Database
    func updateArtist(id: String, name: String, genre: String) {
        //creating artist with the new given values
        let artist = [
            "id": id,
            "artistName": name,
            "artistGenre": genre
        ]
        //updating the artist using the key of the artist
        refArtists.child(id).setValue(artist)
        //displaying messenger
        labelMessenger.text = "Artist Updated"
    }
    
    //MARK: -Delete operation -Firebase Realtime database
    func deleteartist(id: String) {
        refArtists.child(id).setValue(nil)
        //Display Message
        labelMessenger.text = "Artist Deleted"
    }
    
}
