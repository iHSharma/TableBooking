//
//  ViewController.swift
//  TableBookingApp
//
//  Created by Hitesh on 19/08/22.
//

import UIKit

struct Restaurant {
    var title:String?
    var desc:String?
    var location:String?
    var rating:String?
    var arr_Timings:[NSDictionary]?
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tbl_Tables:UITableView!
    
    var semaphore = DispatchSemaphore (value: 0)
    var arr_Resturants:[NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        DispatchQueue.global(qos: .background).async {
            /* Retrieve all the booking restaurants list in background */
            self.fetchBookings()
            DispatchQueue.main.async {
                // Update the tableview after data fetched
                self.tbl_Tables.reloadData()
                
            }
        }
        
    }
    
    //MARK:- Fetch Booking details
    func fetchBookings() {
        
        let parameters = [
            [
                "key": "date",
                "value": "2021-4-16",
                "type": "text"
            ],
            [
                "key": "time",
                "value": "10.30",
                "type": "text"
            ],
            [
                "key": "latitude",
                "value": "53.798407",
                "type": "text"
            ],
            [
                "key": "longitude",
                "value": "-1.548248",
                "type": "text"
            ],
            [
                "key": "person",
                "value": "2",
                "type": "text"
            ]] as [[String : Any]]
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""
        var _: Error? = nil
        for param in parameters {
            if param["disabled"] == nil {
                let paramName = param["key"]!
                body += "--\(boundary)\r\n"
                body += "Content-Disposition:form-data; name=\"\(paramName)\""
                if param["contentType"] != nil {
                    body += "\r\nContent-Type: \(param["contentType"] as! String)"
                }
                let paramType = param["type"] as! String
                if paramType == "text" {
                    let paramValue = param["value"] as! String
                    body += "\r\n\r\n\(paramValue)\r\n"
                } else {
                    
                    do {
                        let paramSrc = param["src"] as! String
                        let fileData = try NSData(contentsOfFile:paramSrc, options:[]) as Data
                        let fileContent = String(data: fileData, encoding: .utf8)!
                        body += "; filename=\"\(paramSrc)\"\r\n"
                            + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
                    } catch {
                        print(error)
                    }
                    
                }
            }
        }
        
        body += "--\(boundary)--\r\n";
        let postData = body.data(using: .utf8)
        
        var request = URLRequest(url: URL(string: "https://igmiweb.com/gladdenhub/Api/search_table")!,timeoutInterval: Double.infinity)
        request.addValue("NB10SKS20AS30", forHTTPHeaderField: "x-api-key")
        request.addValue("ci_session=411297411ea2211e3b73cc5f96c79f55ad003e1e", forHTTPHeaderField: "Cookie")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                self.semaphore.signal()
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                let arr_listed = json?["listed"] as? [NSDictionary]
                
                //checking the data is nil or not
                if let arr_List = arr_listed {
                    self.arr_Resturants = arr_List
                } else {
                    self.arr_Resturants = []
                }
                
            } catch {
                print("erroMsg")
            }
            self.semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
    }
    
}

//MARK:- Booking Tableview Delegates and datasources
extension ViewController:UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Resturants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableBookingCell
        
        let dict = self.arr_Resturants[indexPath.row]
        cell.lbl_Title.text = dict.value(forKey: "business_name") as? String
        cell.lbl_Desc.text = dict.value(forKey: "description") as? String
        cell.lbl_Location.text = dict.value(forKey: "address") as? String
        cell.lbl_Rating.text = dict.value(forKey: "rating") as! String + "/" + "5"
        cell.img_Icon?.imageFromServerURL(urlString:  dict.value(forKey: "image") as? String ?? "", PlaceHolderImage: UIImage.init(named: "placeholder")!)
        
        tableView.separatorStyle = .none
        // passing available timings here
        cell.getTimingAvailable(timing: dict.value(forKey: "time_available") as! [NSDictionary])
        
        // refreshing layout
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? TableBookingCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(row: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//URL to image loader extension
extension UIImageView {
    
    public func imageFromServerURL(urlString: String, PlaceHolderImage:UIImage) {
        if self.image == nil{
            self.image = PlaceHolderImage
        }
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error ?? "No Error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
        }).resume()
    }}
