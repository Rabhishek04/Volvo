/********************************************************************************
 * 車両レコードの納車予定日をオポチュニティの納車開始日に設定するクラス
 * 振る舞いだけを持つstaticクラス
 ********************************************************************************/
public class CL_CPDDSetToOpportunity{

    /**
     * OpportunityへAssetの納車予定日を反映させる
     * 
     * @param oldAssetMap 更新前の車両レコード
     * @param newAssetMap 更新後の車両レコード
     */
     public static void setCPDDToOpp(Map<Id, Asset> oldAssetMap, Map<Id, Asset> newAssetMap, CL_MgmtOpportunity mgmt){
     
         /* 作成・更新・削除されたAssetレコードの中で、以下の条件に当てはまるレコードのMitsumoriId__cを取得する。*/
         // insert : NoshaYoteibi__cが設定されている
         // update : NoshaYoteibi__cが変更された
         // delete : NoshaYoteibi__cが設定されていた
         
         Set<Id> mtmrId = new Set<Id>();
         
         If(oldAssetMap == null){    // insertの時
             for(Asset ass : newAssetMap.values()){
                 if(ass.InstallDate != null || ass.NoshaYoteibi__c != null){
                     mtmrId.add(ass.MitsumoriID__c);
                 }  
             }
         } else If(newAssetMap == null){    // deleteの時
             for(Asset ass : oldAssetMap.values()){
                 if(ass.InstallDate != null || ass.NoshaYoteibi__c != null){
                     mtmrId.add(ass.MitsumoriID__c);
                 }
             }
         } else {    // updateの時
             for(Asset ass :newAssetMap.values()){ 
                 if(oldAssetMap.containskey(ass.id)){
                     Asset oldAss = oldAssetMap.get(ass.id);
                     if(oldass.InstallDate != ass.InstallDate || oldass.NoshaYoteibi__c != ass.NoshaYoteibi__c){
                         mtmrId.add(ass.MitsumoriId__c);
                     }
                 }
             }
         } 
         
         /* 取得したMitsumoriId__cからMitsumori__cレコードを取得する。*/
         
         List<Mitsumori__c> mtmrList;
         mtmrList = [SELECT Id, (SELECT Id, NoshaYoteibi__c, InstallDate FROM AssetMitsumori__r), Opportunity__c, Opportunity__r.DeliveryStartDate__c FROM Mitsumori__c WHERE Id = :mtmrId];
         
         /* Asset内で最古の納車予定日を取得し、それがブランクでない場合、オポチュニティの納車開始日に設定する */
         
         for(Mitsumori__c mtmr : mtmrList){
             Date oldestCPDD;
             for(Asset ass : mtmr.AssetMitsumori__r){
                 Date dateCPDDorCDC;
                 if(ass.InstallDate != null){
                     dateCPDDorCDC = ass.InstallDate;
                 } else {
                     dateCPDDorCDC = ass.NoshaYoteibi__c;
                 }
                 if(oldestCPDD == null || oldestCPDD > dateCPDDorCDC){
                     oldestCPDD = dateCPDDorCDC;
                 }
             }
             
             if(oldestCPDD != null){
                 Opportunity opp = new Opportunity();
                 opp.Id = mtmr.Opportunity__c;
                 opp.DeliveryStartDate__c = oldestCPDD;
                 
                 mgmt.setDmlOpportunityForUpd(opp);
             } else if(mtmr.AssetMitsumori__r.size() == 0){    // 見積りに紐づく車の数が0の場合
                 Opportunity opp = new Opportunity();
                 opp.Id = mtmr.Opportunity__c;
                 opp.TotalOpportunityQuantity = 0;
                 
                 mgmt.setDmlOpportunityForUpd(opp);
             }
         }
     }
}