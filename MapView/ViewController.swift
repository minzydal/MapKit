//
//  ViewController.swift
//  MapView
//
//  Created by MINZY KIM on 2022/07/28.
//
import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, UISearchResultsUpdating,CLLocationManagerDelegate {
    
    let mapView = MKMapView()
    let searchVC = UISearchController(searchResultsController: ResultsViewController())
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Maps"
        view.addSubview(mapView)
        searchVC.searchBar.backgroundColor = .secondarySystemBackground
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        
        locationManager.delegate = self //델리게이트 설정
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //거리 정확도 설정
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            print("위치 서비스 on 상태")
            locationManager.startUpdatingLocation() //위치 정보 받아오기 시작
            print(locationManager.location?.coordinate)
        } else {
            print("위치 서비스 off 상태")
        }
        
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUPdateLocations")
        if let location = locations.first {
            print("위도: \(location.coordinate.latitude)")
            print("경도: \(location.coordinate.longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = view.bounds
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultsVC = searchController.searchResultsController as? ResultsViewController else {
            return
        }
        
        resultsVC.delegate = self
        
        GooglePlacesManager.shared.findPlaces(query: query){ result in
            switch result{
            case .success(let places):
                print("found results")
                DispatchQueue.main.async {
                    resultsVC.update(with: places)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension ViewController: ResultsViewControllerDelegate{
    func didTapPlace(with coordinates: CLLocationCoordinate2D) {
        searchVC.searchBar.resignFirstResponder()
        searchVC.dismiss(animated: true, completion: nil)
        
        // Remove all map pins
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        
        // Add a map pin
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(
            center: coordinates,
            span: MKCoordinateSpan(
                latitudeDelta: 0.2,
                longitudeDelta: 0.2
            )),
                          animated: true
        )
    }
}
