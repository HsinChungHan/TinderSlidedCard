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
}

public protocol CardDeskViewDelegate: AnyObject {
  func cardDeskViewDidLikeCard(_ cardDeskView: CardDeskView, cardViewModel: CardViewModel)
  
  func cardDeskViewDidDislikeCard(_ cardDeskView: CardDeskView, cardViewModel: CardViewModel)
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
  
  public func putIntoCards() {
    guard let dataSource = dataSource else {
      fatalError("🚨 You have to set CardDeskView's dataSource")
    }
    cardViews.removeAll()
    dataSource.cardDeskViewAllCardViewModels(self).forEach {
      let cardView = CardView(cardViewModel: $0)
      cardViews.append(cardView)
      cardView.delegate = self
    }
    setupCardViewsLayout()
  }
  
  fileprivate func setupCardViewsLayout() {
    cardViews.forEach{
      addSubview($0)
      $0.fillSuperView()
    }
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

extension CardDeskView: CardViewDelegate {
  func cardViewDidLikeCard(_ cardView: CardView, cardViewModel: CardViewModel) {
    cardViews.removeLast()
    delegate?.cardDeskViewDidLikeCard(self, cardViewModel: cardViewModel)
  }
  
  func cardViewDidDislikeCard(_ cardView: CardView, cardViewModel: CardViewModel) {
    cardViews.removeLast()
    delegate?.cardDeskViewDidDislikeCard(self, cardViewModel: cardViewModel)
  }
}
