//
//  KTKarwaBusPlanDirectionListViewController.swift
//  KarwaRide
//
//  Created by Apple on 02/02/22.
//  Copyright © 2022 Karwa. All rights reserved.
//

import UIKit
import GoogleMaps

class KTKarwaBusPlanDirectionListViewController: KTBaseViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var mapView : GMSMapView!

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var timeLabel: UIView!
    @IBOutlet weak var earlierBtn: UIButton!
    @IBOutlet weak var laterBtn: UIButton!
    @IBOutlet weak var timeRangeLabel: UILabel!

    var kTableHeaderHeight:CGFloat = 420.0
    var headerView: UIView!
    var itenary: Itinerary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.estimatedRowHeight = 80
        tblView.rowHeight = UITableViewAutomaticDimension
        //setupViews()
        // Do any additional setup after loading the view.
        headerView = tblView.tableHeaderView
        tblView.tableHeaderView = nil
        tblView.addSubview(headerView)
        tblView.contentInset = UIEdgeInsets(top: kTableHeaderHeight, left: 0, bottom: 0, right: 0)
        tblView.contentOffset = CGPoint(x: 0, y: -kTableHeaderHeight)
        self.addMap()
        
        var i = 0
        for item in itenary?.legs ?? [Leg]() {
            
            let showDestination = i == (itenary?.legs?.count ?? 0) - 1 ? true : false
            if let routeColor = item.routeColor{
                self.addPointsOnMap(points: item.legGeometry?.points ?? "", mode: item.mode ?? "WALK", color: UIColor(hexString: "#"+routeColor), showDestination: showDestination)
            } else {
                self.addPointsOnMap(points: item.legGeometry?.points ?? "", mode: item.mode ?? "WALK", color: UIColor.primary, showDestination: showDestination)
            }
            
            i += 1
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    public func addPointsOnMap(points: String, mode: String, color: UIColor, showDestination: Bool) {
      if(!points.isEmpty) {
        // create path for router
          if let path = GMSMutablePath(fromEncodedPath: points) {
              let polyline = GMSPolyline.init(path: path)
              polyline.strokeWidth = 3
              polyline.strokeColor = color
              
              
              // draw pickup and destimation pins from path
              let pickup = path.coordinate(at:0)
              let dropoff = path.coordinate(at:path.count()-1)
              
              if mode == "Walk"{
                  let styles = [GMSStrokeStyle.solidColor(color), GMSStrokeStyle.solidColor(UIColor.clear), GMSStrokeStyle.solidColor(UIColor.clear), GMSStrokeStyle.solidColor(color)]
                  let lengths = [0.5, 0.5] // Play with this for dotted line
                  polyline.spans = GMSStyleSpans(polyline.path!, styles, lengths as [NSNumber], .rhumb)
                  addMarkerOnMap(location: pickup, image: UIImage(named: "BookingMapDirectionPickup")!)
              } else {
                  addMarkerOnMap(location: pickup, image: UIImage(named: "stop")!)
              }
              
              polyline.map = self.mapView
              
              if showDestination {
                  addMarkerOnMap(location: dropoff, image: UIImage(named: "stop")!)
              } else {
                  addMarkerOnMap(location: dropoff, image: UIImage(named: "dropoff_pin")!)
              }
              
              let inset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
              
      //        // focus to fit all the point including path, pick and destination in map camera
              focusMapToFitRoute(pointA: path.coordinate(at: 0),
                                 pointB: path.coordinate(at: path.count()-1),
                                 path: path,
                                 inset: inset)
                
          }
          
      }
    }
    
    func addMarkerOnMap(location: CLLocationCoordinate2D, image: UIImage) {
        let marker = GMSMarker()
        marker.position = location
        marker.icon = image
        marker.groundAnchor = CGPoint(x:0.5,y:1)
        marker.map = self.mapView
    }
    
    func focusMapToFitRoute(pointA: CLLocationCoordinate2D, pointB: CLLocationCoordinate2D, path: GMSMutablePath, inset: UIEdgeInsets) {

      if pointA.latitude == 0 && pointA.longitude == 0 {
        return
      }

      //var bounds: GMSCoordinateBounds

      let c1 = pointA // swiftlint:disable:this identifier_name
      let c2 = pointB // swiftlint:disable:this identifier_name

      let mapCenter = CLLocationCoordinate2DMake((c1.latitude + c2.latitude)/2, (c1.longitude + c2.longitude)/2)

      var bounds = GMSCoordinateBounds.init(coordinate: mapCenter, coordinate: mapCenter)

      bounds = bounds.includingCoordinate(c1)
      bounds = bounds.includingCoordinate(c2)
      bounds = bounds.includingPath(path)

      if let mutableCamera: GMSMutableCameraPosition = self.mapView.camera.mutableCopy() as? GMSMutableCameraPosition {
        mutableCamera.target = mapCenter
        self.mapView.camera = mutableCamera
        self.mapView.animate(with: GMSCameraUpdate.fit(bounds, with: inset))
      }
    }
    
    func setupViews() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        self.view.addGestureRecognizer(panGesture)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }
    
    func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: -kTableHeaderHeight, width: tblView.bounds.width, height: kTableHeaderHeight)
        if tblView.contentOffset.y < -kTableHeaderHeight {
            headerRect.origin.y = tblView.contentOffset.y
            headerRect.size.height = -tblView.contentOffset.y
        }
        headerView.frame = headerRect
    }
    
    func progressAlongAxis(_ pointOnAxis: CGFloat, _ axisLength: CGFloat) -> CGFloat {
        let movementOnAxis = pointOnAxis / axisLength
        let positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
        let positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)
        return CGFloat(positiveMovementOnAxisPercent)
    }

    func ensureRange<T>(value: T, minimum: T, maximum: T) -> T where T: Comparable {
        return min(max(value, minimum), maximum)
    }
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        
//        let percentThreshold:CGFloat = 0.3
//        let translation = sender.translation(in: view)
//
//        let newX = ensureRange(value: view.frame.minY + translation.y, minimum: 0, maximum: view.frame.maxY)
//        let progress = progressAlongAxis(newX, view.bounds.height)
//
//        view.frame.origin.y = newX //Move view to new position
//
//        if sender.state == .ended {
//            let velocity = sender.velocity(in: view)
//
//            print("velocity", velocity)
//
//            if velocity.y >= 1300 || progress > percentThreshold {
//
//                self.dismiss(animated: true) //Perform dismiss
//            } else {
//                UIView.animate(withDuration: 0.2, animations: {
//                    self.view.frame.origin.y = 130 // Revert animation
//                })
//            }
//        }
        
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        let dragVelocity = sender.velocity(in: self.view)
        print("dragVelocity", dragVelocity)
        
        if sender.state == .ended {
            
            if  UIScreen.main.bounds.height/2 < view.frame.origin.y {
                self.dismiss(animated: true, completion: nil)
            }
            if dragVelocity.y >= 1300 {
                // Velocity fast enough to dismiss the uiview
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension KTKarwaBusPlanDirectionListViewController: GMSMapViewDelegate{

    internal func addMap() {

        let camera = GMSCameraPosition.camera(withLatitude: 25.281308, longitude: 51.531917, zoom: 14.0)
        
//        showCurrentLocationDot(show: true)
        self.mapView.camera = camera;
        
        let padding = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        mapView.padding = padding
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "map_style_karwa", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
      
      mapView.delegate = self
    
      self.focusMapToCurrentLocation()
        
    }
    
    func focusMapToCurrentLocation() {
        if(KTLocationManager.sharedInstance.isLocationAvailable && KTLocationManager.sharedInstance.currentLocation.coordinate.isZeroCoordinate == false) {
            let update :GMSCameraUpdate = GMSCameraUpdate.setTarget(KTLocationManager.sharedInstance.currentLocation.coordinate, zoom: KTCreateBookingConstants.DEFAULT_MAP_ZOOM)
            mapView.animate(with: update)
        }
    }
    
}


extension KTKarwaBusPlanDirectionListViewController {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 100
        }
        
        if let leg = itenary?.legs?[indexPath.row - 1] {
            if leg.mode == "WALK" {
                return 120
            } else if leg.mode == "BUS" {
                return 220
            }
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 100
        }
        return UITableViewAutomaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (itenary?.legs?.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : KTKarwaDirectionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "KTKarwaDirectionTableViewCell") as! KTKarwaDirectionTableViewCell
        cell.selectionStyle = .none
        if indexPath.row == 0 {
            cell.directionStackViewImage1.isHidden = false
            cell.directionStackViewImage2.isHidden = false
            cell.directionStackViewImage3.isHidden = true
            cell.directionStackViewImage4.isHidden = true
            cell.topStackView.isHidden = false
            cell.middleStackView.isHidden = true
            cell.bottomStackView.isHidden = true
            cell.bgView.backgroundColor = UIColor(hex: "129793").withAlphaComponent(0.1)
            cell.firstLbl.text = "Start from"
            cell.secondLbl.text = suggestedRoutes.plan?.from?.name ?? ""
            cell.amountLbl.isHidden = true
            let date = Date(timeIntervalSince1970: TimeInterval(Double(suggestedRoutes.plan?.date ?? 0)))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a dd MMM yyyy"
            let dateString = dateFormatter.string(from: date)
            cell.thirdLbl.text = "Departs at \(dateString)"
            cell.directionStackViewImage1.image = #imageLiteral(resourceName: "SHWIconHome")
            return cell

        } else {
            
            cell.directionStackViewImage1.isHidden = true
            cell.directionStackViewImage2.isHidden = false
            cell.directionStackViewImage3.isHidden = false
            cell.directionStackViewImage4.isHidden = false
            cell.topStackView.isHidden = false
            cell.bgView.backgroundColor = UIColor.white

            if let leg = itenary?.legs?[indexPath.row - 1] {
                
                cell.directionStackViewImage1.isHidden = true
                cell.directionStackViewImage2.isHidden = false
                cell.directionStackViewImage3.isHidden = false
                cell.directionStackViewImage4.isHidden = false
                
                if leg.mode! == "WALK" {
                    cell.directionStackViewImage2.image = #imageLiteral(resourceName: "dotted_line")
                    cell.directionStackViewImage3.image = #imageLiteral(resourceName: "walk_gray")
                    cell.directionStackViewImage4.image = #imageLiteral(resourceName: "solid line")
                    cell.amountLbl.isHidden = true
                    cell.firstLbl.text = "Walk to"
                    cell.secondLbl.text = leg.to?.name ?? ""
                    cell.thirdLbl.text = "\(Int(leg.distance ?? 0)) m • \((leg.duration ?? 0)/60) min"
                    cell.middleStackView.isHidden = true
                    return cell

                } else if leg.mode! == "BUS" {
                    
                    let cell : KTKarwaBusDirectionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "KTKarwaBusDirectionTableViewCell") as! KTKarwaBusDirectionTableViewCell
                    cell.selectionStyle = .none
                    cell.busNumberLbl.addLeading(image: UIImage(named: "BusListing")!, text: "\(leg.routeShortName ?? "") ", imageOffsetY: 0)
                    cell.busNumberLbl.customBorderColor = UIColor(hexString: "\(leg.routeColor ?? "")")
                    cell.addressLbl.text = leg.from?.name ?? ""
                    let date = Date(timeIntervalSince1970: TimeInterval(Double(suggestedRoutes.plan?.date ?? 0)))
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "h:mm a dd MMM yyyy"
                    let dateString = dateFormatter.string(from: date)
                    cell.timeLbl.text = "Departs at \(dateString)"
                    
                    let departTime = Date(timeIntervalSince1970: TimeInterval(Double(leg.from?.departure ?? 0)))
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "h:mm a dd/mm/yyyy"
                    let timeString = timeFormatter.string(from: departTime)
                    
                    let arrivalTime = Date(timeIntervalSince1970: TimeInterval(Double(leg.from?.arrival ?? 0)))
                    let arrivalTimeFormatter = DateFormatter()
                    arrivalTimeFormatter.dateFormat = "h:mm a dd/mm/yyyy"
                    let arrtimeString = arrivalTimeFormatter.string(from: arrivalTime)
                    
                    cell.timeLbl.text = "\(timeString) - \(arrtimeString)"
                    
                    cell.rideToAddressLbl.text = leg.to?.name ?? ""
                    cell.rideToTimeLbl.text = "\(Int(leg.distance ?? 0)) m • \((leg.duration ?? 0)/60) min"

                    cell.directionStackViewImage1.image = #imageLiteral(resourceName: "clock")
                    cell.directionStackViewImage2.image = #imageLiteral(resourceName: "solid line")
                    cell.directionStackViewImage3.image = #imageLiteral(resourceName: "BusListing")
                    cell.directionStackViewImage2.image = #imageLiteral(resourceName: "solid line")
                    return cell
                }
                
            }
            
            
            
        }
        return UITableViewCell()
    }
}

class KTKarwaDirectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var directionStackView: UIStackView!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var middleStackView: UIStackView!
    @IBOutlet weak var bottomStackView: UIStackView!
    
    @IBOutlet weak var firstLbl: UILabel!
    @IBOutlet weak var secondLbl: UILabel!
    @IBOutlet weak var thirdLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!

    @IBOutlet weak var directionStackViewImage1: UIImageView!
    @IBOutlet weak var directionStackViewImage2: UIImageView!
    @IBOutlet weak var directionStackViewImage3: UIImageView!
    @IBOutlet weak var directionStackViewImage4: UIImageView!

    @IBOutlet weak var bgView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

//KTKarwaBusDirectionTableViewCell

class KTKarwaBusDirectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var directionStackView: UIStackView!
    @IBOutlet weak var bottomStackView: UIStackView!
    
    @IBOutlet weak var busNumberLbl: PaddingLabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var rideToAddressLbl: UILabel!
    @IBOutlet weak var rideToTimeLbl: UILabel!

    @IBOutlet weak var directionStackViewImage1: UIImageView!
    @IBOutlet weak var directionStackViewImage2: UIImageView!
    @IBOutlet weak var directionStackViewImage3: UIImageView!
    @IBOutlet weak var directionStackViewImage4: UIImageView!

    @IBOutlet weak var bgView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        busNumberLbl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        // Initialization code
    }
    
}
