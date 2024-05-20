const { ethers } = require("ethers");
const dotenv = require("dotenv");
const fs = require("fs");
const csv = require("csv-parser");

// Load environment variables
dotenv.config();
const RPC_URL = "https://mainnet.base.org";
const provider = new ethers.JsonRpcProvider(RPC_URL);
const wallet = new ethers.Wallet(process.env.INTERACTOR_WALLET, provider);
const contractAddress = "0x367B2DF346160Ca2CA30d63b0a3ACCA5FcB02670";
const abi = [
    "function weirdrop(address[] recipients, uint256 value) external"
];
const contract = new ethers.Contract(contractAddress, abi, wallet);

const BATCH_SIZE = 500;
const TOKEN_AMOUNT = ethers.parseUnits("420", 8); // 420 tokens with 8 decimals
const CSV_FILE_PATH = "./addresses.csv";

// Function to read addresses from CSV file
function readAddressesFromCsv(filePath) {
    return new Promise((resolve, reject) => {
        const addresses = [];
        fs.createReadStream(filePath)
            .pipe(csv({ headers: false }))
            .on("data", (row) => {
                const address = Object.values(row)[0];
                addresses.push(address);
            })
            .on("end", () => {
                resolve(addresses);
            })
            .on("error", reject);
    });
}

// Function to validate Ethereum addresses
function isValidAddress(address) {
    try {
        return ethers.isAddress(address);
    } catch {
        return false;
    }
}

// Function to send airdrop transactions
async function sendAirdropTransactions(addresses, startBatch = 0) {
    const totalBatches = Math.ceil(addresses.length / BATCH_SIZE);

    for (let batchIndex = startBatch; batchIndex < totalBatches; batchIndex++) {
        const batchStart = batchIndex * BATCH_SIZE;
        const batchEnd = Math.min(batchStart + BATCH_SIZE, addresses.length);
        const batch = addresses.slice(batchStart, batchEnd);

        // Validate all addresses in the batch
        const invalidAddresses = batch.filter(address => !isValidAddress(address));
        if (invalidAddresses.length > 0) {
            console.error(`Invalid addresses found in batch ${batchIndex + 1}:`, invalidAddresses);
            continue;
        }

        try {
            console.log(`Processing batch ${batchIndex + 1}/${totalBatches}`);

            const tx = await contract.weirdrop(batch, TOKEN_AMOUNT);
            console.log(`Transaction sent: ${tx.hash}`);

            const receipt = await tx.wait();
            console.log(`Transaction confirmed: ${receipt.transactionHash}`);
        } catch (error) {
            console.error(`Error processing batch ${batchIndex + 1}:`, error);
            console.log(`Restarting from batch ${batchIndex + 1}`);
            break;
        }
    }
}

(async () => {
    try {
        const addresses = await readAddressesFromCsv(CSV_FILE_PATH);
        console.log(`Total addresses read: ${addresses.length}`);

        // Additional check to see if addresses are valid
        const invalidAddresses = addresses.filter(address => !isValidAddress(address));
        if (invalidAddresses.length > 0) {
            console.error("Invalid addresses found in CSV:", invalidAddresses);
            return;
        }

        const startBatch = process.argv[2] ? parseInt(process.argv[2], 10) : 0;
        await sendAirdropTransactions(addresses, startBatch);
    } catch (error) {
        console.error("Error in airdrop script:", error);
    }
})();