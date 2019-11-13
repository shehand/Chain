import ballerina/http;
import ballerina/lang.'int as ints;
import ballerina/log;
import ballerina/time;

int startservie = 0;

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
        if (startservie == 0) {
            initBlockchainFunction();
        }

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

        if (req is error) {
            log:printError(req.reason(), err = req);
        } else {

            int | error bpm = ints:fromString(req.BPM.toString());

            if (bpm is int) {
                Block oldBlock = Blockchain[Blockchain.length() - 1];
                Block newBlock = generateBlock(oldBlock, bpm);

                if (isValidBlock(newBlock, oldBlock)) {
                    Blockchain.push(newBlock);
                }

                res.setTextPayload(Blockchain.toString());
                var result = caller->respond(res);

                if (result is error) {
                    log:printError(result.reason(), err = result);
                }

            } else {
                log:printError(bpm.reason(), err = bpm);
            }

        }
    }
}



function initBlockchainFunction() {
    string timestamp = time:toString(time:currentTime());

    Block genesisBlock = new (0, timestamp, 0, "");
    Blockchain.push(genesisBlock);

    startservie = 1;
}
