//
//  ViewController.swift
//  TinderCard
//
//  Created by Chung Han Hsin on 2020/4/29.
//  Copyright © 2020 Chung Han Hsin. All rights reserved.
//

import UIKit

fileprivate let threhold: CGFloat = 120

public enum SlideAction {
  case like
  case disLike
}

protocol CardViewDelegate: AnyObject {
  func cardViewDidLikeCard(_ cardView: CardView, cardViewModel: CardViewModel)
  func cardViewDidDislikeCard(_ cardView: CardView, cardViewModel: CardViewModel)
}

public class CardView: UIView {
  weak var delegate: CardViewDelegate?
  
  fileprivate var card = Card()
  public private(set) var cardViewModel: CardViewModel
  
  init(cardViewModel: CardViewModel) {
    self.cardViewModel = cardViewModel
    super.init(frame: .zero)
    card.dataSource = self
    card.delegate = self
    addSubview(card)
    card.fillSuperView()
    card.reloadData()
    addPanGesture()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension CardView: CardDataSource {
  
  func cardCurrentPhotoIndex(_ card: Card) -> Int {
    return cardViewModel.currentPhotoIndex
  }
  
  func cardPhotos(_ cardView: Card) -> [UIImage] {
    return cardViewModel.photos
  }
  
  func cardInformationAttributedText(_ cardView: Card) -> NSAttributedString {
    return cardViewModel.attributedString
  }
  
  func cardInformationTextAlignment(_ cardView: Card) -> NSTextAlignment {
    return cardViewModel.textAlignment
  }
}

extension CardView: CardDelegate {
  
  func cardPhototMoveForward(_ card: Card, currentPhotoIndex: Int, countOfPhotos: Int) {
    cardViewModel.currentPhotoIndex = cardViewModel.getPhotoMoveForwardIndex(currentIndex: currentPhotoIndex, countOfPhotos: countOfPhotos)
    card.reloadData()
  }
  
  func cardPhototBackLast(_ card: Card, currentPhotoIndex: Int, countOfPhotos: Int) {
    cardViewModel.currentPhotoIndex = cardViewModel.getPhotoBackLastIndex(currentIndex: currentPhotoIndex, countOfPhotos: countOfPhotos)
    card.reloadData()
  }
  
  //MARK: - Pan Gesture
  fileprivate func addPanGesture() {
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    addGestureRecognizer(panGesture)
  }
  
  @objc func handlePan(gesture: UIPanGestureRecognizer){
    switch gesture.state {
      case .began:
        superview?.subviews.forEach({ (subview) in
          subview.layer.removeAllAnimations()
        })
      case .changed:
        handleChanged(gesture)
      case .ended:
        handleEnded(gesture)
      default:
        return
    }
  }
  
  fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: nil)
    //convert degrees into radians
    let degrees: CGFloat = translation.x / 20
    let angle: CGFloat = degrees * .pi / 180
    let rotationTransformation = CGAffineTransform.init(rotationAngle: angle)
    transform = rotationTransformation.translatedBy(x: translation.x, y: translation.y)
  }
  
  fileprivate func handleEnded(_ gesture: UIPanGestureRecognizer) {
    var slideAction: SlideAction = .like
    let translationDirection: CGFloat = gesture.translation(in: nil).x
    translationDirection > 0 ? (slideAction = .like) : (slideAction = .disLike)
    let shouldDismissedCard = abs(gesture.translation(in: nil).x) > threhold
    if shouldDismissedCard{
      switch slideAction {
        case .like:
          likeCard()
        case .disLike:
          dislikeCard()
      }
    }else{
      UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {[unowned self] in
        self.transform = .identity
      })
    }
  }
  
  func likeCard() {
    performSwipAnimation(translation: 700, angle: 15)
    delegate?.cardViewDidLikeCard(self, cardViewModel: cardViewModel)
  }
  
  func dislikeCard() {
    performSwipAnimation(translation: -700, angle: -15)
    delegate?.cardViewDidDislikeCard(self, cardViewModel: cardViewModel)
  }
  
  fileprivate func performSwipAnimation(translation: CGFloat, angle: CGFloat) {
    let translationAnimation = CABasicAnimation.init(keyPath: "position.x")
    translationAnimation.toValue = translation
    translationAnimation.duration = 0.5
    translationAnimation.fillMode = .forwards
    translationAnimation.isRemovedOnCompletion = false
    translationAnimation.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
    
    let rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
    rotationAnimation.toValue = angle * CGFloat.pi / 180
    rotationAnimation.duration = 0.5
    CATransaction.setCompletionBlock {
      self.removeFromSuperview()
    }
    
    self.layer.add(translationAnimation, forKey: "translation")
    self.layer.add(rotationAnimation, forKey: "rotation")
    CATransaction.commit()
  }
}
