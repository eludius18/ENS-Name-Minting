import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract, Signer } from "ethers";
import { keccak256, toUtf8Bytes } from "ethers";

// Utility function to calculate the namehash for ENS names
function namehash(name: string): string {
  let node = '0x' + '00'.repeat(32);
  if (name) {
    let labels = name.split('.');
    for (let i = labels.length - 1; i >= 0; i--) {
      node = keccak256(ethers.concat([node, keccak256(toUtf8Bytes(labels[i]))]));
    }
  }
  return node;
}

describe("ENSMinting and WhitelistedRegistrar", function () {
  let ensMinting: Contract;
  let whitelistedRegistrar: Contract;
  let owner: Signer, addr1: Signer, addr2: Signer;

  // Addresses of already deployed contracts
  const ENSRegistryAddress = "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e"; // Replace with actual ENSRegistry address
  const PublicResolverAddress = "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e"; // Replace with actual PublicResolver address
  const ReverseRegistrarAddress = "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e"; // Replace with actual ReverseRegistrar address
  const ETHRegistrarControllerAddress = "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e"; // Replace with actual ETHRegistrarController address

  before(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    // Attach to the deployed ENSMinting contract
    const ENSMintingFactory = await ethers.getContractFactory("ENSMinting");
    ensMinting = await ENSMintingFactory.deploy(
      ENSRegistryAddress,
      PublicResolverAddress,
      ReverseRegistrarAddress
    );

    // Attach to the deployed WhitelistedRegistrar contract
    const WhitelistedRegistrarFactory = await ethers.getContractFactory("WhitelistedRegistrar");
    whitelistedRegistrar = await WhitelistedRegistrarFactory.deploy(
      ETHRegistrarControllerAddress
    );
  });

  describe("ENSMinting Contract", function () {
    it("should mint ENS name and resolve correctly", async function () {
      const node = namehash("test.eth");
      const name = "test.eth";
      const ownerAddress = await addr1.getAddress();

      // Mint ENS name
      await ensMinting.connect(owner).mintENSName(node, name, ownerAddress);

      // Forward resolve
      const resolvedName = await ensMinting.forwardResolve(ownerAddress);
      expect(resolvedName).to.equal(name);

      // Reverse resolve
      const resolvedAddress = await ensMinting.reverseResolve(name);
      expect(resolvedAddress).to.equal(ownerAddress);
    });
  });

  describe("WhitelistedRegistrar Contract", function () {
    it("should allow whitelisted address to mint", async function () {
      await whitelistedRegistrar.connect(owner).addAddressToWhitelist(await addr1.getAddress());

      const canMintBefore = await whitelistedRegistrar.canMint(await addr1.getAddress());
      expect(canMintBefore).to.be.true;

      await whitelistedRegistrar.connect(addr1).register(
        "example",
        await addr1.getAddress(),
        365 * 24 * 60 * 60, // 1 year
        keccak256(toUtf8Bytes("")), // secret
        ethers.ZeroAddress, // resolver
        [], // data
        false, // reverseRecord
        0 // ownerControlledFuses
      );

      const canMintAfter = await whitelistedRegistrar.canMint(await addr1.getAddress());
      expect(canMintAfter).to.be.true;
    });

    it("should prevent non-whitelisted address from minting", async function () {
      const canMint = await whitelistedRegistrar.canMint(await addr2.getAddress());
      expect(canMint).to.be.false;

      await expect(
        whitelistedRegistrar.connect(addr2).register(
          "example",
          await addr2.getAddress(),
          365 * 24 * 60 * 60, // 1 year
          keccak256(toUtf8Bytes("")), // secret
          ethers.ZeroAddress, // resolver
          [], // data
          false, // reverseRecord
          0 // ownerControlledFuses
        )
      ).to.be.rejectedWith("Not whitelisted");
    });

    it("should allow owner to disable whitelist", async function () {
      await whitelistedRegistrar.connect(owner).disableWhitelist();

      const canMint = await whitelistedRegistrar.canMint(await addr2.getAddress());
      expect(canMint).to.be.true;

      await whitelistedRegistrar.connect(addr2).register(
        "example",
        await addr2.getAddress(),
        365 * 24 * 60 * 60, // 1 year
        keccak256(toUtf8Bytes("")), // secret
        ethers.ZeroAddress, // resolver
        [], // data
        false, // reverseRecord
        0 // ownerControlledFuses
      );
    });
  });
});
