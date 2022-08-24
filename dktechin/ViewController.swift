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
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var touchIndex = 0
    
    var horizonIndex = 0
    var verticalIndex = 0
    
    var leftMenuItem: UIBarButtonItem {
        let leftMenuItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(btnAction(_:)))
        leftMenuItem.tag = 5
        return leftMenuItem
    }
    
    var cropRectengle: UIView {
        let cropRectengle = UIView()
        cropRectengle.translatesAutoresizingMaskIntoConstraints = false
        cropRectengle.widthAnchor.constraint(equalToConstant: imageView.layer.frame.width).isActive = true
        cropRectengle.heightAnchor.constraint(equalToConstant: imageView.layer.frame.height).isActive = true
        cropRectengle.backgroundColor = .clear
        cropRectengle.layer.borderWidth = 3
        cropRectengle.layer.borderColor = UIColor.white.cgColor
//        cropRectengle.addGestureRecognizer(gesture)
        return cropRectengle
    }
    
    var cropCornerBtn: UIButton {
        let cropCornerBtn = UIButton()
        cropCornerBtn.translatesAutoresizingMaskIntoConstraints = false
        cropCornerBtn.widthAnchor.constraint(equalToConstant: 6000).isActive = true
        cropCornerBtn.heightAnchor.constraint(equalToConstant: 6000).isActive = true
        cropCornerBtn.backgroundColor = .red
        return cropCornerBtn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.tag = 6
        
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
        case 0: // button hidden true
            buttonHidden(TF: true)
            break
        case 1: // 상하 flip onclick method
            verticalFlip()
            break
        case 2: // 좌우 flip onclick method
            horizonFlip()
            break
        case 3: // 사진 추가 / 변경
            plusAction()
            break
        case 4: // 카메라 클릭이후 체크 버튼 변경후 onclick method
            checkAction()
            break
        case 5: // button hidden false
            buttonHidden(TF: false)
        case 6:
            print("dd")
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
    
    func checkAction() {
        buttonHidden(TF: false)
    }
    
    func buttonHidden(TF : Bool){
        if TF { // start Crop
            // Change tag
            rigthBtn.tag = 4
            
            // add Left Bar Item
//            navBar.topItem?.leftBarButtonItem?.image = UIImage(systemName: "xmark") // 수정필요
            navBar.topItem?.setLeftBarButton(self.leftMenuItem, animated: false);
            
            // button hidden
            btn0.isHidden = TF
            btn1.isHidden = TF
            btn2.isHidden = TF
            
            // change navi title
            navBar.topItem!.title = "사진 자르기"
            
            // change navi Item
            rigthBtn.image = UIImage(systemName: "checkmark")
            
            imageView.addSubview(cropRectengle)
            view.backgroundColor = .gray

            let tapGR = UITapGestureRecognizer(target: self, action: #selector(imageViewTouch(gestureRecognizer: )))
            imageView.addGestureRecognizer(tapGR)
            imageView.isUserInteractionEnabled = true
            
            descriptionLabel.isHidden = false
        }else {
            rigthBtn.tag = 3
            // button hidden
            btn0.isHidden = TF
            btn1.isHidden = TF
            btn2.isHidden = TF
            
            // change navi title
            navBar.topItem!.title = "사진 crop / flip"
            navBar.topItem?.leftBarButtonItem = nil
            
            // change navi Item
            rigthBtn.image = UIImage(systemName: "camera.fill")
            view.backgroundColor = .white
            
            descriptionLabel.isHidden = true
            touchIndex = 0
        }
        
    }
    @objc func imageViewTouch(gestureRecognizer: UITapGestureRecognizer) {
        print(gestureRecognizer)
        if touchIndex < 2 {
            if gestureRecognizer.state == UIGestureRecognizer.State.recognized {
                    
                let location = gestureRecognizer.location(in: gestureRecognizer.view)
                print(gestureRecognizer.location(in: gestureRecognizer.view))
                
                let testView0 = UIView(frame: CGRect(x: location.x, y: location.y, width:  500, height: 2))
                let testView1 = UIView(frame: CGRect(x: location.x, y: location.y, width:  -500, height: 2))
                let testView2 = UIView(frame: CGRect(x: location.x, y: location.y, width:  2, height: 500))
                let testView3 = UIView(frame: CGRect(x: location.x, y: location.y, width:  2, height: -500))
                
                testView0.backgroundColor = UIColor.white
                testView1.backgroundColor = UIColor.white
                testView2.backgroundColor = UIColor.white
                testView3.backgroundColor = UIColor.white
                
                self.imageView.addSubview(testView0)
                self.imageView.addSubview(testView1)
                self.imageView.addSubview(testView2)
                self.imageView.addSubview(testView3)
                
                print("\(#line) ", location.x)
                print("\(#line) ", location.y)
            }
            touchIndex += 1
        }
        
        if touchIndex != 0 {
            descriptionLabel.text = "두번째 모서리 터치"
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
