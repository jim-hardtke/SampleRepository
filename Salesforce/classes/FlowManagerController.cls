public class FlowManagerController {

    private static final string RESOURCE_TOOLING_QUERY_FLOW = '/tooling/query?q=Select+Id,ActiveVersion.VersionNumber,LatestVersion.VersionNumber,DeveloperName+From+FlowDefinition+ORDER+BY+DeveloperName';
    private static final string RESOURCE_TOOLING_SOBJECT_FLOW = '/tooling/sobjects/FlowDefinition/';

    @AuraEnabled
    public static String getFlows() {

        HttpResponse response = executeCallout('GET', RESOURCE_TOOLING_QUERY_FLOW, null);

        System.debug(response);

        if (response.getStatusCode() == 200) {
            return response.getBody();
        }

        throw new AuraHandledException(response.toString());
    }

    @AuraEnabled
    public static boolean updateFlow(String flowId, String metadata) {

        HttpResponse response = executeCallout('PATCH', RESOURCE_TOOLING_SOBJECT_FLOW + flowId + '/?_HttpMethod=PATCH', metadata);

        System.debug(response);

        if (response.getStatusCode() == 200 || response.getStatusCode() == 204) {
            return true;
        }

        return false;
    }

    public static HttpResponse executeCallout(String method, String resourceName, String requestBody) {

        HttpRequest request = new HttpRequest();

        if (method == 'PATCH') {
            request.setMethod('POST');    
        } else {
            request.setMethod(method);    
        }

        request.setEndpoint(getUrl() + resourceName);

        request.setHeader('Authorization', 'OAuth {!$Credential.OAuthToken}');

        request.setHeader('Accept', 'application/json');
        request.setHeader('X-PrettyPrint', '1');
        request.setHeader('Content-Type', 'application/json');

        if (String.isNotBlank(requestBody)) {
            request.setBody(requestBody);
        }

        System.debug(request);

        return new Http().send(request);
    }

    private static String getUrl(){
        return 'callout:Named_Credential'; // CHANGE THIS
    }
}