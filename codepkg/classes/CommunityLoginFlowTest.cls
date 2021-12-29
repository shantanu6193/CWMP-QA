@IsTest
public with sharing class CommunityLoginFlowTest {
   @IsTest
    
   public static  void FinishLoginFlowHome(){
	CommunityLoginFlow community = new CommunityLoginFlow();
     PageReference pagRef = community.FinishLoginFlowHome();
   }
}