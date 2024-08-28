import { ethers } from "hardhat";
import dotenv from "dotenv";

// Load environment variables from .env file
dotenv.config();

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying WhitelistedRegistrar contract with the account:", deployer.address);

  try {
    const ethRegistrarControllerAddress = process.env.ETH_REGISTRAR_CONTROLLER_ADDRESS!;

    const WhitelistedRegistrarFactory = await ethers.getContractFactory("WhitelistedRegistrar");
    const whitelistedRegistrar = await WhitelistedRegistrarFactory.deploy(ethRegistrarControllerAddress);

    await whitelistedRegistrar.waitForDeployment();

    const whitelistedRegistrarAddress = await whitelistedRegistrar.getAddress();

    console.log("WhitelistedRegistrar deployed to:", whitelistedRegistrarAddress);

    // Store or print the address for use in the test script
    console.log(`Whitelisted Registrar Contract Address: ${whitelistedRegistrarAddress}`);
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
