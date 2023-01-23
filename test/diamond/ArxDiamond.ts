import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { describeBehaviorOfSolidStateDiamond } from "@solidstate/spec";
import { ArxDiamond, ArxDiamondMock__factory } from "@arx/typechain-types";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("ArxDiamond", function () {
  let owner: SignerWithAddress;
  let nomineeOwner: SignerWithAddress;
  let nonOwner: SignerWithAddress;

  let instance: ArxDiamond;

  let facetCuts: any[] = [];

  before(async function () {
    [owner, nomineeOwner, nonOwner] = await ethers.getSigners();
  });

  beforeEach(async function () {
    const [deployer] = await ethers.getSigners();
    instance = await new ArxDiamondMock__factory(deployer).deploy(
      owner.address
    );

    const facets = await instance.callStatic["facets()"]();

    expect(facets).to.have.lengthOf(1);

    facetCuts[0] = {
      target: instance.address,
      action: 0,
      selectors: facets[0].selectors,
    };
  });

  describeBehaviorOfSolidStateDiamond(
    async () => instance,
    {
      getOwner: async () => owner,
      getNomineeOwner: async () => nomineeOwner,
      getNonOwner: async () => nonOwner,
      facetFunction: "",
      facetFunctionArgs: [],
      facetCuts,
      fallbackAddress: ethers.constants.AddressZero,
    },
    ["fallback()"]
  );
});
