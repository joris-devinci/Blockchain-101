// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {MyErc721} from "../src/MyErc721.sol";

contract MyErc721LocalTest is Test, IERC721Receiver {
    address private constant EVALUATOR = 0xa39ac9c5eF0582f5D0b21770e34c4c54d6e46Fa6;
    address private constant EVALUATOR2 = 0xB6C6cf310456Bd0dEE01162A9150EC7ccA146936;
    address private constant USER = address(0xBEEF);
    uint256 private constant PRICE = 0.0001 ether;

    MyErc721 private token;

    function setUp() public {
        token = new MyErc721();
        vm.deal(EVALUATOR, 1 ether);
        vm.deal(EVALUATOR2, 1 ether);
        vm.deal(USER, 1 ether);
    }

    function test_ex1_tokenOneReturnsToEvaluatorCaller() public {
        assertEq(token.ownerOf(1), EVALUATOR);

        vm.prank(EVALUATOR);
        token.safeTransferFrom(EVALUATOR, address(this), 1);

        assertEq(token.ownerOf(1), address(this));
    }

    function test_ex2ThroughEx5AttributesBreedersMintingAndBurning() public {
        vm.prank(USER);
        token.registerMeAsBreeder();
        vm.prank(USER);
        uint256 assignedAnimal = token.declareAnimal(1, 2, true, "Assigned");
        vm.prank(USER);
        token.transferFrom(USER, EVALUATOR, assignedAnimal);

        assertEq(token.ownerOf(assignedAnimal), EVALUATOR);
        (string memory name, bool wings, uint256 legs, uint256 sex) = token.getAnimalCharacteristics(assignedAnimal);
        assertEq(name, "Assigned");
        assertTrue(wings);
        assertEq(legs, 2);
        assertEq(sex, 1);

        assertFalse(token.isBreeder(EVALUATOR));
        vm.prank(EVALUATOR);
        token.registerMeAsBreeder();
        assertTrue(token.isBreeder(EVALUATOR));

        vm.prank(EVALUATOR);
        uint256 evaluatorAnimal = token.declareAnimal(2, 4, false, "Evaluator");
        assertEq(token.ownerOf(evaluatorAnimal), EVALUATOR);

        vm.prank(USER);
        uint256 userAnimal = token.declareAnimal(0, 4, true, "User");
        vm.prank(EVALUATOR);
        token.declareDeadAnimal(1);
        assertEq(token.balanceOf(EVALUATOR), 2);

        (name, wings, legs, sex) = token.getAnimalCharacteristics(1);
        assertEq(name, "");
        assertFalse(wings);
        assertEq(legs, 0);
        assertEq(sex, 0);

        vm.expectRevert();
        vm.prank(EVALUATOR);
        token.declareDeadAnimal(userAnimal);
    }

    function test_ex6SaleAndPurchase() public {
        vm.prank(EVALUATOR);
        token.registerMeAsBreeder();
        vm.prank(EVALUATOR);
        uint256 evaluatorAnimal = token.declareAnimal(1, 4, false, "Auction");

        vm.expectRevert("Animal is not for sale");
        vm.prank(EVALUATOR);
        token.buyAnimal(evaluatorAnimal);

        vm.prank(EVALUATOR);
        token.offerForSale(evaluatorAnimal, PRICE);
        assertTrue(token.isAnimalForSale(evaluatorAnimal));
        assertEq(token.animalPrice(evaluatorAnimal), PRICE);

        vm.prank(USER);
        token.registerMeAsBreeder();
        vm.prank(USER);
        uint256 userAnimal = token.declareAnimal(2, 2, true, "Seller");
        vm.prank(USER);
        token.offerForSale(userAnimal, PRICE);

        uint256 initialSellerBalance = USER.balance;
        vm.prank(EVALUATOR);
        token.buyAnimal{value: PRICE}(userAnimal);

        assertEq(token.ownerOf(userAnimal), EVALUATOR);
        assertEq(USER.balance, initialSellerBalance + PRICE);
        assertFalse(token.isAnimalForSale(userAnimal));
    }

    function test_ex7ParentsAndPaidReproduction() public {
        vm.prank(USER);
        token.registerMeAsBreeder();
        vm.prank(USER);
        uint256 userParent = token.declareAnimal(1, 2, true, "Parent");
        vm.prank(EVALUATOR2);
        uint256 evaluatorParent = token.declareAnimalWithParents(2, 4, false, "Child", 1, userParent);

        assertEq(token.ownerOf(evaluatorParent), EVALUATOR2);
        (uint256 parent1, uint256 parent2) = token.getParents(evaluatorParent);
        assertEq(parent1, 1);
        assertEq(parent2, userParent);

        vm.prank(EVALUATOR2);
        token.offerForReproduction(evaluatorParent, PRICE);
        assertTrue(token.canReproduce(evaluatorParent));
        assertEq(token.reproductionPrice(evaluatorParent), PRICE);

        vm.prank(USER);
        token.offerForReproduction(userParent, PRICE);
        vm.expectRevert("Reproduction is not authorized");
        vm.prank(EVALUATOR2);
        token.declareAnimalWithParents(2, 4, false, "Unauthorized", evaluatorParent, userParent);

        uint256 initialUserBalance = USER.balance;
        vm.prank(EVALUATOR2);
        token.payForReproduction{value: PRICE}(userParent);
        assertEq(token.authorizedBreederToReproduce(userParent), EVALUATOR2);
        assertEq(USER.balance, initialUserBalance + PRICE);

        vm.prank(EVALUATOR2);
        uint256 offspring = token.declareAnimalWithParents(0, 2, true, "Paid offspring", evaluatorParent, userParent);
        assertEq(token.ownerOf(offspring), EVALUATOR2);
        assertEq(token.authorizedBreederToReproduce(userParent), address(0));
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
