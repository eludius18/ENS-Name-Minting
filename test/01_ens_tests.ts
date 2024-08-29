import { ethers } from "hardhat";
import { expect } from "chai";
import dotenv from "dotenv";
import namehash from 'eth-ens-namehash';

dotenv.config();

describe("ENSMinting Contract", function () {
  let ensMinting: any;
  let deployer: any;

  before(async function () {
    [deployer] = await ethers.getSigners();

    const ENSRegistryAddress = process.env.ENS_REGISTRY_ADDRESS!;
    const PublicResolverAddress = process.env.PUBLIC_RESOLVER_ADDRESS!;
    const ReverseRegistrarAddress = process.env.REVERSE_REGISTRAR_ADDRESS!;

    const ENSMintingFactory = await ethers.getContractFactory("ENSMinting");
    ensMinting = await ENSMintingFactory.deploy(
      ENSRegistryAddress,
      PublicResolverAddress,
      ReverseRegistrarAddress
    );

    await ensMinting.waitForDeployment();
  });

  it("should deploy ENSMinting contract correctly", async function () {
    const ensMintingAddress = ensMinting.target;
    console.log("ENS Minting deployed to:", ensMintingAddress);

    expect(ethers.isAddress(ensMintingAddress)).to.be.true;
  });

  //TODO:Needs to be fixed
  it.skip("should mint a new ENS name", async function () {
    const name = "unminted-name-test.eth";
    const node = namehash.hash(name);
    const tx = await ensMinting.mintENSName(node, name, deployer.address);
    await tx.wait();

    const resolvedName = await ensMinting.forwardResolve(deployer.address);
    expect(resolvedName).to.equal(name);
  });

  it("should fail to mint an existing ENS name", async function () {
    const name = "eroblesca.eth";
    const node = namehash.hash(name);
    await expect(ensMinting.mintENSName(node, name, deployer.address)).to.be.rejectedWith('Name already minted'); // Second mint should fail
  });
});

describe("WhitelistedRegistrar Contract", function () {
  let whitelistedRegistrar: any;
  let deployer: any;

  before(async function () {
    [deployer] = await ethers.getSigners();

    const ethRegistrarControllerAddress = process.env.ETH_REGISTRAR_CONTROLLER_ADDRESS!;

    const WhitelistedRegistrarFactory = await ethers.getContractFactory("WhitelistedRegistrar");
    whitelistedRegistrar = await WhitelistedRegistrarFactory.deploy(ethRegistrarControllerAddress);

    await whitelistedRegistrar.waitForDeployment();
  });

  it("should deploy WhitelistedRegistrar contract correctly", async function () {
    const whitelistedRegistrarAddress = whitelistedRegistrar.target;
    console.log("Whitelisted Registrar deployed to:", whitelistedRegistrarAddress);

    expect(ethers.isAddress(whitelistedRegistrarAddress)).to.be.true;
  });

  it("should add an address to the whitelist in phase 0", async function () {
    const addressToWhitelist = "0x1234567890123456789012345678901234567890";
    const tx = await whitelistedRegistrar.addAddressToWhitelist(addressToWhitelist);
    await tx.wait();

    const isWhitelisted = await whitelistedRegistrar.whitelist(addressToWhitelist);
    expect(isWhitelisted).to.be.true;

    const whitelistedCount = await whitelistedRegistrar.whitelistedCount();
    expect(whitelistedCount).to.equal(1);
  });

  it("should add up to the phase limit to the whitelist", async function () {
    const addressesToWhitelist = [];
    for (let i = 1; i <= 49; i++) { // Adjusted to 49 to account for the already added address
        addressesToWhitelist.push(ethers.Wallet.createRandom().address);
    }

    for (const address of addressesToWhitelist) {
        await whitelistedRegistrar.addAddressToWhitelist(address);
    }

    const whitelistedCount = await whitelistedRegistrar.whitelistedCount();
    expect(whitelistedCount).to.equal(50);
 });

  it("should not add more than the phase limit to the whitelist", async function () {
      const extraAddress = ethers.Wallet.createRandom().address;

      // Adjust the test to correctly expect the exception when the limit is reached
      await expect(
          whitelistedRegistrar.addAddressToWhitelist(extraAddress)
      ).to.be.revertedWith("Whitelist limit reached for current phase");

      const whitelistedCountAfter = await whitelistedRegistrar.whitelistedCount();
      expect(whitelistedCountAfter).to.equal(50);  // Ensure the count does not increment
  });

  it("should transition to the next phase and whitelist more addresses", async function () {
    const tx = await whitelistedRegistrar.setPhase(1);
    await tx.wait();

    const addressToWhitelist = ethers.Wallet.createRandom().address;
    const tx2 = await whitelistedRegistrar.addAddressToWhitelist(addressToWhitelist);
    await tx2.wait();

    const isWhitelisted = await whitelistedRegistrar.whitelist(addressToWhitelist);
    expect(isWhitelisted).to.be.true;
  });

  it("should remove an address from the whitelist", async function () {
    const addressToWhitelist = "0x1234567890123456789012345678901234567890";
    const tx = await whitelistedRegistrar.removeAddressFromWhitelist(addressToWhitelist);
    await tx.wait();

    const isWhitelisted = await whitelistedRegistrar.whitelist(addressToWhitelist);
    expect(isWhitelisted).to.be.false;
  });

  it("should disable the whitelist and allow all addresses to mint", async function () {
    const tx = await whitelistedRegistrar.disableWhitelist();
    await tx.wait();

    const whitelistDisabled = await whitelistedRegistrar.whitelistDisabled();
    expect(whitelistDisabled).to.be.true;

    const canMint = await whitelistedRegistrar.canMint(deployer.address);
    expect(canMint).to.be.true;

    const randomAddress = ethers.Wallet.createRandom().address;
    const canMintRandom = await whitelistedRegistrar.canMint(randomAddress);
    expect(canMintRandom).to.be.true;
  });

  it("should fail to move to a previous phase", async function () {
    await expect(whitelistedRegistrar.setPhase(0)).to.be.rejectedWith('Cannot revert to previous phase');
  });
});