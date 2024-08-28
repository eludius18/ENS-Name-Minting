import { ethers } from "hardhat";
import dotenv from "dotenv";

// Load environment variables from .env file
dotenv.config();

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying ENSMinting contract with the account:", deployer.address);

  try {
    const ENSRegistryAddress = process.env.ENS_REGISTRY_ADDRESS!;
    const PublicResolverAddress = process.env.PUBLIC_RESOLVER_ADDRESS!;
    const ReverseRegistrarAddress = process.env.REVERSE_REGISTRAR_ADDRESS!;

    // Deploy ENSMinting contract
    const ENSMintingFactory = await ethers.getContractFactory("ENSMinting");
    const ensMinting = await ENSMintingFactory.deploy(
      ENSRegistryAddress,
      PublicResolverAddress,
      ReverseRegistrarAddress
    );

    await ensMinting.waitForDeployment();

    const ensMintingAddress = await ensMinting.getAddress();

    console.log("ENS Minting deployed to:", ensMintingAddress);

    // Store or print the address for use in the test script
    console.log(`ENS Minting Contract Address: ${ensMintingAddress}`);
  } catch (error) {
    console.error("Error during deployment:", error);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
