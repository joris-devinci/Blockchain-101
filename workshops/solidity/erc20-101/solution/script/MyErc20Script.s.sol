// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {MyErc20} from "../src/MyErc20.sol";

interface IEvaluator {
    function readTicker(address studentAddres) external view returns (string memory);
    function readSupply(address studentAddres) external view returns (uint256);
    function submitExercice(address studentExercice) external;
    function ex0_setupProject() external;
    function ex1_getTickerAndSupply() external;
    function ex2_testErc20TickerAndSupply() external;
    function ex3_testGetToken() external;
    function ex4_testBuyToken() external;
    function ex5_testDenyListing() external;
    function ex6_testAllowListing() external;
    function ex7_testDenyListing() external;
    function ex8_testTier1Listing() external;
    function ex9_testTier2Listing() external;
    function ex10_allInOne() external;
}

contract MyErc20Script is Script {
    IEvaluator private constant EVALUATOR = IEvaluator(0x05A644d6d9BBd85861ff927245aaC13bd56e6d57);

    function runExercise2() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);
        EVALUATOR.ex2_testErc20TickerAndSupply();
        vm.stopBroadcast();
    }

    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address student = vm.addr(privateKey);

        string memory tokenTicker = EVALUATOR.readTicker(student);
        uint256 initialSupply = EVALUATOR.readSupply(student);

        if (bytes(tokenTicker).length == 0) {
            vm.startBroadcast(privateKey);
            EVALUATOR.ex1_getTickerAndSupply();
            vm.stopBroadcast();

            tokenTicker = EVALUATOR.readTicker(student);
            initialSupply = EVALUATOR.readSupply(student);
        }

        require(bytes(tokenTicker).length > 0, "No ticker assigned");
        require(initialSupply > 0, "No supply assigned");

        vm.startBroadcast(privateKey);
        MyErc20 token = new MyErc20(tokenTicker, initialSupply);
        EVALUATOR.submitExercice(address(token));
        EVALUATOR.ex10_allInOne();
        vm.stopBroadcast();
    }
}
