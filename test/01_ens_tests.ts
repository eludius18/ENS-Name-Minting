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

  it("should mint a new ENS name", async function () {
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

  it("should add an address to the whitelist", async function () {
    const addressToWhitelist = "0x1234567890123456789012345678901234567890";
    const tx = await whitelistedRegistrar.addAddressToWhitelist(addressToWhitelist);
    await tx.wait();

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
});