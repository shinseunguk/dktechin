//
//  ViewController.swift
//  dktechin
//
//  Created by ukBook on 2022/08/20.
//

import UIKit

class ViewController: UIViewController {
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var imageView: UIImageView!
    
    var horizonIndex = 0
    var verticalIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //imagePicker setup
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.delegate = self // picker delegate
        self.imagePicker.sourceType = .photoLibrary // 앨범에서 가져옴
    }
    
    override func viewDidAppear(_ animated: Bool) {
        plusAction()
    }
    
    func plusAction() {
        let alert =  UIAlertController(title: "사진 추가 / 변경", message: nil, preferredStyle: .actionSheet)

        let library1 =  UIAlertAction(title: "Select Original Image", style: .default) {
            (action) in self.openLibrary(index: 1)
        }
        
        let library2 =  UIAlertAction(title: "Select Crop Image", style: .default) {
            (action) in self.openLibrary(index: 2)
        }

        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(library1)
        alert.addAction(library2)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func openLibrary(index : Int){
        // 수정 가능 여부
        if index == 1 {
            self.imagePicker.allowsEditing = false
        }else {
            self.imagePicker.allowsEditing = true
        }
        
        present(imagePicker, animated: false, completion: nil)
    }
    
    @IBAction func btnAction(_ sender: Any) {
        let tagIndex = (sender as! AnyObject).tag
        
        switch tagIndex {
        case 0:
            print("0")
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
        default:
            print("default")
        }
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
