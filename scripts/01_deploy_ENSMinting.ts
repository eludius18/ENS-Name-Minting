import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying ENSMinting contract with the account:", deployer.address);

  try {
    // Deploy ENSMinting contract
    const ENSMintingFactory = await ethers.getContractFactory("ENSMinting");
    const ensMinting = await ENSMintingFactory.deploy(
      "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e", // Replace with the actual ENSRegistry address
      "0x231b0Ee14048e9dCcD1d247744d114a4EB5E8E63", // Replace with the actual PublicResolver address
      "0xa58E81fe9b61B5c3fE2AFD33CF304c454AbFc7Cb" // Replace with the actual ReverseRegistrar address
    );

    await ensMinting.waitForDeployment(); // Wait for the deployment to be mined

    console.log("ENS Minting deployed to:", await ensMinting.getAddress());
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
