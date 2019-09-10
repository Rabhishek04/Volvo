/********************************************************************************
 * CreateQuoteVSSコンポーネントのコントローラ
 ********************************************************************************/
public class CL_CreateQuoteVSSController{

/********************************************************************************
 * Public Method
 ********************************************************************************/
 
    /**
     * コンポーネント側で管理したい営業プロセスレコードを取得する
     * 
     * @param oppId 取得したい営業プロセスレコードのSFID
     */
    @AuraEnabled 
    public static CL_OpportunityController getOpportunity(Id oppId){
        return new CL_OpportunityController(oppId);
    }
}