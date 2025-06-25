import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        UserDefaults.standard.set(["ru"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    private var selectedDevice: ViewImageConfig = .iPhone13Pro
    
    func testOnboardingFirstPage() {
        let page = OnboardingPage(imageName: DefaultController.OnboardingImage.onBoardingBlue.imageName,
                                  titleText: NSLocalizedString("label.onBoardingBlue", comment: ""),
                                  index: 0,
                                  total: 2)
        
        let vc = OnboardingPageViewController(page: page)
        assertSnapshot(of: vc, as: .image(on: selectedDevice), record: false)
    }
    
    func testOnboardingSecondPage() {
        let page = OnboardingPage(imageName: DefaultController.OnboardingImage.onBoardingRed.imageName,
                                  titleText: NSLocalizedString("label.onBoardingRed", comment: ""),
                                  index: 1, total: 2)
        
        let vc = OnboardingPageViewController(page: page)
        assertSnapshot(of: vc, as: .image(on: selectedDevice), record: false)
    }
    
    func testTrackersViewControllerLight(){
        let vc = TrackersViewController()
        let traits = UITraitCollection(userInterfaceStyle: .light)
        assertSnapshot(of: vc, as: .image(on: selectedDevice, traits: traits), record: false)
    }
    
    func testTrackersViewControllerLightDark(){
        let vc = TrackersViewController()
        let traits = UITraitCollection(userInterfaceStyle: .dark)
        assertSnapshot(of: vc, as: .image(on: selectedDevice, traits: traits), record: false)
    }
    
    
    func testTrackerTypeViewControllerLight(){
        let vc = TrackerTypeViewController()
        let traits = UITraitCollection(userInterfaceStyle: .light)
        assertSnapshot(of: vc, as: .image(on: selectedDevice, traits: traits), record: false)
    }
    
    func testTrackerTypeViewControllerDark(){
        let vc = TrackerTypeViewController()
        let traits = UITraitCollection(userInterfaceStyle: .dark)
        assertSnapshot(of: vc, as: .image(on: selectedDevice, traits: traits), record: false)
    }
    
    func testScheduleViewController(){
        let vc = ScheduleViewController()
        assertSnapshot(of: vc, as: .image(on: selectedDevice), record: false)
    }
}
