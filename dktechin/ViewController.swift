//
//  ViewController.swift
//  dktechin
//
//  Created by ukBook on 2022/08/20.
//

//https://myungji.dev/wiki/uiimage-crop/

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
    
    // 초기 터치값
    var recLeftTopX : CGFloat = 0.0
    var recLeftTopY : CGFloat = 0.0
    var recRightBottomX : CGFloat = 0.0
    var recRightBottomY : CGFloat = 0.0
    
    // 이후 좌표값
    var leftTopX : CGFloat = 0.0
    var leftTopY : CGFloat = 0.0
    var leftBottomX : CGFloat = 0.0
    var leftBottomY : CGFloat = 0.0
    var rightTopX : CGFloat = 0.0
    var rightTopY : CGFloat = 0.0
    var rightBottomX : CGFloat = 0.0
    var rightBottomY : CGFloat = 0.0
    
    var recWidth : CGFloat = 0.0
    var recHeight : CGFloat = 0.0
    
    
    var touchIndex = 0
    
    var horizonIndex = 0
    var verticalIndex = 0
    
    var enableTouch : Bool = false
    
    var testView0 = UIView()
    var testView1 = UIView()
    var testView2 = UIView()
    var testView3 = UIView()
    var testView4 = UIView()
    var testView5 = UIView()
    var testView6 = UIView()
    var testView7 = UIView()
    
    var leftMenuItem: UIBarButtonItem { // 좌상단 네비게이션 아이템
        let leftMenuItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(btnAction(_:)))
        leftMenuItem.tag = 5
        return leftMenuItem
    }
    
    var cropRectengle: UIView { // crop시 imageview 영역표시
        let cropRectengle = UIView()
        cropRectengle.translatesAutoresizingMaskIntoConstraints = false
        cropRectengle.widthAnchor.constraint(equalToConstant: imageView.layer.frame.width).isActive = true
        cropRectengle.heightAnchor.constraint(equalToConstant: imageView.layer.frame.height).isActive = true
        cropRectengle.backgroundColor = .clear
        cropRectengle.layer.borderWidth = 3
        cropRectengle.layer.borderColor = UIColor.white.cgColor
        return cropRectengle
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
        plusAction() // 화면 진입시 Device 갤러리 진입 actionSheet alert 노출
    }
    
    func plusAction() { // actionSheet alert => 사진 추가 / 변경
        let alert =  UIAlertController(title: "사진 추가 / 변경", message: nil, preferredStyle: .actionSheet)

        let library1 =  UIAlertAction(title: "사진 추가 / 변경", style: .default) {
            (action) in self.openLibrary()
        }

        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(library1)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func openLibrary(){ // 앨범 open
        present(imagePicker, animated: false, completion: nil)
    }
    
    @objc
    @IBAction func btnAction(_ sender: Any) { // btn Action
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
            buttonHidden(TF: false)
            workCrop()
            break
        case 5: // button hidden false
            buttonHidden(TF: false)
        case 6:
            print("case 6")
        default:
            print("default")
        }
    }
    
    func verticalFlip() { // 상하 flip onclick method
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
    
    func horizonFlip() { // 좌우 flip onclick method
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
    
    func buttonHidden(TF : Bool){
        // button hidden
        btn0.isHidden = TF
        btn1.isHidden = TF
        btn2.isHidden = TF
        
        if TF { // start Crop
            // Change tag
            rigthBtn.tag = 4
            
            // 네비게이션 좌상단 item set
            navBar.topItem?.setLeftBarButton(self.leftMenuItem, animated: false);
            
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
            enableTouch = true
        }else {
            rigthBtn.tag = 3
            
            // change navi title
            navBar.topItem!.title = "사진 crop / flip"
            navBar.topItem?.leftBarButtonItem = nil
            
            // change navi Item
            rigthBtn.image = UIImage(systemName: "camera.fill")
            view.backgroundColor = .white
            
            descriptionLabel.isHidden = true
            touchIndex = 0
            
            testView0.removeFromSuperview()
            testView1.removeFromSuperview()
            testView2.removeFromSuperview()
            testView3.removeFromSuperview()
            
            testView4.removeFromSuperview()
            testView5.removeFromSuperview()
            testView6.removeFromSuperview()
            testView7.removeFromSuperview()
            
            //label reset
            descriptionLabel.text = "자르실 첫번째 모서리 터치"
            enableTouch = false
        }
        
    }
    @objc func imageViewTouch(gestureRecognizer: UITapGestureRecognizer) {
        if enableTouch {
            if touchIndex < 2 {
                if touchIndex == 0 {
                    if gestureRecognizer.state == UIGestureRecognizer.State.recognized {
                            
                        let location = gestureRecognizer.location(in: gestureRecognizer.view)
                        
                        testView0 = UIView(frame: CGRect(x: location.x, y: location.y, width:  400, height: 2))
                        testView1 = UIView(frame: CGRect(x: location.x, y: location.y, width:  -400, height: 2))
                        testView2 = UIView(frame: CGRect(x: location.x, y: location.y, width:  2, height: 800))
                        testView3 = UIView(frame: CGRect(x: location.x, y: location.y, width:  2, height: -800))
                        
                        testView0.backgroundColor = UIColor.white
                        testView1.backgroundColor = UIColor.white
                        testView2.backgroundColor = UIColor.white
                        testView3.backgroundColor = UIColor.white
                        
                        self.imageView.addSubview(testView0)
                        self.imageView.addSubview(testView1)
                        self.imageView.addSubview(testView2)
                        self.imageView.addSubview(testView3)
                        
                        recLeftTopX = location.x
                        recLeftTopY = location.y
                        
                        descriptionLabel.text = "나머지 대각선 모서리 터치"
                    }
                }else if touchIndex == 1 {
                    if gestureRecognizer.state == UIGestureRecognizer.State.recognized {
                            
                        let location = gestureRecognizer.location(in: gestureRecognizer.view)
                        
                        testView4 = UIView(frame: CGRect(x: location.x, y: location.y, width:  5000, height: 2))
                        testView5 = UIView(frame: CGRect(x: location.x, y: location.y, width:  -5000, height: 2))
                        testView6 = UIView(frame: CGRect(x: location.x, y: location.y, width:  2, height: 5000))
                        testView7 = UIView(frame: CGRect(x: location.x, y: location.y, width:  2, height: -5000))
                        
                        testView4.backgroundColor = UIColor.white
                        testView5.backgroundColor = UIColor.white
                        testView6.backgroundColor = UIColor.white
                        testView7.backgroundColor = UIColor.white
                        
                        self.imageView.addSubview(testView4)
                        self.imageView.addSubview(testView5)
                        self.imageView.addSubview(testView6)
                        self.imageView.addSubview(testView7)
                        
                        recRightBottomX = location.x
                        recRightBottomY = location.y
                        
                        print("recLeftTopX ",recLeftTopX)
                        print("recLeftTopY ", recLeftTopY)
                        print("recRightBottomX ",recRightBottomX)
                        print("recRightBottomY ", recRightBottomY)
                        
                        recWidth = recRightBottomX - recLeftTopX
                        recHeight = recRightBottomY - recLeftTopY
                        
                        print("recWidth ", Int(recWidth)) // 사각형 너비
                        print("recHeight ", Int(recHeight)) // 사각형 높이
                        
                        descriptionLabel.text = "취소 : Cancel / 적용 : 체크버튼"
                    }
                }
                touchIndex += 1
            }
        }
    }
    
    func workCrop() { // 원본 이미지를 비율에 맞게 조절후 crop해줌 => Helper class 참고
        imageView.image = imageView.image(at: CGRect(x: recLeftTopX, y: recLeftTopY, width: recWidth, height: recHeight))
    }
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var newImage: UIImage? = nil // update 할 이미지
        
       if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
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
