import ballerina/http;

service blockchainService on new http:Listener(8080) {

    resource function returnBlockChain(http:Caller caller, http:Request request) {
        
    }
}