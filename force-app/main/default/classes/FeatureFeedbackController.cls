public with sharing class FeatureFeedbackController {

    @AuraEnabled
    public static void toggleFeature(String featureName, Boolean active) {
        FeatureManagement.setPackageBooleanValue(featureName, active);
    }

    @AuraEnabled
    public static FeatureInfo getFeatureInfo(String featureName) {
        try {
            // Determine enablement status and any prior feedback score from this user
            List<FeatureFeedback__c> feedbacks = 
                [select Score__c from FeatureFeedback__c 
                    where FeedbackId__c = :buildFeedbackId(featureName)];
            FeatureInfo fi = new FeatureInfo();
            fi.canManage = FeatureManagement.checkPermission('ManageFeatures');
            fi.active = FeatureManagement.checkPackageBooleanValue(featureName);
            fi.userRating = feedbacks.size()==0 ? null : Integer.valueOf(feedbacks[0].Score__c);
            return fi;
        } catch (Exception e) {
            throw new AuraException(e);
        }
    }

    @AuraEnabled
    public static void rateFeature(String featureName, Integer userRating) {
        try {        
            // User rating as Integer (Aura remoting bug)
            userRating = Integer.valueOf(userRating);
            // Record the users rating
            Feature__c featureRecord = new Feature__c();
            featureRecord.APIName__c = featureName;
            featureRecord.Name = featureName;
            upsert featureRecord APIName__c;
            FeatureFeedback__c feedback = new FeatureFeedback__c();
            feedback.Feature__c = featureRecord.Id;
            feedback.FeedbackId__c = buildFeedbackId(featureName);
            feedback.Name = feedback.FeedbackId__c;
            feedback.Score__c = userRating;
            upsert feedback FeedbackId__c;
            // Calculate the new org average for this feature
            AggregateResult[] groupedResults
                = [select AVG(Score__c) score, COUNT(Score__c) scoreCount 
                    from FeatureFeedback__c
                    where Feature__c = :featureRecord.Id];
            if(groupedResults.size()==1) {
                Decimal feedbackAverage = (Decimal) groupedResults[0].get('score');
                Integer feedbackScore = Integer.valueOf(feedbackAverage * 10);
                Integer feedbackCount = Integer.valueOf(groupedResults[0].get('scoreCount'));
                // Update subscriber record
                featureRecord.AverageScore__c = (Decimal) feedbackScore;
                update featureRecord;
                // Send the average user rating back to the LMO, along with the count
                if(feedbackScore!=null && feedbackCount!=null) {
                    updateFeatureManagement(featureName, feedbackCount, feedbackScore);
                }
            }
        } catch (Exception e) {
            throw new AuraException(e);
        }
    }

    /**
     * Perform FeatureManagement calls in async to avoid MIXED_DML_OPERATION errors
     **/
    @future
    public static void updateFeatureManagement(String featureName, Integer count, Integer score) {
        FeatureManagement.setPackageIntegerValue(featureName+'Count', count);
        FeatureManagement.setPackageIntegerValue(featureName+'Score', score);        
    }

    /**
     * Build unique feature feedback Id for this user context and feature
     **/
    private static String buildFeedbackId(String featureName) {
        return featureName + ':' + String.valueOf(UserInfo.getUserId());
    }

    public class FeatureInfo {
        @AuraEnabled
        public Boolean canManage;
        @AuraEnabled
        public Boolean active;
        @AuraEnabled
        public Integer userRating;
    }
}
