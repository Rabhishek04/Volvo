/********************************************************************************
 * カバレッジ用CL_CreateQuoteVSSControllerテストクラス
 ********************************************************************************/
@isTest
private class CL_CreateQuoteVSSController_Test{

/********************************************************************************
 * Test Method
 ********************************************************************************/

    /**
     * メソッドテスト
     */
    static testMethod void methodTest(){
        List<Account> accList = CL_TestDataFactory_Test.createAccountRecords(1);
        insert accList;
        
        List<Opportunity> oppList = CL_TestDataFactory_Test.createOpportunityAnkenRecords(accList);
        insert oppList;
        
        CL_CreateQuoteVSSController.getOpportunity(oppList[0].Id);
    }
}