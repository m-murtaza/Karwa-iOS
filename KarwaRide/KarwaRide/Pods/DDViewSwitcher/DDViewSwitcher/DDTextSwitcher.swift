//
//  DDTextSwitcher.swift
//  DDViewSwitcher
//
//  Created by DingMac on 2017. 6. 15..
//  Copyright © 2017년 Dingding. All rights reserved.
//

import UIKit

open class DDTextSwitcher: UIView {
    
    private var lbCenter = UILabel()
    private var lbNext = UILabel()
    
    open var isScrolling = false
    open var isAutoScroll = true
    open var isInfiniteScrolling = true
    
    open var arrData = [String]()
    
    //Index of current data
    open var indexSwitcher: Int = 0
    
    //Default value of animation
    open var duration = 1.0
    open var delay = 1.0
    
    open var scrollDirection: ScrollDirection = .vertical
    
    public enum ScrollDirection: String {
        case horizontal = "horizontal"
        case vertical = "vertical"
    }
    
    private var pointVerticalOverTop: CGPoint!
    private var pointVerticalOverBottom: CGPoint!
    private var pointHorizontalOverLeft: CGPoint!
    private var pointHorizontalOverRight: CGPoint!
    
    //Center label point
    private var pointNormal: CGPoint!
    
    open var currentText: String {
        return lbCenter.text!
    }
    
    //Action when view is tapped
    open var tapAction: ((Void) -> Void)?
    open var finishScrollAction: ((Void) -> Void)?
    open var didChangeItemAction: ((Void) -> Void)?
    
    public init(frame: CGRect, data: [String], scrollDirection: ScrollDirection) {
        super.init(frame: frame)
        
        self.arrData = data
        
        self.scrollDirection = scrollDirection
        
        initSwitcher()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.addGestureRecognizer(tapGesture)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //Initiallize switcher view. set default values.
    private func initSwitcher(){
        self.removeFromSuperview()
        
        pointVerticalOverTop = CGPoint(x: 0, y: -self.frame.height)
        pointVerticalOverBottom = CGPoint(x: 0, y: self.frame.height)
        pointHorizontalOverLeft = CGPoint(x: -self.frame.width, y: 0)
        pointHorizontalOverRight = CGPoint(x: self.frame.width, y: 0)
        pointNormal = CGPoint(x: 0, y: 0)
        
        clipsToBounds = true
        
        isScrolling = false
        indexSwitcher = 0
        
        backgroundColor = UIColor.clear
        
        lbCenter.textColor = UIColor.black
        lbCenter.font = lbCenter.font.withSize(20)
        lbCenter.textAlignment = .center
        lbCenter.numberOfLines = 0
        self.lbCenter.frame.size = self.frame.size
        self.lbCenter.frame.origin = pointNormal
        self.addSubview(lbCenter)
        
        lbNext.textColor = UIColor.black
        lbNext.font = lbNext.font.withSize(20)
        lbNext.textAlignment = .center
        lbNext.numberOfLines = 0
        self.lbNext.frame.size = self.frame.size
        self.lbNext.frame.origin = (self.scrollDirection == .vertical) ? self.pointVerticalOverBottom : self.pointHorizontalOverRight
        self.addSubview(lbNext)
        
        lbCenter.text = arrData[indexSwitcher]
        indexSwitcher += 1
        lbNext.text = arrData[indexSwitcher]
    }
    
    //Scroll stop
    open func stop(){
        if(isAutoScroll){
            isScrolling = false
        }
        else {
            debugPrint("DDTextSwitcher >> You can't call stop() method. 'isAutoScroll' value is false")
        }
    }
    
    //Scroll start
    open func start(){
        if(isAutoScroll){
            isScrolling = true
            updateSwitcherAnimation()
        }
        else {
            debugPrint("DDTextSwitcher >> You can't call resume() method. 'isAutoScroll' value is false")
        }
    }
    
    //Scroll reset
    open func reset(){
        indexSwitcher = 0
        self.lbCenter.frame.origin = pointNormal
        self.lbNext.frame.origin = (self.scrollDirection == .vertical) ? self.pointVerticalOverBottom : self.pointHorizontalOverRight
        
        lbCenter.text = arrData[indexSwitcher]
        indexSwitcher += 1
        lbNext.text = arrData[indexSwitcher]
    }
    
    //Animate to next text
    open func next(){
        if(isAutoScroll){
            debugPrint("DDTextSwitcherLabel >> You can't call next() method. 'isAutoScroll' value is true")
        }
        else {
            updateSwitcherAnimation()
        }
    }
    
    //Set UILabel text color
    open func setTextColor(color: UIColor) {
        lbCenter.textColor = color
        lbNext.textColor = color
    }
    
    //Set UILabel text size
    open func setTextSize(size: CGFloat) {
        lbCenter.font = lbCenter.font.withSize(size)
        lbNext.font = lbNext.font.withSize(size)
    }
    
    //Set UILabel text alignment
    open func setTextAlignment(align: NSTextAlignment) {
        lbCenter.textAlignment = align
        lbNext.textAlignment = align
    }
    
    //Set UILabel number of Lines
    open func setNumberOfLines(numberOfLines: Int) {
        lbCenter.numberOfLines = 0
        lbNext.numberOfLines = 0
    }
    
    //****************************
    private func updateSwitcherAnimation() {
        UIView.animate(withDuration: duration, delay: delay, options: [], animations: { () -> Void in
            
            self.lbCenter.frame.origin = (self.scrollDirection == .vertical) ? self.pointVerticalOverTop : self.pointHorizontalOverLeft
            self.lbNext.frame.origin = self.pointNormal
            
        }, completion: { (finished: Bool) in

            if(self.indexSwitcher >= (self.arrData.count-1)){
                //Index move to zero
                if(self.isInfiniteScrolling) {
                    self.indexSwitcher = 0
                }
                //Scroll is end
                else {
                    self.indexSwitcher = self.indexSwitcher + 1
                    self.lbCenter.text = self.lbNext.text
                    self.isScrolling = false
                    
                    self.finishScroll()
                    
                    debugPrint("DDTextSwitcher >> Scrolling is end. 'isInfiniteScrolling' value is false")
                    
                    return
                }
            }
            else{
                self.indexSwitcher = self.indexSwitcher + 1
            }
            
            self.lbCenter.text = self.lbNext.text
            self.lbNext.text = self.arrData[self.indexSwitcher]
            
            self.lbCenter.frame.origin = self.pointNormal
            self.lbNext.frame.origin = (self.scrollDirection == .vertical) ? self.pointVerticalOverBottom : self.pointHorizontalOverRight
            
            //call handler
            self.didChangeItem()
            
            //This case is stop() is called.
            //if without check 'finished' values updateSwitcherAnimation will execute repeatedly after view controller is dismiss.
            if(finished && self.isScrolling){
                self.updateSwitcherAnimation()
            }
        })
    }
    
    //Tap action handler
    @objc open func didTap(sender: UITapGestureRecognizer) {
        guard let action = self.tapAction else { return /*didn't set closure*/}
        action(())
    }
    
    //scroll finish(Only isInfiniteScrolling is false) action handler
    open func finishScroll() {
        guard let action = self.finishScrollAction else { return /*didn't set closure*/}
        action(())
    }
    
    //scroll finish(Only isInfiniteScrolling is false) action handler
    open func didChangeItem() {
        guard let action = self.didChangeItemAction else { return /*didn't set closure*/}
        action(())
    }
}
