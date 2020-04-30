//
//  CardDeskView.swift
//  TinderCard
//
//  Created by Chung Han Hsin on 2020/4/29.
//  Copyright © 2020 Chung Han Hsin. All rights reserved.
//

import UIKit

public protocol CardDeskViewDataSource: AnyObject {
  func cardDeskViewAllCardViewModels(_ cardDeskView: CardDeskView) -> [CardViewModel]
  func cardDeskViewLikeIcon(_ cardDeskView: CardDeskView) -> UIImage
  func cardDeskViewDislikeIcon(_ cardDeskView: CardDeskView) -> UIImage
}

public protocol CardDeskViewDelegate: AnyObject {
  func cardDeskViewWillLikeCard(_ cardDeskView: CardDeskView, cardViewModel: CardViewModel)
  func cardDeskViewWillDislikeCard(_ cardDeskView: CardDeskView, cardViewModel: CardViewModel)
  func cardDeskViewDidRefreshAllCards(_ cardDeskView: CardDeskView, cardViewModels: [CardViewModel])
  func cardDeskViewDidSlide(_ cardDeskView: CardDeskView, cardViewModel: CardViewModel)
  func cardDeskViewDidCancelSlide(_ cardDeskView: CardDeskView, cardViewModel: CardViewModel)
  func cardDeskViewSliding(_ cardDeskView: CardDeskView, cardViewModel: CardViewModel, translation: CGPoint)
}

public class CardDeskView: UIView {
  weak public var dataSource: CardDeskViewDataSource?
  weak public var delegate: CardDeskViewDelegate?
  
  fileprivate var cardViews = [CardView]()
  fileprivate var currentCardView: CardView? {
    get {
      return cardViews.last
    }
  }
  
  override public init(frame: CGRect) {
    super.init(frame: .zero)
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension CardDeskView {
  fileprivate func setupCardViewsLayout() {
    cardViews.forEach{
      addSubview($0)
      $0.fillSuperView()
      $0.setupLikeAndDislikeIconLayout()
    }
  }
}

extension CardDeskView {
  
  public func putIntoCards() {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set CardDeskView's dataSource")
    }
    removeAllSubViewsFromSuperView()
    cardViews.removeAll()
    
    let cardViewModels = dataSource.cardDeskViewAllCardViewModels(self)
    
    cardViewModels.forEach {
      let cardView = CardView(cardViewModel: $0)
      cardViews.append(cardView)
      cardView.delegate = self
      cardView.dataSource = self
    }
    setupCardViewsLayout()
    delegate?.cardDeskViewDidRefreshAllCards(self, cardViewModels: cardViewModels)
  }
  
  public func likeCurrentCard() {
    currentCardView?.likeCard()
  }
  
  public func dislikeCurrentCard() {
    currentCardView?.dislikeCard()
  }
  
  public func getCurrentCardView() -> CardView? {
    return currentCardView
  }
}
 
extension CardDeskView: CardViewDataSource {
  
  func cardViewLikeImage(_ cardView: CardView) -> UIImage {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set CardDeskView's dataSource")
    }
    return dataSource.cardDeskViewLikeIcon(self)
  }
  
  func cardViewDislikeImage(_ cardView: CardView) -> UIImage {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set CardDeskView's dataSource")
    }
    return dataSource.cardDeskViewDislikeIcon(self)
  }
}

extension CardDeskView: CardViewDelegate {
  func cardViewDidSlide(_ cardView: CardView, cardViewModel: CardViewModel) {
    delegate?.cardDeskViewDidSlide(self, cardViewModel: cardViewModel)
  }
  
  func cardViewSliding(_ cardView: CardView, cardViewModel: CardViewModel, translation: CGPoint) {
    
    delegate?.cardDeskViewSliding(self, cardViewModel: cardViewModel, translation: translation)
  }
  
  func cardViewDidCancelSlide(_ cardView: CardView, cardViewModel: CardViewModel) {
    delegate?.cardDeskViewDidCancelSlide(self, cardViewModel: cardViewModel)
  }
  
  func cardViewWillLikeCard(_ cardView: CardView, cardViewModel: CardViewModel) {
    cardViews.removeLast()
    delegate?.cardDeskViewWillLikeCard(self, cardViewModel: cardViewModel)
  }
  
  func cardViewWillDislikeCard(_ cardView: CardView, cardViewModel: CardViewModel) {
    cardViews.removeLast()
    delegate?.cardDeskViewWillDislikeCard(self, cardViewModel: cardViewModel)
  }
}
