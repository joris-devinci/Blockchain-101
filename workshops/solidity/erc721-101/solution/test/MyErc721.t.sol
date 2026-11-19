// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {MyErc721} from "../src/MyErc721.sol";

interface IEvaluator {
    function submitExercice(address studentExercice) external;
    function ex1_testERC721() external;
    function ex2a_getAnimalToCreateAttributes() external;
    function ex2b_testDeclaredAnimal(uint256 animalNumber) external;
    function readName(address studentAddress) external view returns (string memory);
    function readLegs(address studentAddress) external view returns (uint256);
    function readSex(address studentAddress) external view returns (uint256);
    function readWings(address studentAddress) external view returns (bool);
}

contract MyErc721Test is Test, IERC721Receiver {
    IEvaluator evaluator;
    MyErc721 nft;

    function setUp() public {
        uint256 id = vm.createFork("https://eth-sepolia.g.alchemy.com/v2/alch_PJ56JlrTEkQJodcDWh93o");
        vm.selectFork(id);

        evaluator = IEvaluator(address(0xa39ac9c5eF0582f5D0b21770e34c4c54d6e46Fa6));

        nft = new MyErc721();
        evaluator.submitExercice(address(nft));
    }

    function test_ex1() public {
        evaluator.ex1_testERC721();
    }

    function test_ex2() public {
        evaluator.ex2a_getAnimalToCreateAttributes();

        nft.registerMeAsBreeder();
        uint256 animalNumber = nft.declareAnimal(
            evaluator.readSex(address(this)),
            evaluator.readLegs(address(this)),
            evaluator.readWings(address(this)),
            evaluator.readName(address(this))
        );
        nft.transferFrom(address(this), address(evaluator), animalNumber);

        evaluator.ex2b_testDeclaredAnimal(animalNumber);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
