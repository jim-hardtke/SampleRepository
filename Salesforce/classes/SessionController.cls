public class SessionController {

    @AuraEnabled
    public static String getSessionId() {
        //get session id
        return UserInfo.getSessionId();
    }
    
}