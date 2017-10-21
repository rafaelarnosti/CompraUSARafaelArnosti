//
//  TotalViewController.swift
//  CompraUSA
//
//  Created by rafael on 17/10/17.
//  Copyright © 2017 rafael. All rights reserved.
//

import UIKit
import CoreData

var fetchedResultController: NSFetchedResultsController<Produto>!

class TotalViewController: UIViewController {
    @IBOutlet weak var lbValorProduto: UILabel!
    @IBOutlet weak var lbValorProdutoTrib: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProdutos()
        somarValores()
    }

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
    func somarValores(){
        if let count = fetchedResultController.fetchedObjects?.count {
            if count != 0 {
                var Soma = 0.0
                var Somatrib = 0.0
                var valorTrib = 0.0
                for  produtos in fetchedResultController.fetchedObjects!{
                    Soma = Soma + produtos.valor
                    if(produtos.cartao){
                        valorTrib = produtos.valor * UserDefaults.standard.double(forKey: "cotdol") * UserDefaults.standard.double(forKey: "iof") * (produtos.estado?.imposto)!
                    }else{
                        valorTrib = produtos.valor * UserDefaults.standard.double(forKey: "cotdol") * UserDefaults.standard.double(forKey: "iof")
                    }
                    Somatrib = Somatrib + valorTrib
                }
                lbValorProduto.text = "\(Soma)"
                lbValorProdutoTrib.text = "\(Somatrib)"
            }
        }
    }

}

extension TotalViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
}
