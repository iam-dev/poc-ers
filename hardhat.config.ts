import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-abi-exporter";
import "hardhat-preprocessor";
import "hardhat-spdx-license-identifier";
import fs from "fs";

function getRemappings() {
  return fs
    .readFileSync("remappings.txt", "utf8")
    .split("\n")
    .filter(Boolean) // remove empty lines
    .map((line) => line.trim().split("="));
}

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  preprocess: {
    eachLine: (hre) => ({
      transform: (line: string) => {
        if (line.match(/^\s*import /i)) {
          for (const [from, to] of getRemappings()) {
            if (line.includes(from)) {
              line = line.replace(from, to);
              break;
            }
          }
        }
        return line;
      },
    }),
  },
  gasReporter: {
    enabled: true,
  },

  typechain: {
    alwaysGenerateOverloads: true,
  },

  abiExporter: {
    runOnCompile: true,
    clear: true,
    flat: true,
    except: [".*Mock$"],
  },

  spdxLicenseIdentifier: {
    overwrite: false,
    runOnCompile: true,
  },

  paths: {
    cache: "./cache_hardhat",
  },
};

export default config;
