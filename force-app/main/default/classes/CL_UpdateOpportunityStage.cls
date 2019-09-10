/********************************************************************************
 * 概要 ： 営業プロセスのセールスステージを自動更新する
 ********************************************************************************/
public class CL_UpdateOpportunityStage{
    
    /**
     * 渡した見積りレコードに紐づく営業プロセスのセールスステージを自動更新する
     *
     * @param newMtmrList 見積りレコードリスト
     */
    public static void updOppStg(List<Mitsumori__c> newMtmrList){
    
        // 更新された見積りがないなら何もしない
        if(newMtmrList == null || newMtmrList.isEmpty()){
            return;
        }
       
        // 見積りステータスとオポチュニティステージの対比テーブルを取得し、MAP化
        Map<String, String> allocateTbl = new Map<String, String>();
        for(StatusStageAllocation__mdt temp : [SELECT MitsumoriStatus__c, OpportunityStage__c FROM StatusStageAllocation__mdt]){
            if(String.isNotEmpty(temp.MitsumoriStatus__c) && String.isNotEmpty(temp.OpportunityStage__c)){
                allocateTbl.put(temp.MitsumoriStatus__c.toLowerCase(), temp.OpportunityStage__c);
            }
        }
        
        // オポチュニティIDセット
        Set<Id> oppIdSet = new Set<Id>();
        for(Mitsumori__c newMtmr : newMtmrList){
            oppIdSet.add(newMtmr.Opportunity__c);
        }
        
        // オポチュニティ取得
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, StageName, QuoteLinkedFlg__c FROM Opportunity WHERE Id = :oppIdSet]);
        
        // オポチュニティ更新用リスト作成
        List<Opportunity> updOppList = new List<Opportunity>();
        for(Mitsumori__c newMtmr : newMtmrList){
            if(oppMap.containsKey(newMtmr.Opportunity__c)){
                
                Opportunity opp = oppMap.get(newMtmr.Opportunity__c);
                Opportunity oldOpp = opp.clone(true, true, true, true);
                
                // セールスステージステージ更新
                if(ApexTrgFuncEnable__c.getOrgDefaults().SalesStageAutoUpdateFlg__c){
                    if(String.isNotEmpty(newMtmr.Status__c)){
                        String mtmrStatusLower = newMtmr.Status__c.toLowerCase();
                        if(allocateTbl.containsKey(mtmrStatusLower)){
                            opp.StageName = allocateTbl.get(mtmrStatusLower);                       
                        }
                    }
                }
                
                // 見積り紐付フラグ更新
                if(ApexTrgFuncEnable__c.getOrgDefaults().QuoteLinkFlgUpdateFlg__c){
                    opp.QuoteLinkedFlg__c = true;
                }
               
                // オポチュニティ変更確認
                if(opp != oldOpp){
                    updOppList.add(opp);
                }
            }
            
        }
        
        //オポチュニティ更新
        Database.SaveResult[] srList = Database.Update(updOppList, false);
    }
}