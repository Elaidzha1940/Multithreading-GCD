//
//  ViewController.swift
//  Multithreading | GDC
//
//  Created by Elaidzha Shchukin on 31.08.2022.
//

import UIKit

///31.08
 
class FriendController: UIViewController {
 
  // Create tableView IBOutlet
  @IBOutlet weak var tableView: UITableView!
 
  // Create group
  let parsingGroup = DispatchGroup()
 
  // Create queues
  let storeQueue = DispatchQueue.global(qos: .userInteractive)
  let parsingQueue = DispatchQueue.init(label: "parsing", attributes: .concurrent)
 
  // Create arrays
  var userNames:[String] = []
  var userDates:[String] = []
  var userImages:[String] = []
  var userMessages:[String] = []
 
  // Create subclass SpinnerViewController - class added new view in general view
  let childView = SpinnerViewController()
 
  override func viewDidLoad() {
    tableView.dataSource = self
    tableView.delegate = self
 
    moveIndicator()
    checkStore()
  }
 
  // Create method stopIndicator - it stopped spinner
  private func stopIndicator(){
    self.childView.willMove(toParent: nil)
    self.childView.view.removeFromSuperview()
    self.childView.removeFromParent()
  }
 
 
  // Create method moveIndicator - it add spinner view to general view
  private func moveIndicator() {
    addChild(childView)
    childView.view.frame = view.frame
    view.addSubview(childView.view)
    childView.didMove(toParent: self)
  }
 
  // Create method checkStore - it check is plist file exist or not
  private func checkStore()  {
    storeQueue.async {
      if let path = Bundle.main.path(forResource: "UsersData", ofType:"plist"){
        let dict = NSDictionary(contentsOfFile: path) as! [String: Any]
        self.appendDateFromPlistConcurrent(dict)
      }
    }
  }
 
  // Create method appendDateFromPlistConcurrent - it append data to arrays conrurrently, but you need using group's metod
  private func appendDateFromPlistConcurrent(_ dict: [String: Any]) {
    parsingGroup.enter()
    parsingQueue.async {
      sleep(2)
      self.userNames = dict["allNames"] as! Array<String>
      self.parsingGroup.leave()
    }
 
    parsingGroup.enter()
    parsingQueue.async {
      sleep(2)
      self.userDates = dict["allDates"] as! Array<String>
      self.parsingGroup.leave()
    }
 
    parsingGroup.enter()
    parsingQueue.async {
      sleep(2)
      self.userImages = dict["allImages"] as! Array<String>
      self.parsingGroup.leave()
    }
 
    parsingGroup.enter()
    parsingQueue.async {
      sleep(2)
      self.userMessages = dict["allMessages"] as! Array<String>
      self.parsingGroup.leave()
    }
    parsingGroup.wait()
  }
 
  // Create method clearRow - it clear text labels
  private func clearRow(_ cell: FriendCell) {
    cell.nameUser.text = ""
    cell.dateMessage.text = ""
    cell.messageUser.text = ""
  }
}
 
extension FriendController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
}
 
 
extension FriendController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 9
  }
 
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as? FriendCell else { return  UITableViewCell() }
 
    clearRow(cell)
 
    // Create group notify - when group is completed then cell get rows
    parsingGroup.notify(queue: .main) {
      cell.nameUser.text = self.userNames[indexPath.row]
      cell.imageUser.image = UIImage(named: self.userImages[indexPath.row])
      cell.dateMessage.text = self.userDates[indexPath.row]
      cell.messageUser.text = self.userMessages[indexPath.row]
 
      // Stop spinner work
      self.stopIndicator()
    }
 
    return cell
  }
 
 
}
 
 
class SpinnerViewController: UIViewController {
 
  // Create UI elements
  let rectangleView = UIView()
  let spinner = UIActivityIndicatorView(style: .large)
  let label = UILabel()
 
  override func loadView() {
    // View settings
    view = UIView()
    view.backgroundColor = UIColor(white: 0.6, alpha: 0.7)
 
    // RectangleView settings
    rectangleView.backgroundColor =  colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    rectangleView.layer.cornerRadius = 13
    rectangleView.backgroundColor = UIColor(white: 0.3, alpha: 0.4)
    view.addSubview(rectangleView)
    rectangleView.translatesAutoresizingMaskIntoConstraints = false
    rectangleView.widthAnchor.constraint(equalToConstant: 150).isActive = true
    rectangleView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    rectangleView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    rectangleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
 
    // Spinner settings
    spinner.translatesAutoresizingMaskIntoConstraints = false
    spinner.startAnimating()
    rectangleView.addSubview(spinner)
    spinner.color =  colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
 
    // Label settings
    label.text = "Loading chat..."
    label.textColor =  colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    label.font = UIFont(name: "Arial", size: 22)
    rectangleView.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
 
    label.centerXAnchor.constraint(equalTo: rectangleView.centerXAnchor, constant: 0).isActive = true
    label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 10).isActive = true
  }
}
