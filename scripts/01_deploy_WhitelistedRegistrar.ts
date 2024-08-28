import { ethers } from "hardhat";

  async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying WhitelistedRegistrar contract with the account:", deployer.address);
  
    try {
      const ethRegistrarControllerAddress = "0x253553366Da8546fC250F225fe3d25d0C782303b"; 
  
      const WhitelistedRegistrarFactory = await ethers.getContractFactory("WhitelistedRegistrar");
      const whitelistedRegistrar = await WhitelistedRegistrarFactory.deploy(ethRegistrarControllerAddress);
  
      await whitelistedRegistrar.waitForDeployment();
      console.log("WhitelistedRegistrar deployed to:", await whitelistedRegistrar.getAddress());
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
  
