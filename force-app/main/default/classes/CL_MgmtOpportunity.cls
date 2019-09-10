/********************************************************************************
 * Opportunityを管理するクラス。
 * トリガなどで多量のメソッドを実装したときに、
 * DMLの回数が増えないようDML更新はこのクラスに任せる。
 ********************************************************************************/
public class CL_MgmtOpportunity{

/********************************************************************************
 * Field
 ********************************************************************************/
 
    private Map<Id,Opportunity> dmlOpportunityForUpd;
    
/********************************************************************************
 * Constructor
 ********************************************************************************/
    
    /**
     * コンストラクタ
     */
    public CL_MgmtOpportunity(){
        refreshMemberDMLParam();
    }
    
/********************************************************************************
 * Public Method
 ********************************************************************************/
    
    /**
     * メンバ変数[dmlOpportunityForUpd]のセッター
     * 
     * @param argOpportunity メンバ変数[dmlOpportunityForUpd]にセットしたいOpportunityレコード
     */
    public void setDmlOpportunityForUpd(Opportunity argOpportunity){
        Opportunity opp;
        
        if(dmlOpportunityForUpd.containsKey(argOpportunity.id)){
            opp = dmlOpportunityForUpd.get(argOpportunity.id);
        } else {
            opp = new Opportunity(); 
        }
        
        for(String str : argOpportunity.getPopulatedFieldsAsMap().keySet()){
            opp.put(str, argOpportunity.getPopulatedFieldsAsMap().get(str));
        }
            
        dmlOpportunityForUpd.put(opp.id, opp);
            
    }
    /**
     * DML処理を実行する。
     */
    public void executeDML (){
        if(dmlOpportunityForUpd.size() >= 1){
            Database.update(dmlOpportunityForUpd.Values(), false);
        }
        refreshMemberDMLParam();
    }
    
/********************************************************************************
 * Private Method
 ********************************************************************************/

    /**
     * DML処理用メンバ変数を初期化する。
     */
    private void refreshMemberDMLParam(){
        dmlOpportunityForUpd = new Map<Id, Opportunity>();
    }
}