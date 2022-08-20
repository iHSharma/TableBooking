//
//  TableBookingCell.swift
//  TableBookingApp
//
//  Created by Hitesh on 19/08/22.
//

import UIKit

class TableTimingCell: UICollectionViewCell {
    @IBOutlet weak var lbl_Time:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lbl_Time.layer.masksToBounds = false
        lbl_Time.layer.cornerRadius = 6
    }
}

class TableBookingCell: UITableViewCell {
    
    @IBOutlet weak var coll_TimeSlot:UICollectionView!
    @IBOutlet weak var coll_Height:NSLayoutConstraint!
    @IBOutlet weak var lbl_Title:UILabel!
    @IBOutlet weak var lbl_Desc:UILabel!
    @IBOutlet weak var lbl_Location:UILabel!
    @IBOutlet weak var lbl_Rating:UILabel!
    @IBOutlet weak var img_Icon:UIImageView!
    
    var arr_timings:[NSDictionary] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 2, left: 4, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: self.bounds.width/4, height: self.bounds.width/3)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 6
        self.coll_TimeSlot.collectionViewLayout = layout
        self.coll_TimeSlot.delegate=self
        self.coll_TimeSlot.dataSource=self
        self.coll_TimeSlot.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setCollectionViewDataSourceDelegate(row: Int) {
        self.coll_TimeSlot.tag = row
        self.coll_TimeSlot.reloadData()
    }
    
    deinit {
        self.coll_TimeSlot.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" { // make a dynamic size
            if let newVal = change?[.newKey] {
                let newSize = newVal as! CGSize
                self.coll_Height.constant = newSize.height
            }
        }
    }
    
    func getTimingAvailable(timing:[NSDictionary]) {
        
        //checking timing slots
        if timing.count > 0 {
            self.arr_timings = timing
        }
    }
}

//MAR:- Timing slots Collection view delegates and datasources
extension TableBookingCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arr_timings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TableTimingCell
        let dict = self.arr_timings[indexPath.row]
        cell.lbl_Time.text = dict.value(forKey: "time") as? String
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 74, height: 30)
    }
    
}
