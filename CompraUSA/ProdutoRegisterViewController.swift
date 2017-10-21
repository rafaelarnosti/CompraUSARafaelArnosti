//
//  ProdutoRegisterViewController.swift
//  CompraUSA
//
//  Created by rafael on 13/10/17.
//  Copyright © 2017 rafael. All rights reserved.
//

import UIKit
import CoreData

class ProdutoRegisterViewController: UIViewController {
    @IBOutlet weak var tfNomeProduto: UITextField!
    @IBOutlet weak var tfEstado: UITextField!
    @IBOutlet weak var tfValor: UITextField!
    @IBOutlet weak var ivImagem: UIImageView!
    @IBOutlet weak var btnAddUpdate: UIButton!
    @IBOutlet weak var swCartao: UISwitch!
    
    var produto: Produto!
    var smallImage: UIImage!
    
    var pickerView: UIPickerView!
    
    var dataSource:[Estado] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView = UIPickerView() //Instanciando o UIPickerView
        pickerView.backgroundColor = .white
        pickerView.delegate = self  //Definindo seu delegate
        pickerView.dataSource = self  //Definindo seu dataSource
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        
        //O botão abaixo servirá para o usuário cancelar a escolha de gênero, chamando o método cancel
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        //O botão done confirmará a escolha do usuário, chamando o método done.
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.items = [btCancel, btSpace, btDone]
        
        //Aqui definimos que o pickerView será usado como entrada do extField
        tfEstado.inputView = pickerView
        
        //Definindo a toolbar como view de apoio do textField (view que fica acima do teclado)
        tfEstado.inputAccessoryView = toolbar
        if produto != nil {
            tfNomeProduto.text = produto.nome
            
            tfValor.text = "\(produto.valor)"
            btnAddUpdate.setTitle("Atualizar", for: .normal)
            if let image = produto.imagem as? UIImage {
                ivImagem.image = image
            }
        }
        
    }
    @objc func cancel() {
        
        //O método resignFirstResponder() faz com que o campo deixe de ter o foco, fazendo assim
        //com que o teclado (pickerView) desapareça da tela
        tfEstado.resignFirstResponder()
    }
    
    //O método done irá atribuir ao textField a escolhe feita no pickerView
    @objc func done() {
        
        //Abaixo, recuperamos a linha selecionada na coluna (component) 0 (temos apenas um component
        //em nosso pickerView)
        tfEstado.text = dataSource[pickerView.selectedRow(inComponent: 0)].nome_estado
        
        //Agora, gravamos esta escolha no UserDefaults
        UserDefaults.standard.set(tfEstado.text!, forKey: "estado")
        cancel()
    }
    func loadEstados() {
        let fetchRequest: NSFetchRequest<Estado> = Estado.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "nome_estado", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            dataSource = try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        loadEstados()
        if produto != nil {
            if let estado = produto.estado {
                tfEstado.text = estado.nome_estado
            }
        }
    }

    @IBAction func AddImagem(_ sender: UIButton) {
        let alert = UIAlertController(title: "Selecionar poster", message: "De onde você quer escolher o poster?", preferredStyle: .actionSheet)
        
        //Verificamos se o device possui câmera. Se sim, adicionamos a devida UIAlertAction
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default, handler: { (action: UIAlertAction) in
                self.selectPicture(sourceType: .camera)
            })
            alert.addAction(cameraAction)
        }
        
        //As UIAlertActions de Biblioteca de fotos e Álbum de fotos também são criadas e adicionadas
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let photosAction = UIAlertAction(title: "Álbum de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .savedPhotosAlbum)
        }
        alert.addAction(photosAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    @IBAction func AddUpdateProduto(_ sender: UIButton) {
        if !tfNomeProduto.text!.isEmpty && !tfEstado.text!.isEmpty && !tfValor.text!.isEmpty && ivImagem.image != nil{
            if produto == nil {
                produto = Produto(context: context)
            }
        
        
            produto.nome = tfNomeProduto.text!
            if let EstadoIndex = dataSource.index(where:{ $0.nome_estado == tfEstado.text!}){
                produto.estado = dataSource[EstadoIndex]
            }
            produto.cartao = swCartao.isOn
            produto.valor = Double(tfValor.text!)!
            if smallImage != nil {
                produto.imagem = smallImage
            }
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
            close()
        }
        else {
            let alert = UIAlertController(title: "Campos Invalidos", message: "todos os campos precisam ser preenchidos", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    func close() {
        if produto != nil && produto.nome == nil {
            context.delete(produto)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        //Criando o objeto UIImagePickerController
        let imagePicker = UIImagePickerController()
        
        //Definimos seu sourceType através do parâmetro passado
        imagePicker.sourceType = sourceType
        
        //Definimos a MovieRegisterViewController como sendo a delegate do imagePicker
        imagePicker.delegate = self
        
        //Apresentamos a imagePicker ao usuário
        present(imagePicker, animated: true, completion: nil)
    }

    

}
extension ProdutoRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //O método abaixo nos trará a imagem selecionada pelo usuário em seu tamanho original
   @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {
        
        //Iremos usar o código abaixo para criar uma versão reduzida da imagem escolhida pelo usuário
        let smallSize = CGSize(width: 300, height: 280)
        UIGraphicsBeginImageContext(smallSize)
        image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
        
        //Atribuímos a versão reduzida da imagem à variável smallImage
        smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        ivImagem.image = smallImage
        
        //Aqui efetuamos o dismiss na UIImagePickerController, para retornar à tela anterior
        dismiss(animated: true, completion: nil)
    }
}
extension ProdutoRegisterViewController: UIPickerViewDelegate {
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //Retornando o texto recuperado do objeto dataSource, baseado na linha selecionada
        return dataSource[row].nome_estado
    }
}

extension ProdutoRegisterViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1    //Usaremos apenas 1 coluna (component) em nosso pickerView
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count //O total de linhas será o total de itens em nosso dataSource
    }
}

