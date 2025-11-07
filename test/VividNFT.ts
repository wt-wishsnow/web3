import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { network } from "hardhat";
import { getAddress } from "viem";
import { devNull } from "node:os";

describe("VividNFT", async function () {
    // const { viem } = await network.connect();
    const { viem } = await network.connect("sepolia");
    const publicClient = await viem.getPublicClient();
    const [owner] = await viem.getWalletClients();
    // 打印部署者钱包地址
    console.log(`Using deployer: ${owner.account.address}`);

    it("Should successfully mint an NFT", async function () {
        const contractAddress = "0x680C94e8620731941dF7dE78507c1d9B93618917";
        const vividNFT = await viem.getContractAt("VividNFT", contractAddress);
        // const vividNFT = await viem.deployContract("VividNFT", ["VividNFT", "VNFT"]);

        const tokenId = 2n;

        const testURI = "https://copper-central-kangaroo-407.mypinata.cloud/ipfs/bafkreidhdfbprv2bqs24qkloa3malixqayn6uq56raisgod3uh6vtc37rq"
        const to = owner.account.address;

        const hash = await vividNFT.write.safeMint([to, testURI]);
        console.log(`Transaction hash: ${hash}`);

        // 等待确认
        const receipt = await publicClient.waitForTransactionReceipt({ hash });
        assert.equal(receipt.status, "success");

        // 验证所有权
        const ownerOfToken = await vividNFT.read.ownerOf([tokenId]);
        assert.equal(
            ownerOfToken,
            getAddress(to)
        );

        // 验证 tokenURI
        const tokenURI = await vividNFT.read.tokenURI([tokenId]);
        assert.equal(tokenURI, testURI);

        // await viem.assertions.emitWithArgs(
        //     vividNFT.write.safeMint([to, testURI]),    // 合约调用（返回 Promise<Hash>）
        //     vividNFT,                // 合约实例
        //     "TokenMinted",            // 事件名称
        //     [getAddress(to), tokenId, testURI]                    // 预期的事件参数
        // );

        // 手动验证事件
        const events = await vividNFT.getEvents.TokenMinted();
        const mintEvents = events.filter(event => event.transactionHash === hash);

        assert.ok(mintEvents.length > 0, "TokenMinted event should be emitted");

        // 安全地访问事件参数
        const mintEvent = mintEvents[0];
        if (mintEvent && mintEvent.args) {
            assert.equal(mintEvent.args.to!.toLowerCase(), to.toLowerCase());
            assert.equal(mintEvent.args.tokenId!, tokenId);
            assert.equal(mintEvent.args.tokenURI!, testURI);
        } else {
            assert.fail("Event args should not be undefined");
        }

        console.log("✅ NFT minted successfully!");
    });
});


// npx hardhat keystore set SEPOLIA_RPC_URL --dev
// npx hardhat keystore set SEPOLIA_PRIVATE_KEY --dev

// npx hardhat keystore set SEPOLIA_RPC_URL
// npx hardhat keystore set SEPOLIA_PRIVATE_KEY