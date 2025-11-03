// import { expect } from "chai";
// import hre from "hardhat";
// import { loadFixture } from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
// import { getAddress, parseEther } from "viem";

// describe("VividNFT", function () {
//     // 部署合约的fixture函数
//     async function deployVividNFTFixture() {
//         const [owner, account1, account2, account3] = await hre.viem.getWalletClients();

//         const vividNFT = await hre.viem.deployContract("VividNFT", [
//             "Vivid NFT Collection", // 合约名称 - 用户可根据需要修改
//             "VIVID" // 合约符号 - 用户可根据需要修改
//         ]);

//         const publicClient = await hre.viem.getPublicClient();

//         return {
//             vividNFT,
//             owner,
//             account1,
//             account2,
//             account3,
//             publicClient,
//         };
//     }

//     describe("部署", function () {
//         it("应该正确设置名称和符号", async function () {
//             const { vividNFT } = await loadFixture(deployVividNFTFixture);

//             expect(await vividNFT.read.name()).to.equal("Vivid NFT Collection");
//             expect(await vividNFT.read.symbol()).to.equal("VIVID");
//         });

//         it("应该将部署者设置为所有者", async function () {
//             const { vividNFT, owner } = await loadFixture(deployVividNFTFixture);

//             expect(await vividNFT.read.owner()).to.equal(getAddress(owner.account.address));
//         });

//         it("初始token ID计数器应该为0", async function () {
//             const { vividNFT } = await loadFixture(deployVividNFTFixture);

//             expect(await vividNFT.read.getCurrentTokenId()).to.equal(0n);
//             expect(await vividNFT.read.totalSupply()).to.equal(0n);
//         });
//     });

//     describe("单次铸造", function () {
//         it("所有者应该能够铸造NFT", async function () {
//             const { vividNFT, owner, account1 } = await loadFixture(deployVividNFTFixture);

//             const tokenURI = "https://example.com/token/1"; // 用户可替换为实际元数据URI

//             const tx = await vividNFT.write.safeMint([
//                 account1.account.address,
//                 tokenURI
//             ], { account: owner.account });

//             // 验证token ID计数器增加
//             expect(await vividNFT.read.getCurrentTokenId()).to.equal(1n);
//             expect(await vividNFT.read.totalSupply()).to.equal(1n);

//             // 验证NFT所有权
//             expect(await vividNFT.read.ownerOf([0n])).to.equal(getAddress(account1.account.address));

//             // 验证token URI
//             expect(await vividNFT.read.tokenURI([0n])).to.equal(tokenURI);

//             // 验证URI使用标记
//             expect(await vividNFT.read.isURIUsed([tokenURI])).to.be.true;

//             // 验证token存在性
//             expect(await vividNFT.read.exists([0n])).to.be.true;
//         });

//         it("应该触发TokenMinted事件", async function () {
//             const { vividNFT, owner, account1, publicClient } = await loadFixture(deployVividNFTFixture);

//             const tokenURI = "https://example.com/token/2"; // 用户可替换为实际元数据URI

//             const hash = await vividNFT.write.safeMint([
//                 account1.account.address,
//                 tokenURI
//             ], { account: owner.account });

//             const receipt = await publicClient.getTransactionReceipt({ hash });

//             // 查找TokenMinted事件
//             const mintEvent = receipt.logs.find(log =>
//                 log.address.toLowerCase() === vividNFT.address.toLowerCase()
//             );

//             expect(mintEvent).to.not.be.undefined;
//         });

//         it("非所有者不应该能够铸造NFT", async function () {
//             const { vividNFT, account1, account2 } = await loadFixture(deployVividNFTFixture);

//             const tokenURI = "https://example.com/token/3"; // 用户可替换为实际元数据URI

//             await expect(
//                 vividNFT.write.safeMint([
//                     account2.account.address,
//                     tokenURI
//                 ], { account: account1.account })
//             ).to.be.rejectedWith("OwnableUnauthorizedAccount");
//         });

//         it("不应该允许使用空的tokenURI", async function () {
//             const { vividNFT, owner, account1 } = await loadFixture(deployVividNFTFixture);

//             await expect(
//                 vividNFT.write.safeMint([
//                     account1.account.address,
//                     ""
//                 ], { account: owner.account })
//             ).to.be.rejectedWith("VividNFT: tokenURI cannot be empty");
//         });

//         it("不应该允许使用重复的tokenURI", async function () {
//             const { vividNFT, owner, account1 } = await loadFixture(deployVividNFTFixture);

//             const tokenURI = "https://example.com/token/4"; // 用户可替换为实际元数据URI

//             // 第一次铸造应该成功
//             await vividNFT.write.safeMint([
//                 account1.account.address,
//                 tokenURI
//             ], { account: owner.account });

//             // 第二次使用相同URI应该失败
//             await expect(
//                 vividNFT.write.safeMint([
//                     account1.account.address,
//                     tokenURI
//                 ], { account: owner.account })
//             ).to.be.rejectedWith("VividNFT: tokenURI already used");
//         });
//     });

//     describe("批量铸造", function () {
//         it("所有者应该能够批量铸造NFT", async function () {
//             const { vividNFT, owner, account1, account2 } = await loadFixture(deployVividNFTFixture);

//             const recipients = [
//                 account1.account.address,
//                 account2.account.address,
//                 account1.account.address
//             ];

//             const tokenURIs = [
//                 "https://example.com/token/5", // 用户可替换为实际元数据URI
//                 "https://example.com/token/6", // 用户可替换为实际元数据URI
//                 "https://example.com/token/7"  // 用户可替换为实际元数据URI
//             ];

//             await vividNFT.write.batchMint([recipients, tokenURIs], {
//                 account: owner.account
//             });

//             // 验证token ID计数器增加
//             expect(await vividNFT.read.getCurrentTokenId()).to.equal(3n);
//             expect(await vividNFT.read.totalSupply()).to.equal(3n);

//             // 验证NFT所有权
//             expect(await vividNFT.read.ownerOf([0n])).to.equal(getAddress(account1.account.address));
//             expect(await vividNFT.read.ownerOf([1n])).to.equal(getAddress(account2.account.address));
//             expect(await vividNFT.read.ownerOf([2n])).to.equal(getAddress(account1.account.address));

//             // 验证token URIs
//             expect(await vividNFT.read.tokenURI([0n])).to.equal(tokenURIs[0]);
//             expect(await vividNFT.read.tokenURI([1n])).to.equal(tokenURIs[1]);
//             expect(await vividNFT.read.tokenURI([2n])).to.equal(tokenURIs[2]);

//             // 验证所有URI都被标记为已使用
//             for (const uri of tokenURIs) {
//                 expect(await vividNFT.read.isURIUsed([uri])).to.be.true;
//             }
//         });

//         it("批量铸造应该处理空数组", async function () {
//             const { vividNFT, owner } = await loadFixture(deployVividNFTFixture);

//             await expect(
//                 vividNFT.write.batchMint([[], []], { account: owner.account })
//             ).to.be.rejectedWith("VividNFT: empty arrays");
//         });

//         it("批量铸造应该验证数组长度匹配", async function () {
//             const { vividNFT, owner, account1 } = await loadFixture(deployVividNFTFixture);

//             const recipients = [account1.account.address];
//             const tokenURIs = ["uri1", "uri2"]; // 长度不匹配

//             await expect(
//                 vividNFT.write.batchMint([recipients, tokenURIs], { account: owner.account })
//             ).to.be.rejectedWith("VividNFT: arrays length mismatch");
//         });

//         it("批量铸造应该限制批次大小", async function () {
//             const { vividNFT, owner, account1 } = await loadFixture(deployVividNFTFixture);

//             // 创建51个元素的数组（超过限制）
//             const largeArray = Array(51).fill(account1.account.address);
//             const largeURIs = Array(51).fill("https://example.com/token/");

//             await expect(
//                 vividNFT.write.batchMint([largeArray, largeURIs], { account: owner.account })
//             ).to.be.rejectedWith("VividNFT: batch too large");
//         });
//     });

//     describe("更新token URI", function () {
//         it("所有者应该能够更新token URI", async function () {
//             const { vividNFT, owner, account1, publicClient } = await loadFixture(deployVividNFTFixture);

//             const originalURI = "https://example.com/token/original"; // 用户可替换为实际元数据URI
//             const newURI = "https://example.com/token/updated"; // 用户可替换为实际元数据URI

//             // 先铸造一个NFT
//             await vividNFT.write.safeMint([
//                 account1.account.address,
//                 originalURI
//             ], { account: owner.account });

//             // 验证原始URI被标记为已使用
//             expect(await vividNFT.read.isURIUsed([originalURI])).to.be.true;
//             expect(await vividNFT.read.isURIUsed([newURI])).to.be.false;

//             // 更新token URI
//             const hash = await vividNFT.write.updateTokenURI([0n, newURI], {
//                 account: owner.account
//             });

//             const receipt = await publicClient.getTransactionReceipt({ hash });

//             // 验证token URI已更新
//             expect(await vividNFT.read.tokenURI([0n])).to.equal(newURI);

//             // 验证URI使用标记已更新
//             expect(await vividNFT.read.isURIUsed([originalURI])).to.be.false;
//             expect(await vividNFT.read.isURIUsed([newURI])).to.be.true;

//             // 查找TokenURIUpdated事件
//             const updateEvent = receipt.logs.find(log =>
//                 log.address.toLowerCase() === vividNFT.address.toLowerCase()
//             );

//             expect(updateEvent).to.not.be.undefined;
//         });

//         it("不应该更新不存在的token", async function () {
//             const { vividNFT, owner } = await loadFixture(deployVividNFTFixture);

//             const newURI = "https://example.com/token/nonexistent"; // 用户可替换为实际元数据URI

//             await expect(
//                 vividNFT.write.updateTokenURI([999n, newURI], { account: owner.account })
//             ).to.be.rejectedWith("VividNFT: token does not exist");
//         });

//         it("不应该允许使用已存在的URI进行更新", async function () {
//             const { vividNFT, owner, account1, account2 } = await loadFixture(deployVividNFTFixture);

//             const uri1 = "https://example.com/token/uri1"; // 用户可替换为实际元数据URI
//             const uri2 = "https://example.com/token/uri2"; // 用户可替换为实际元数据URI

//             // 铸造两个NFT
//             await vividNFT.write.safeMint([
//                 account1.account.address,
//                 uri1
//             ], { account: owner.account });

//             await vividNFT.write.safeMint([
//                 account2.account.address,
//                 uri2
//             ], { account: owner.account });

//             // 尝试将第一个token的URI更新为第二个token正在使用的URI
//             await expect(
//                 vividNFT.write.updateTokenURI([0n, uri2], { account: owner.account })
//             ).to.be.rejectedWith("VividNFT: tokenURI already used");
//         });
//     });

//     describe("视图函数", function () {
//         it("应该正确报告URI使用状态", async function () {
//             const { vividNFT, owner, account1 } = await loadFixture(deployVividNFTFixture);

//             const usedURI = "https://example.com/token/used"; // 用户可替换为实际元数据URI
//             const unusedURI = "https://example.com/token/unused"; // 用户可替换为实际元数据URI

//             // 铸造一个NFT
//             await vividNFT.write.safeMint([
//                 account1.account.address,
//                 usedURI
//             ], { account: owner.account });

//             expect(await vividNFT.read.isURIUsed([usedURI])).to.be.true;
//             expect(await vividNFT.read.isURIUsed([unusedURI])).to.be.false;
//         });

//         it("应该正确报告token存在性", async function () {
//             const { vividNFT, owner, account1 } = await loadFixture(deployVividNFTFixture);

//             const tokenURI = "https://example.com/token/exists"; // 用户可替换为实际元数据URI

//             // 铸造前token 0不应该存在
//             expect(await vividNFT.read.exists([0n])).to.be.false;

//             // 铸造一个NFT
//             await vividNFT.write.safeMint([
//                 account1.account.address,
//                 tokenURI
//             ], { account: owner.account });

//             // 铸造后token 0应该存在
//             expect(await vividNFT.read.exists([0n])).to.be.true;
//             expect(await vividNFT.read.exists([1n])).to.be.false; // 不存在的token
//         });
//     });

//     describe("ERC721标准功能", function () {
//         it("应该支持ERC721接口", async function () {
//             const { vividNFT } = await loadFixture(deployVividNFTFixture);

//             // ERC721接口ID
//             const erc721InterfaceId = "0x80ac58cd";
//             expect(await vividNFT.read.supportsInterface([erc721InterfaceId])).to.be.true;

//             // ERC721Metadata接口ID
//             const metadataInterfaceId = "0x5b5e139f";
//             expect(await vividNFT.read.supportsInterface([metadataInterfaceId])).to.be.true;
//         });

//         it("应该正确处理token转移", async function () {
//             const { vividNFT, owner, account1, account2 } = await loadFixture(deployVividNFTFixture);

//             const tokenURI = "https://example.com/token/transfer"; // 用户可替换为实际元数据URI

//             // 铸造NFT给account1
//             await vividNFT.write.safeMint([
//                 account1.account.address,
//                 tokenURI
//             ], { account: owner.account });

//             // account1转移NFT给account2
//             await vividNFT.write.transferFrom([
//                 account1.account.address,
//                 account2.account.address,
//                 0n
//             ], { account: account1.account });

//             // 验证所有权转移
//             expect(await vividNFT.read.ownerOf([0n])).to.equal(getAddress(account2.account.address));

//             // token URI应该保持不变
//             expect(await vividNFT.read.tokenURI([0n])).to.equal(tokenURI);
//         });
//     });
// });