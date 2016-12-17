//
//  LocationsViewController.swift
//  Location Journal
//
//  Created by David Wang on 12/15/16.
//  Copyright © 2016 David Wang. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    
    
    
    var managedObjectContext: NSManagedObjectContext!
    

    //old (replace code below with this if it doesnt work
    var locations = [Location]()
    
    /*lazy var fetchedResultsController:
        NSFetchedResultsController<Location> = {
            let fetchRequest = NSFetchRequest<Location>()
            let entity = Location.entity()
            fetchRequest.entity = entity
            
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            fetchRequest.fetchBatchSize = 20
            
            let fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: self.managedObjectContext,
                sectionNameKeyPath: nil,
                cacheName: "Locations")
            
            fetchedResultsController.delegate = self
            return fetchedResultsController
    }()*/
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    //attempt to make a second class
    /*override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        let location = locations[indexPath.row]
        cell.configure(for: location)
        return cell
    }*/
    
    /*override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }*/
    
    /*override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        let location = fetchedResultsController.object(at: indexPath)
        cell.configure(for: location)
        
        return cell
    }*/
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "LocationCell", for: indexPath)
        let location = locations[indexPath.row]
        let descriptionLabel = cell.viewWithTag(100) as! UILabel
        descriptionLabel.text = location.locationDescription
        let addressLabel = cell.viewWithTag(101) as! UILabel
        if let placemark = location.placemark {
            var text = ""
            if let s = placemark.subThoroughfare {
                text += s + " "
            }
            if let s = placemark.thoroughfare {
                text += s + ", "
            }
            if let s = placemark.locality {
                text += s
            }
            addressLabel.text = text
        } else {
            addressLabel.text = ""
        }
        return cell
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        let fetchRequest = NSFetchRequest<Location>()
        //
        let entity = Location.entity()
        fetchRequest.entity = entity
        //
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            //
            locations = try managedObjectContext.fetch(fetchRequest)
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    /*override func viewDidLoad() {
        super.viewDidLoad()
        performFetch()
    }*/
    
    /*func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    deinit {
        fetchedResultsController.delegate = nil
    }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let navigationController = segue.destination
                as! UINavigationController
            let controller = navigationController.topViewController
                as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            if let indexPath = tableView.indexPath(
                for: sender as! UITableViewCell) {
                let location = locations[indexPath.row]
                controller.locationToEdit = location
            }
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let location = locations[indexPath.row]
            managedObjectContext.delete(location)
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LocationsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any, at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        case .delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRow(at: indexPath!)
                as? LocationCell {
                let location = controller.object(at: indexPath!) as! Location
                cell.configure(for: location)
            }
        case .move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(IndexSet(integer: sectionIndex),
                                     with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(IndexSet(integer: sectionIndex),
                                     with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (section)")
        case .move:
            print("*** NSFetchedResultsChangeMove (section)")
        }
    }
    
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}