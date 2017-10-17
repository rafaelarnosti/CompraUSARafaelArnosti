//
//  EstadoRegisterViewController.swift
//  CompraUSA
//
//  Created by rafael on 13/10/17.
//  Copyright © 2017 rafael. All rights reserved.
//

import UIKit
import CoreData

enum EstadoType {
    case add
    case edit
}

class EstadoRegisterViewController: UIViewController {
    
    @IBOutlet weak var tfiof: UITextField!
    @IBOutlet weak var tfCotDol: UITextField!
    @IBOutlet weak var EstadoTableView: UITableView!
    var dataSource: [Estado] = []
    var produto: Produto!

    override func viewDidLoad() {
        super.viewDidLoad()
        tfCotDol.text = UserDefaults.standard.string(forKey: "cotdol")
        tfiof.text = UserDefaults.standard.string(forKey: "iof")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EstadoTableView.delegate = self
        EstadoTableView.dataSource = self
        loadEstados()
    }

    @IBAction func Add(_ sender: UIButton) {
        showAlert(type: .add, estado: nil)
    }
    
    func showAlert(type: EstadoType, estado: Estado?) {
        let title = (type == .add) ? "Adicionar" : "Editar"
        let alert = UIAlertController(title: "\(title) Estado", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Nome do Estado"
            if let nome_estado = estado?.nome_estado {
                textField.text = nome_estado
            }
        }
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Valor do Imposto"
            if let imposto = estado?.imposto {
                textField.text = "\(imposto)"
            }
        }
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action: UIAlertAction) in
            let estado = estado ?? Estado(context: self.context)
            estado.nome_estado = alert.textFields?.first?.text
            let imposto = alert.textFields?.last?.text
            estado.imposto = Double(imposto!)!
            do {
                try self.context.save()
                self.loadEstados()
            } catch {
                print(error.localizedDescription)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func loadEstados() {
        let fetchRequest: NSFetchRequest<Estado> = Estado.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "nome_estado", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            dataSource = try context.fetch(fetchRequest)
            EstadoTableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
}
extension EstadoRegisterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let estado = dataSource[indexPath.row]
            context.delete(estado)
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Excluir") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let estado = self.dataSource[indexPath.row]
            self.context.delete(estado)
            try! self.context.save()
            self.dataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Editar") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let estado = self.dataSource[indexPath.row]
            tableView.setEditing(false, animated: true)
            self.showAlert(type: .edit, estado: estado)
        }
        editAction.backgroundColor = .blue
        return [editAction, deleteAction]
    }
}

// MARK: - UITableViewDelegate
extension EstadoRegisterViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let estado = dataSource[indexPath.row]
        cell.textLabel?.text = estado.nome_estado
        cell.accessoryType = .none
        return cell
    }
}
