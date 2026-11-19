// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {MyErc20} from "../src/MyErc20.sol";

interface IExerciceSolution {
    function symbol() external view returns (string memory);
    function getToken() external returns (bool);
    function buyToken() external payable returns (bool);
    function isCustomerWhiteListed(address customerAddress) external returns (bool);
    function customerTierLevel(address customerAddress) external returns (uint256);
}

interface IEvaluator {
    function readTicker(address studentAddres) external view returns (string memory);
    function readSupply(address studentAddres) external view returns (uint256);
    function submitExercice(IExerciceSolution studentExercice) external;
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

contract MyErc20Test is Test {

    IEvaluator evaluator;
    IExerciceSolution exerciseSolution;

    function setUp() public {
        uint256 id = vm.createFork("https://eth-sepolia.g.alchemy.com/v2/alch_PJ56JlrTEkQJodcDWh93o");
        vm.selectFork(id);

        evaluator = IEvaluator(
            address(0x05A644d6d9BBd85861ff927245aaC13bd56e6d57)
        );

        evaluator.ex1_getTickerAndSupply();

        string memory ticker = evaluator.readTicker(address(this));
        uint256 supply = evaluator.readSupply(address(this));

        exerciseSolution = IExerciceSolution(
            address(new MyErc20(ticker, supply))
        );

        evaluator.submitExercice(exerciseSolution);
    }

    // function test_ex02() public {   
    //     evaluator.ex2_testErc20TickerAndSupply();
    // }

    // function test_ex03() public {
    //     evaluator.ex3_testGetToken();
    // }

    // function test_ex04() public {
    //     evaluator.ex4_testBuyToken();
    // }

    // function test_ex05() public {
    //     evaluator.ex5_testDenyListing();
    // }

    // function test_ex06() public {
    //     evaluator.ex6_testAllowListing();
    // }

    // function test_ex07() public {
    //     evaluator.ex7_testDenyListing();
    // }

    // function test_ex08() public {
    //     evaluator.ex8_testTier1Listing();
    // }

    // function test_ex09() public {
    //     evaluator.ex9_testTier2Listing();
    // }

    function test_ex10_allInOne() public {
        evaluator.ex10_allInOne();
    }
}   
