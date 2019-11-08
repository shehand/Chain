import ballerina/crypto;
import ballerina/time;

public type Block object {
    private int index = 0;
    private string timestamp = "";
    private int bpm = 0;
    private string hash = "";
    private string prevhash = "";

    public function __init(int index, string timestamp, int bpm, string prevhash) {
        self.index = index;
        self.timestamp = timestamp;
        self.bpm = bpm;
        self.prevhash = prevhash;
    }

    public function getIndex() returns int {
        return self.index;
    }

    public function getHash() returns string {
        return self.hash;
    }

    public function getPrevHash() returns string {
        return self.prevhash;
    }

    public function getTimeStamp() returns string {
        return self.timestamp;
    }

    public function getBPM() returns int {
        return self.bpm;
    }

    public function setHash(string hash) {
        self.hash = hash;
    }
};

Block [] Blockchain = []; // initialize the blockchain

public function calculateHash(Block block) returns string {

    string records = block.getIndex().toString() + block.getTimeStamp() + block.getBPM().toString() + block.getPrevHash();
    byte[] results = crypto:hashSha256(records.toBytes());

    return results.toBase16();
}

public function generateBlock(Block oldBlock, int BPM) returns Block {

    int index = oldBlock.getIndex() + 1;
    string preHash = oldBlock.getPrevHash();
    string timestamp = time:toString(time:currentTime());

    Block newBlock = new Block(index, timestamp, BPM, preHash);

    string newHash = calculateHash(newBlock);
    newBlock.setHash(newHash);

    return oldBlock;
}

public function isValidBlock(Block newBlock, Block oldBlock) returns boolean {
    
    if (oldBlock.getIndex() + 1 != newBlock.getIndex()) {
        return false;
    }

    if (oldBlock.getHash() != newBlock.getPrevHash()) {
        return false;
    }

    if calculateHash(newBlock) != newBlock.getHash() {
        return false;
    }

    return true;
}

public function replaceChain(Block[] newBlocks) {
    if (newBlocks.length() > Blockchain.length()) {
        Blockchain = newBlocks;
    }
}