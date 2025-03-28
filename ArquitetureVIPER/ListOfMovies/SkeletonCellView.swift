//
//  MovieCellView.swift
//  ArquitetureVIPER
//
//  Created by Angel Hernández Gámez on 25/03/25.

import UIKit

class SkeletonCellView: UITableViewCell {
    
    let imageSkeletonView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleSkeletonView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let descriptionSkeletonView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        startSkeletonAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(imageSkeletonView)
        addSubview(titleSkeletonView)
        addSubview(descriptionSkeletonView)
        
        NSLayoutConstraint.activate([
            imageSkeletonView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            imageSkeletonView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            imageSkeletonView.heightAnchor.constraint(equalToConstant: 200),
            imageSkeletonView.widthAnchor.constraint(equalToConstant: 100),
            imageSkeletonView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12),
            
            titleSkeletonView.leadingAnchor.constraint(equalTo: imageSkeletonView.trailingAnchor, constant: 18),
            titleSkeletonView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleSkeletonView.topAnchor.constraint(equalTo: imageSkeletonView.topAnchor, constant: 24),
            titleSkeletonView.heightAnchor.constraint(equalToConstant: 24),
            
            descriptionSkeletonView.leadingAnchor.constraint(equalTo: imageSkeletonView.trailingAnchor, constant: 20),
            descriptionSkeletonView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            descriptionSkeletonView.topAnchor.constraint(equalTo: titleSkeletonView.bottomAnchor, constant: 8),
            descriptionSkeletonView.heightAnchor.constraint(equalToConstant: 40),
            descriptionSkeletonView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12)
        ])
    }
    
    private func addSkeletonAnimation(to view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.lightGray.cgColor,
            UIColor.white.cgColor,
            UIColor.lightGray.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = view.bounds
        gradientLayer.locations = [0, 0.5, 1]
        view.layer.addSublayer(gradientLayer)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.0
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "skeletonAnimation")
    }
    
    func startSkeletonAnimation() {
        layoutIfNeeded()
        addSkeletonAnimation(to: imageSkeletonView)
        addSkeletonAnimation(to: titleSkeletonView)
        addSkeletonAnimation(to: descriptionSkeletonView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update the frame of any gradient layers to match the current bounds of their view
        [imageSkeletonView, titleSkeletonView, descriptionSkeletonView].forEach { view in
            view.layer.sublayers?.forEach { layer in
                if let gradientLayer = layer as? CAGradientLayer {
                    gradientLayer.frame = view.bounds
                }
            }
        }
    }
}
