({
    doInit: function(cmp) {
        var action = cmp.get("c.getFeatureInfo");        
        action.setParams({ featureName : cmp.get("v.feature") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var featureInfo = response.getReturnValue();
                cmp.set('v.manageFeatures', featureInfo.canManage);
                cmp.set('v.activated', featureInfo.active);
                var userRating = featureInfo.userRating-1; // Base zero adjust
                var ratings = [false, false, false, false, false];
                var rating;
                for(rating = 0; rating < ratings.length; rating++) {
                    ratings[rating] = rating<=userRating ? true : false;
                }
                cmp.set('v.ratings', ratings);
            } else {
                // TODO: Better error handling, https://developer.salesforce.com/blogs/2017/09/error-handling-best-practices-lightning-apex.html
                console.log(response.getError());                
            }
        });
        $A.enqueueAction(action);
    },    
    handleLike : function(cmp, event, helper) {
        // Update the UI
        var score = event.getSource().get('v.name');
        var ratings = cmp.get('v.ratings');
        var rating;
        for(rating = 0; rating < ratings.length; rating++) {
            ratings[rating] = rating<=score ? true : false;
        }
        cmp.set('v.ratings', ratings);
        // Store the users score and update Feature Management
        var action = cmp.get("c.rateFeature");        
        action.setParams({ 
            featureName : cmp.get("v.feature"),
            userRating : parseInt(score)+1 }); // Base zero adjust
        action.setCallback(this, function(response) {
            var state = response.getState();
            // TODO: Better error handling, https://developer.salesforce.com/blogs/2017/09/error-handling-best-practices-lightning-apex.html
            if (state === "ERROR") {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);        
    }
})