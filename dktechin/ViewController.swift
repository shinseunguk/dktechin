//
//  ViewController.swift
//  dktechin
//
//  Created by ukBook on 2022/08/20.
//

import Foundation
import UIKit

class ViewController: UIViewController {
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var rigthBtn: UIBarButtonItem!
    @IBOutlet weak var btn0: UIButton!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var horizonIndex = 0
    var verticalIndex = 0
    
    var leftMenuItem: UIBarButtonItem {
        let leftMenuItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(btnAction(_:)))
        return leftMenuItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //imagePicker setup
        self.imagePicker.delegate = self // picker delegate
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .photoLibrary // 앨범에서 가져옴
    }
    
    override func viewDidAppear(_ animated: Bool) {
        plusAction()
    }
    
    func plusAction() {
        let alert =  UIAlertController(title: "사진 추가 / 변경", message: nil, preferredStyle: .actionSheet)

        let library1 =  UIAlertAction(title: "사진 추가 / 변경", style: .default) {
            (action) in self.openLibrary()
        }

        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(library1)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func openLibrary(){
        present(imagePicker, animated: false, completion: nil)
    }
    
    @objc
    @IBAction func btnAction(_ sender: Any) {
        let tagIndex = (sender as! AnyObject).tag
        
        switch tagIndex {
        case 0:
            cropImage()
            break
        case 1:
            verticalFlip()
            break
        case 2:
            horizonFlip()
            break
        case 3:
            plusAction()
            break
        case 4:
            checkAction()
            break
        default:
            print("default")
        }
    }
    
    func cropImage() {
        // button hidden, 오른쪽 상단 체크 버튼, 왼쪽 상단 x버튼
        print(#function)
        buttonHidden(TF: true)
    }
    
    func verticalFlip() {
        if horizonIndex == 0{
            if verticalIndex == 0 {
                imageView.transform = CGAffineTransform(scaleX: 1, y: -1);
                verticalIndex = 1
            }else {
                imageView.transform = CGAffineTransform(scaleX: 1, y: 1);
                verticalIndex = 0
            }
        }else {
            if verticalIndex == 0 {
                imageView.transform = CGAffineTransform(scaleX: -1, y: -1);
                verticalIndex = 1
            }else {
                imageView.transform = CGAffineTransform(scaleX: -1, y: 1);
                verticalIndex = 0
            }
        }
    }
    
    func horizonFlip() {
        if verticalIndex == 0 {
            if horizonIndex == 0 {
                imageView.transform = CGAffineTransform(scaleX: -1, y: 1);
                horizonIndex = 1
            }else {
                imageView.transform = CGAffineTransform(scaleX: 1, y: 1);
                horizonIndex = 0
            }
        }else {
            if horizonIndex == 0 {
                imageView.transform = CGAffineTransform(scaleX: -1, y: -1);
                horizonIndex = 1
            }else {
                imageView.transform = CGAffineTransform(scaleX: 1, y: -1);
                horizonIndex = 0
            }
        }
    }
    
    func checkAction() {
        buttonHidden(TF: false)
    }
    
    func buttonHidden(TF : Bool){
        if TF { // start Crop
            // Change tag
            rigthBtn.tag = 4
            
            // add Left Bar Item
            leftMenuItem.image = UIImage(systemName: "xmark") // 수정필요
            navBar.topItem?.setLeftBarButton(self.leftMenuItem, animated: false);
            
            // button hidden
            btn0.isHidden = TF
            btn1.isHidden = TF
            btn2.isHidden = TF
            
            // change navi title
            navBar.topItem!.title = "사진 자르기"
            
            // change navi Item
            rigthBtn.image = UIImage(systemName: "checkmark")
        }else {
            rigthBtn.tag = 3
            // button hidden
            btn0.isHidden = TF
            btn1.isHidden = TF
            btn2.isHidden = TF
            
            // change navi title
            navBar.topItem!.title = "사진 crop / flip"
            
            // change navi Item
            rigthBtn.image = UIImage(systemName: "camera")
        }
        
    }
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var newImage: UIImage? = nil // update 할 이미지
        
        if let possibleImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                    newImage = possibleImage // 수정된 이미지가 있을 경우
        } else if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            newImage = possibleImage // 원본 이미지가 있을 경우
        }
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        //flip한 이미지들 제자리로 초기화
        imageView.transform = CGAffineTransform(scaleX: 1, y: 1);
        horizonIndex = 0
        verticalIndex = 0
        
        self.imageView.image = newImage // 받아온 이미지를 update
        
        
        picker.dismiss(animated: true, completion: nil) // picker를 닫아줌
    }
}
