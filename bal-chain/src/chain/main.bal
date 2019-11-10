import ballerina/http;
import ballerina/log;
import ballerina/lang.'int as ints;

@http:ServiceConfig {
    cors: {
        allowCredentials: false,
        allowHeaders: ["CORELATION_ID"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}
service blockchainService on new http:Listener(8080) {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/",
        cors: {
            allowCredentials: true,
            allowHeaders: ["X-Content-Type-Options", "X-PINGOTHER"]
        }
    }
    resource function returnBlockChain(http:Caller caller, http:Request request) {
        http:Response res = new;
        res.setTextPayload(Blockchain.toString());

        var result = caller->respond(res);

        if (result is error) {
            log:printError(result.reason(), err = result);
        }
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/"
    }
    resource function addBlocksToBlockChain(http:Caller caller, http:Request request) {
        http:Response res = new;
        var req = request.getJsonPayload();

        if ( req is error ) {
             log:printError(req.reason(), err = req);
        } else {

            int | error bpm = ints:fromString(req.BPM.toString());

            if (bpm is int) {
                Block newBlock = generateBlock(Blockchain[Blockchain.length() - 1], bpm);
            } else {
                log:printError(bpm.reason(), err = bpm);
            }
            
        }
    }
}