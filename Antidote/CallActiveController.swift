//
//  CallActiveController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07.02.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

protocol CallActiveControllerDelegate: class {
    func callActiveController(controller: CallActiveController, mute: Bool)
    func callActiveController(controller: CallActiveController, speaker: Bool)
    func callActiveController(controller: CallActiveController, outgoingVideo: Bool)
    func callActiveControllerDecline(controller: CallActiveController)
}

private struct Constants {
    static let BigCenterContainerTopOffset = 50.0
    static let BigButtonOffset = 30.0

    static let SmallButtonOffset = 20.0
    static let SmallBottomOffset = -20.0
}

class CallActiveController: CallBaseController {
    enum State {
        case None
        case Reaching
        case Active(duration: NSTimeInterval)
    }

    weak var delegate: CallActiveControllerDelegate?

    var type: State = .None {
        didSet {
            switch type {
                case .None:
                    infoLabel.text = nil
                case .Reaching:
                    infoLabel.text = String(localized: "call_reaching")
                case .Active(let duration):
                    infoLabel.text = String(timeInterval: duration)
            }
        }
    }

    var mute: Bool = false {
        didSet {
            bigMuteButton?.selected = mute
            smallMuteButton?.selected = mute
        }
    }

    var speaker: Bool = false {
        didSet {
            bigSpeakerButton?.selected = speaker
            smallSpeakerButton?.selected = speaker
        }
    }

    var outgoingVideo: Bool = false {
        didSet {
            bigVideoButton?.selected = outgoingVideo
            smallVideoButton?.selected = outgoingVideo
        }
    }

    private var bigContainerView: UIView!
    private var bigCenterContainer: UIView!
    private var bigMuteButton: CallButton?
    private var bigSpeakerButton: CallButton?
    private var bigVideoButton: CallButton?
    private var bigDeclineButton: CallButton?

    private var smallContainerView: UIView!
    private var smallMuteButton: CallButton?
    private var smallSpeakerButton: CallButton?
    private var smallVideoButton: CallButton?
    private var smallDeclineButton: CallButton?

    override init(theme: Theme, callerName: String) {
        super.init(theme: theme, callerName: callerName)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()

        createBigViews()
        createSmallViews()
        installConstraints()

        setButtonsInitValues()

        updateViewsWithTraitCollection(self.traitCollection)
    }

    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        updateViewsWithTraitCollection(newCollection)
    }

    override func prepareForRemoval() {
        super.prepareForRemoval()

        bigMuteButton?.enabled = false
        bigSpeakerButton?.enabled = false
        bigVideoButton?.enabled = false
        bigDeclineButton?.enabled = false

        smallMuteButton?.enabled = false
        smallSpeakerButton?.enabled = false
        smallVideoButton?.enabled = false
        smallDeclineButton?.enabled = false
    }
}

// MARK: Actions
extension CallActiveController {
    func muteButtonPressed(button: CallButton) {
        mute = !button.selected
        delegate?.callActiveController(self, mute: mute)
    }

    func speakerButtonPressed(button: CallButton) {
        speaker = !button.selected
        delegate?.callActiveController(self, speaker: speaker)
    }

    func videoButtonPressed(button: CallButton) {
        outgoingVideo = !button.selected
        delegate?.callActiveController(self, outgoingVideo: outgoingVideo)
    }

    func declineButtonPressed() {
        delegate?.callActiveControllerDecline(self)
    }
}

private extension CallActiveController {
    func createBigViews() {
        bigContainerView = UIView()
        bigContainerView.backgroundColor = .clearColor()
        view.addSubview(bigContainerView)

        bigCenterContainer = UIView()
        bigCenterContainer.backgroundColor = .clearColor()
        bigContainerView.addSubview(bigCenterContainer)

        bigMuteButton = addButtonWithType(.Mute, buttonSize: .Big, action: "muteButtonPressed:", container: bigCenterContainer)
        bigSpeakerButton = addButtonWithType(.Speaker, buttonSize: .Big, action: "speakerButtonPressed:", container: bigCenterContainer)
        bigVideoButton = addButtonWithType(.Video, buttonSize: .Big, action: "videoButtonPressed:", container: bigCenterContainer)
        bigDeclineButton = addButtonWithType(.Decline, buttonSize: .Small, action: "declineButtonPressed", container: bigContainerView)
    }

    func createSmallViews() {
        smallContainerView = UIView()
        smallContainerView.backgroundColor = .clearColor()
        view.addSubview(smallContainerView)

        smallMuteButton = addButtonWithType(.Mute, buttonSize: .Small, action: "muteButtonPressed:", container: smallContainerView)
        smallSpeakerButton = addButtonWithType(.Speaker, buttonSize: .Small, action: "speakerButtonPressed:", container: smallContainerView)
        smallVideoButton = addButtonWithType(.Video, buttonSize: .Small, action: "videoButtonPressed:", container: smallContainerView)
        smallDeclineButton = addButtonWithType(.Decline, buttonSize: .Small, action: "declineButtonPressed", container: smallContainerView)
    }

    func addButtonWithType(type: CallButton.ButtonType, buttonSize: CallButton.ButtonSize, action: Selector, container: UIView) -> CallButton {
        let button = CallButton(theme: theme, type: type, buttonSize: buttonSize)
        button.addTarget(self, action: action, forControlEvents: .TouchUpInside)
        container.addSubview(button)

        return button
    }

    func installConstraints() {
        bigContainerView.snp_makeConstraints {
            $0.top.equalTo(topContainer.snp_bottom)
            $0.left.right.bottom.equalTo(view)
        }

        bigCenterContainer.snp_makeConstraints {
            $0.centerX.equalTo(bigContainerView)
            $0.centerY.equalTo(view)
        }

        bigMuteButton!.snp_makeConstraints {
            $0.top.equalTo(bigCenterContainer)
            $0.left.equalTo(bigCenterContainer)
        }

        bigSpeakerButton!.snp_makeConstraints {
            $0.top.equalTo(bigCenterContainer)
            $0.right.equalTo(bigCenterContainer)
            $0.left.equalTo(bigMuteButton!.snp_right).offset(Constants.BigButtonOffset)
        }

        bigVideoButton!.snp_makeConstraints {
            $0.top.equalTo(bigMuteButton!.snp_bottom).offset(Constants.BigButtonOffset)
            $0.left.equalTo(bigCenterContainer)
            $0.bottom.equalTo(bigCenterContainer)
        }

        bigDeclineButton!.snp_makeConstraints {
            $0.centerX.equalTo(bigContainerView)
            $0.top.greaterThanOrEqualTo(bigCenterContainer).offset(Constants.BigButtonOffset)
            $0.bottom.equalTo(bigContainerView).offset(-Constants.BigButtonOffset)
        }

        smallContainerView.snp_makeConstraints {
            $0.bottom.equalTo(view).offset(Constants.SmallBottomOffset)
            $0.centerX.equalTo(view)
        }

        smallMuteButton!.snp_makeConstraints {
            $0.top.bottom.equalTo(smallContainerView)
            $0.left.equalTo(smallContainerView)
        }

        smallSpeakerButton!.snp_makeConstraints {
            $0.top.bottom.equalTo(smallContainerView)
            $0.left.equalTo(smallMuteButton!.snp_right).offset(Constants.SmallButtonOffset)
        }

        smallVideoButton!.snp_makeConstraints {
            $0.top.bottom.equalTo(smallContainerView)
            $0.left.equalTo(smallSpeakerButton!.snp_right).offset(Constants.SmallButtonOffset)
        }

        smallDeclineButton!.snp_makeConstraints {
            $0.top.bottom.equalTo(smallContainerView)
            $0.left.equalTo(smallVideoButton!.snp_right).offset(Constants.SmallButtonOffset)
            $0.right.equalTo(smallContainerView)
        }
    }

    func setButtonsInitValues() {
        bigMuteButton?.selected = mute
        smallMuteButton?.selected = mute

        bigSpeakerButton?.selected = speaker
        smallSpeakerButton?.selected = speaker

        bigVideoButton?.selected = outgoingVideo
        smallVideoButton?.selected = outgoingVideo
    }

    func updateViewsWithTraitCollection(traitCollection: UITraitCollection) {
        switch traitCollection.verticalSizeClass {
            case .Regular:
                bigContainerView.hidden = false
                smallContainerView.hidden = true
            case .Unspecified:
                fallthrough
            case .Compact:
                bigContainerView.hidden = true
                smallContainerView.hidden = false
        }
    }
}
