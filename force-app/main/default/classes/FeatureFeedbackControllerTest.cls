@IsTest
public with sharing class FeatureFeedbackControllerTest {

    @IsTest
    private static void testRating() {
        Test.startTest();
        FeatureFeedbackController.rateFeature('WidgetAnalysis', 2);
        FeatureFeedbackController.FeatureInfo fi = 
            FeatureFeedbackController.getFeatureInfo('WidgetAnalysis');
        Test.stopTest();
        System.assertEquals(2, fi.userRating);
        System.assertEquals(Integer.valueOf(1), FeatureManagement.checkPackageIntegerValue('WidgetAnalysisCount'));
        System.assertEquals(Integer.valueOf(20), FeatureManagement.checkPackageIntegerValue('WidgetAnalysisScore'));
    }
}
