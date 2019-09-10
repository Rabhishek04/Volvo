/********************************************************************************
 * 概要 ： 目標・実績レコード登録、更新バッチのスケジューラ
 ********************************************************************************/
public class CL_UpdMokuhyoJissekiBatch_Sch implements Schedulable{
    /**
     * Schedulableインターフェースのexecuteメソッド
     */
    public void execute(SchedulableContext sc) {
        //バッチ実行
        CL_UpdMokuhyoJissekiBatch batch = new CL_UpdMokuhyoJissekiBatch();

        //集計関数を多数使用する為、バッチサイズは小さくした方が良い
        Database.executeBatch(batch, Integer.valueOf(System.Label.AP01_DEF_0003));
    }

}