//
//  ViewController.swift
//  MachineLearningImageRecognition
//
//  Created by Atil Samancioglu on 6.08.2019.
//  Copyright © 2019 Atil Samancioglu. All rights reserved.
//

import UIKit
import CoreML
import Vision // bu coreml ile birlikte ve image recognition da kullandığımız yardımcı bir kütüphane

// core ml bizim machine learning modellerini uygulamamız içinde kullanmamıza olanak sağlayan bir framework. machine learning le yazdığımız kodlarla bir model oluşturuyoruz bu modeli eğitiyoruz ve model akıllanıyor. bunun sonucunda mesela koyulan görsel görselin içinde ne objeleri olduğunu anlayan bir model ortaya çıkıyor. biz de bu modeli alıp kendi uygulamamızda nasıl kullanabiliriz onu öğrenicez. ama bu modeli yapmak birçok farklı tekniğe sahip olmayı gerektiriyor bunun için ayrı kurslar var. phyton ile daha kolay öğrenilebilir. biz burada machine learningi yani eğitilmiş bir modeli alıp uygulamamızda nasıl kullanılırız onu görücez. hazır modelleri kullanıcaz.

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel! // yüzde kaç ihtimalle ne gördüğümüzü gösteren bir label
    
    var chosenImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
    }

    @IBAction func changeClicked(_ sender: Any) { // butona tıklandığında bir resim seçilebilmesini sağlıyoruz
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) { // resim seçildikten sonra ne yapılacağını yazıyoruz
        
        imageView.image = info[.originalImage] as? UIImage // resmi alıp uiimage a koy
        self.dismiss(animated: true, completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!) { // ciImage uiimage gibi core image tarafından kullanılabilicek bir görsel. burada aldığımız görseli uiimage değilde ciimage sınıfıyla kullanmak lazım. o yüzden ciimage a çeviriyoruz
            chosenImage = ciImage
        }
        recognizeImage(image: chosenImage) // kullanıcı resmi seçer seçmez bu fonksiyonu çağırıyoz. bunu yapınca kullanıcı görseli seçince içinde ne var görücek. ama dezavantajı şuana kadar kullanmadığımız ciImage diye bir görsel yapısı bekliycek
    }
    
    func recognizeImage(image: CIImage) { // burada ciimage ı kullanarak resmi almaya çalışıcaz
        
        // 1) Request -> görsel tanıma işlemini yaparken ilk adım request oluşturmak
        // 2) Handler -> sonra bu request i ele almak
        
        resultLabel.text = "Finding ..."
        
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) { // bu proje içindeki MobileNetV2 modelini kullanıp bu modeli bir değişkene atıyoruz
      
            let request = VNCoreMLRequest(model: model) { (vnrequest, error) in // request oluştururken VNCoreMLRequest kullanılır. bunun içinde bizden bir model istiyor ve bunun sonucunda bir request veriyor
                
                if let results = vnrequest.results as? [VNClassificationObservation] { // VNClassificationObservation görsel analizinin isteiğinin sonucunda üretilen bir sınıflandırma. bizim yapmak istediğimiz de bir görsel sınıflandırma
                    
                    if results.count > 0 { // bir görsel geldiyse
                        
                        let topResult = results.first // ilk sonucu alırsak bize en yüksek olaslıklı sonucu verir. birden fazla sonucu alıp bunlardan biridir diye bir sonuç da gösterebiliriz kullanıcıya ama hoca bir sonuç göstermek istiyor
                        
                        DispatchQueue.main.async { // arayüzle ilgili işlemler yapıcaz o yüzden main de yapmak gerekiyor
                            // requesti çalıştırmamız lazım. requesti ele alıp çalıştırıcağımız yer handler
                            
                            let confidenceLevel = (topResult?.confidence ?? 0) * 100 // yüzde kaç ihtimalle bu işlem yapıldı. sonucu 0 la 1 arasında veriyor o yüzden 100 ile çarparak görteriyoruz ama böyle yapınca da örneğin 26.435 gibi sayılar veriyor. o yüzden aşağıdaki kodu yazıyoruz. ?? buna default value deniyor ! bu force-unwrap
                            
                            let rounded = Int (confidenceLevel * 100) / 100 // bunu yapınca sayıyı yuvarlıyor
                            
                            self.resultLabel.text = "\(rounded)% it's \(topResult!.identifier)"
                        }
                    }
                }
            }
            let handler = VNImageRequestHandler(ciImage: image)
                  DispatchQueue.global(qos: .userInteractive).async { // burada DispatchQueue.global(qos: .userInteractive).async kullanmak yine arka planda çalıştırır ama high priority yani büyük öncelik verir. bunu her zaman kullanmayız, arka planda bir şeyi çok hızlı asenkronize bi şekilde yapmak istediğimizde bunu kullanırız.
                    do {
                    try handler.perform([request])
                    } catch {
                        print("error")
                    }
            }
        }
    }
}

