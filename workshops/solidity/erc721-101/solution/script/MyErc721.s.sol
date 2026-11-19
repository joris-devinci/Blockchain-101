// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {MyErc721} from "../src/MyErc721.sol";

interface IEvaluator {
    function submitExercice(address studentExercice) external;
}

interface IEvaluator2 {
    function submitExercice(address studentExercice) external;
}

contract DeployMyErc721 is Script {
    function run() public {
        vm.startBroadcast();

        MyErc721 nft = new MyErc721();

        IEvaluator evaluator = IEvaluator(0xa39ac9c5eF0582f5D0b21770e34c4c54d6e46Fa6);
        IEvaluator2 evaluator2 = IEvaluator2(0xB6C6cf310456Bd0dEE01162A9150EC7ccA146936);

        evaluator.submitExercice(address(nft));
        evaluator2.submitExercice(address(nft));

        vm.stopBroadcast();
    }
}
