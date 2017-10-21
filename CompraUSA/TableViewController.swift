//
//  TableViewController.swift
//  CompraUSA
//
//  Created by rafael on 03/10/17.
//  Copyright © 2017 rafael. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
    
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 22))
    var fetchedResultController: NSFetchedResultsController<Produto>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 106
        tableView.rowHeight = UITableViewAutomaticDimension
        label.text = "Sem Compras!"
        label.textAlignment = .center
        label.textColor = .black
        
        loadProdutos()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    func loadProdutos() {
        let fetchRequest: NSFetchRequest<Produto> = Produto.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "nome", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedResultController.fetchedObjects?.count {
            tableView.backgroundView = (count == 0) ? label : nil
            return count
        } else {
            tableView.backgroundView = label
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let produto = fetchedResultController.object(at: indexPath)
            context.delete(produto)
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProdutoViewCell
        let produto = fetchedResultController.object(at: indexPath)
        cell.lbProduto.text = produto.nome
        if let image = produto.imagem as? UIImage {
            cell.ivImagem.image = image
        } else {
            cell.ivImagem.image = nil
        }
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ViewController = segue.destination as? ProdutoRegisterViewController{
            if let produto = sender as? Produto{
                ViewController.produto = produto
            }else{
                ViewController.produto = nil
            }
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "produto", sender: fetchedResultController.object(at: indexPath))
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
extension TableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
