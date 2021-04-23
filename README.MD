# App store transition
Almost similar app store transition.
<br/>

# Demo
![alt tag](https://github.com/chanonly123/app-store-transition/raw/master/demo2.gif)
<br/>

# Usage

## Step 1: Drag and drop `Transition` folder project
```
Transition/DismissBehaviour.swift
Transition/Presenter.swift
Transition/UIViewTouchFeedback.swift
```

## Step 2: implement `HomeController` protocol

```
extension HomeViewController: HomeController {
    var linkView: UIView { sharedView }
}
```

## Step 3: implement `DetailController` protocol

```
extension DetailViewController: DetailController {

}
```
## Step 4: create `Presenter` and hold strong
```
presenter = Presenter(params: .init(from: home, to: detail))
presenter.present()
```
## Optional bounce: Enable touch feedback
```
cardView.enableTouchFeedback(enable: true) { (down, view) in
    UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [.allowUserInteraction], animations: {
        view.transform = down ? CGAffineTransform.init(scaleX: 0.97, y: 0.97) : CGAffineTransform.identity
    }, completion: nil)
}
```
## Optional drag down to dismiss: set `scrollView` from `detail` controller and implemtent delegate
```
presenter?.scrollView = scrollView
scrollView.delegate = self

extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        presenter?.behaviour.scrollViewDidScroll(scrollView)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        presenter?.behaviour.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
}

```
## For more info please look at demo project

<br/>

# Thanks to
[Github: iOS 11 App Store Transition](https://github.com/aunnnn/AppStoreiOS11InteractiveTransition)
<br/>
[Raywenderlich: Custom View Controller Presentation Transitions](https://www.raywenderlich.com/2925473-ios-animation-tutorial-custom-view-controller-presentation-transitions)

<br/>

# Feedbacks
Looking forward to hear from you