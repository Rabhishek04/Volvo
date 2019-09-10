/********************************************************************************
 * カバレッジ用CL_OpportunityControllerテストクラス
 ********************************************************************************/
@isTest
private class CL_OpportunityController_Test{

/********************************************************************************
 * Test Method
 ********************************************************************************/

    /**
     * UD車の営業プロセスの時
     */
    static testMethod void testNotVOLVO(){
        List<Account> accList = CL_TestDataFactory_Test.createAccountRecords(1);
        insert accList;
        
        List<Opportunity> oppList = CL_TestDataFactory_Test.createOpportunityAnkenRecords(accList);
        insert oppList;
        
        CL_OpportunityController ctrl = new CL_OpportunityController(oppList[0].Id);
        
        Opportunity opp = ctrl.opp;
        String urlToVSS = ctrl.urlToVSS;
    }

    /**
     * VOLVO車の営業プロセスの時
     */    
    static testMethod void testVOLVO(){
        List<Account> accList = CL_TestDataFactory_Test.createAccountRecords(1);
        insert accList;
        
        List<Opportunity> oppList = CL_TestDataFactory_Test.createOpportunityAnkenRecords(accList);
        // VOLVO車のUD車型をカスタムメタから取得
        oppList[0].UDShagata__c = [SELECT MasterLabel FROM VolvoModelList__mdt LIMIT 1].MasterLabel;
        insert oppList;
        
        CL_OpportunityController ctrl = new CL_OpportunityController(oppList[0].Id);
    }
}