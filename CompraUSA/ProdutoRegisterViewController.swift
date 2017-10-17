//
//  ProdutoRegisterViewController.swift
//  CompraUSA
//
//  Created by rafael on 13/10/17.
//  Copyright © 2017 rafael. All rights reserved.
//

import UIKit

class ProdutoRegisterViewController: UIViewController {
    @IBOutlet weak var tfNomeProduto: UITextField!
    @IBOutlet weak var tfEstado: UITextField!
    @IBOutlet weak var tfValor: UITextField!
    @IBOutlet weak var ivImagem: UIImageView!
    @IBOutlet weak var btnAddUpdate: UIButton!
    
    var produto: Produto!
    var smallImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if produto != nil {
            tfNomeProduto.text = produto.nome
            
            tfValor.text = "\(produto.valor)"
            btnAddUpdate.setTitle("Atualizar", for: .normal)
            if let image = produto.imagem as? UIImage {
                ivImagem.image = image
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
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
        if produto == nil {
            produto = Produto(context: context)
        }
        produto.nome = tfNomeProduto.text!
        // = tfEstado.text!
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
    
    func close() {
        if produto != nil && produto.nome == nil {
            context.delete(produto)
        }
        dismiss(animated: true, completion: nil)
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {
        
        //Iremos usar o código abaixo para criar uma versão reduzida da imagem escolhida pelo usuário
        let smallSize = CGSize(width: 300, height: 280)
        UIGraphicsBeginImageContext(smallSize)
        image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
        
        //Atribuímos a versão reduzida da imagem à variável smallImage
        smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        ivImagem.image = smallImage //Atribuindo a imagem à ivPoster
        
        //Aqui efetuamos o dismiss na UIImagePickerController, para retornar à tela anterior
        dismiss(animated: true, completion: nil)
    }
}
