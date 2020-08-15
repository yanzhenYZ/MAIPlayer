//
//  ViewController.swift
//  test
//
//  Created by Work on 2020/6/20.
//  Copyright © 2020 yanzhen. All rights reserved.
//

import UIKit
import MSBPlayer

//#define NETAVURL @"http://39.107.116.40/res/tpl/default/file/guoke.mp4"
//#define NETAVURL @"http://playback.bsy.live.kkgoo.cn/live/347339769685475644.m3u8"
//#define NETAVURL @"http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8"

//private let video = "http://39.107.116.40/res/tpl/default/file/guoke.mp4"

private let video = "http://s2.meixiu.mobi/courseware/test/texiao/ES2U102KABWL/errors/2.mp4"

//let video = "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8"



class ViewController: UIViewController {

    private var index = 1
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var timeLabel: UILabel!
    private var subView: UIView!
    private var player: MSBAIPlayer?
    private var bbViw: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        
//        subView = PlayerView(frame: CGRect(x: 100, y: 100, width: 10, height: 10))
//        bbViw = UIView(frame: subView.bounds);
//        subView.addSubview(bbViw)
//        view.addSubview(subView)

//        subView = view
        
        playVideo()
    }
    
    
    
    @IBAction private func seekTo(_ sender: UISlider) {
        player?.seek(toTime: TimeInterval(slider.value))
    }
    

    @IBAction private func pausePlay(_ sender: UIButton) {
        if sender.isSelected {
            player?.resume()
        } else {
            player?.pause()
        }
        sender.isSelected.toggle()
        
        
//        player?.play()
        
//        player?.seek(toTime: 0)
//        player?.play()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        player?.seek(toTime: 0)
//        playVideo()
//        print(subView, subView.layer)
//        subView.transform = CGAffineTransform(scaleX: 35, y: 35)
//        subView.center = CGPoint(x: subView.frame.size.width * 0.5, y: subView.frame.size.height * 0.5)
//        subView.frame = CGRect(x: 0, y: 0, width: 700, height: 700)
//        print(subView, subView.layer)

//        for sub in subView.subviews {
//            print(sub, sub.layer.frame, sub.layer.bounds)
//        }
    }
    
}

private extension ViewController {
    func playVideo() {
        let path = Bundle.main.path(forResource: "output", ofType: "mp4")
        
        let url = URL(fileURLWithPath: path!)
//        let url = URL(string: "https://xiaoxiong-private.oss-cn-hangzhou.aliyuncs.com/courseware/test/temp/675ee040ba8111eaa93d315dba0324be.mp4")
            //URL(string: "https://xiaoxiong-private.oss-cn-hangzhou.aliyuncs.com/courseware/product/temp/0ac7c090c4d611ea8ad70b2b8db29493.mp4")
        
        
//        player = MSBAIApplePlayer(url: url)
//        player = MSBAIPlayer(url: url)
        player = MSBAIPlayer(url: url, apple: false)
        player?.videoGravity = .resizeAspect
        player?.attach(to: view)
        
        player?.playerStatus = { [weak self] (status, error) in
            print("status:", status.rawValue, error)
            if status == .readyToPlay {
                self?.player?.play()
            }
        }
        
        player?.playbackStatus = { [weak self] (status) in
            guard let self = self else {
                return
            }
            print(status.rawValue, "end")
            if status == .ended {
//                self.player?.stop()
//                self.player = nil
//                self.index += 1
//                if self.index < 12 {
//                    self.playVideo()
//                }
            }
        }
                
        player?.playbackTime = { [weak self] (time, duration) in
            self?.slider.maximumValue = Float(duration)
            self?.slider.value = Float(time)
            self?.timeLabel.text = String(format: "%.f/%.f", time, duration)
        }
        
        player?.loadedTime = { (time, duration) in
//            print("load:", time, duration)
        }
    }
}
