// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

interface IEx1Evaluator {
    function ex1_getTickerAndSupply() external;
    function readTicker(address studentAddress) external view returns (string memory);
    function readSupply(address studentAddress) external view returns (uint256);
}

contract ClaimEx1Script is Script {
    IEx1Evaluator private constant EVALUATOR =
        IEx1Evaluator(0x05A644d6d9BBd85861ff927245aaC13bd56e6d57);

    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address student = vm.addr(privateKey);

        string memory ticker = EVALUATOR.readTicker(student);
        uint256 supply = EVALUATOR.readSupply(student);

        if (bytes(ticker).length == 0) {
            vm.startBroadcast(privateKey);
            EVALUATOR.ex1_getTickerAndSupply();
            vm.stopBroadcast();

            ticker = EVALUATOR.readTicker(student);
            supply = EVALUATOR.readSupply(student);
        }

        console2.log("Assigned ticker:");
        console2.log(ticker);
        console2.log("Assigned initial supply (base units):");
        console2.log(supply);
    }
}
