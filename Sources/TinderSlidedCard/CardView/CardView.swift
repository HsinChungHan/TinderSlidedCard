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
  case dislike
}

protocol CardViewDataSource: AnyObject {
  func cardViewLikeImage(_ cardView: CardView) -> UIImage
  func cardViewDislikeImage(_ cardView: CardView) -> UIImage
}

protocol CardViewDelegate: AnyObject {
  func cardViewWillLikeCard(_ cardView: CardView, cardViewModel: CardViewModel)
  func cardViewWillDislikeCard(_ cardView: CardView, cardViewModel: CardViewModel)
  func cardViewDidCancelSlide(_ cardView: CardView, cardViewModel: CardViewModel)
  func cardViewDidSlide(_ cardView: CardView, cardViewModel: CardViewModel)
  func cardViewSliding(_ cardView: CardView, cardViewModel: CardViewModel, translation: CGPoint)
}

public class CardView: UIView {
  weak var dataSource: CardViewDataSource?
  weak var delegate: CardViewDelegate?
  
  fileprivate var card = Card()
  public private(set) var cardViewModel: CardViewModel
  
  fileprivate lazy var likeIconImv = makeTransparentLikeIcon()
  fileprivate lazy var dislikeIconImv = makeTransparentDislikeIcon()
  
  init(cardViewModel: CardViewModel) {
    self.cardViewModel = cardViewModel
    super.init(frame: .zero)
    card.dataSource = self
    card.delegate = self
    setupLayout()
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
    
    let absOffset = abs(translation.x)
    let userSlideAction: SlideAction = translation.x > 0 ? .like : .dislike
    switch userSlideAction {
      case .like:
        likeIconImv.alpha = absOffset/frame.width * 3
      case .dislike:
        dislikeIconImv.alpha = absOffset/frame.width * 3
    }
    
    delegate?.cardViewSliding(self, cardViewModel: cardViewModel, translation: translation)
  }
  
  fileprivate func handleEnded(_ gesture: UIPanGestureRecognizer) {
    var slideAction: SlideAction = .like
    let translationDirection: CGFloat = gesture.translation(in: nil).x
    translationDirection > 0 ? (slideAction = .like) : (slideAction = .dislike)
    let shouldDismissedCard = abs(gesture.translation(in: nil).x) > threhold
    if shouldDismissedCard {
      switch slideAction {
        case .like:
          likeCard()
        case .dislike:
          dislikeCard()
      }
    }else{
      cancleSlide()
    }
  }
  
  func likeCard() {
    delegate?.cardViewWillLikeCard(self, cardViewModel: cardViewModel)
    self.likeIconImv.alpha = 1.0
    performSwipAnimation(translation: 700, angle: 15)
  }
  
  func dislikeCard() {
    delegate?.cardViewWillDislikeCard(self, cardViewModel: cardViewModel)
    self.dislikeIconImv.alpha = 1.0
    performSwipAnimation(translation: -700, angle: -15)
  }
  
  func cancleSlide() {
    UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {[unowned self] in
      self.transform = .identity
      self.likeIconImv.alpha = 0.0
      self.dislikeIconImv.alpha = 0.0
    })
    delegate?.cardViewDidCancelSlide(self, cardViewModel: cardViewModel)
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
      self.delegate?.cardViewDidSlide(self, cardViewModel: self.cardViewModel)
    }
    
    self.layer.add(translationAnimation, forKey: "translation")
    self.layer.add(rotationAnimation, forKey: "rotation")
    CATransaction.commit()
  }
  
  fileprivate func setupLayout() {
    addSubview(card)
    card.fillSuperView()
    card.reloadData()
  }
  
  func setupLikeAndDislikeIconLayout() {
    [likeIconImv, dislikeIconImv].forEach {
      addSubview($0)
    }
    likeIconImv.anchor(top: topAnchor, bottom: nil, leading: leadingAnchor, trailing: nil, padding: .init(top: 16, left: 16, bottom: 0, right: 0), size: .init(width: 130, height: 130))
    dislikeIconImv.anchor(top: topAnchor, bottom: nil, leading: nil, trailing: trailingAnchor, padding: .init(top: 16, left: 0, bottom: 0, right: 16), size: .init(width: 150, height: 150))
  }
  
  fileprivate func makeTransparentLikeIcon() -> UIImageView {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set CardDeskView's dataSource")
    }
    let imv = UIImageView(image: dataSource.cardViewLikeImage(self))
    imv.alpha = 0.0
    imv.contentMode = .scaleAspectFill
    return imv
  }
  
  fileprivate func makeTransparentDislikeIcon() -> UIImageView {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set CardDeskView's dataSource")
    }
    let imv = UIImageView(image: dataSource.cardViewDislikeImage(self))
    imv.alpha = 0.0
    imv.contentMode = .scaleAspectFill
    return imv
  }
}
