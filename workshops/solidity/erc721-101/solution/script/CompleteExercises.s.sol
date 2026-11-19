// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {MyErc721} from "../src/MyErc721.sol";

interface IEvaluator {
    function submitExercice(address studentExercice) external;
    function ex1_testERC721() external;
    function ex2a_getAnimalToCreateAttributes() external;
    function ex2b_testDeclaredAnimal(uint256 animalNumber) external;
    function ex3_testRegisterBreeder() external;
    function ex4_testDeclareAnimal() external;
    function ex5_declareDeadAnimal() external;
    function ex6a_auctionAnimal_offer() external;
    function ex6b_auctionAnimal_buy(uint256 animalForSale) external;
    function readName(address studentAddress) external view returns (string memory);
    function readLegs(address studentAddress) external view returns (uint256);
    function readSex(address studentAddress) external view returns (uint256);
    function readWings(address studentAddress) external view returns (bool);
}

interface IEvaluator2 {
    function submitExercice(address studentExercice) external;
    function ex2a_getAnimalToCreateAttributes() external;
    function ex7a_breedAnimalWithParents(uint256 parent1, uint256 parent2) external;
    function ex7b_offerAnimalForReproduction() external;
    function ex7c_payForReproduction(uint256 animalAvailableForReproduction) external;
}

interface IPointsBalance {
    function balanceOf(address account) external view returns (uint256);
}

contract CompleteExercises is Script {
    address private constant EVALUATOR = 0xa39ac9c5eF0582f5D0b21770e34c4c54d6e46Fa6;
    address private constant EVALUATOR2 = 0xB6C6cf310456Bd0dEE01162A9150EC7ccA146936;
    address private constant POINTS = 0x36f7439dB3b9E408B095A9895456A95BA5450D24;
    uint256 private constant PRICE = 0.0001 ether;

    function run() external {
        IEvaluator evaluator = IEvaluator(EVALUATOR);
        IEvaluator2 evaluator2 = IEvaluator2(EVALUATOR2);
        require(EVALUATOR.balance >= PRICE, "Fund Evaluator with at least 0.0001 Sepolia ETH first");
        require(EVALUATOR2.balance >= PRICE, "Fund Evaluator2 with at least 0.0001 Sepolia ETH first");

        vm.startBroadcast();
        (, address user,) = vm.readCallers();

        MyErc721 nft = new MyErc721();
        evaluator.submitExercice(address(nft));
        evaluator2.submitExercice(address(nft));

        evaluator.ex1_testERC721();

        evaluator.ex2a_getAnimalToCreateAttributes();
        nft.registerMeAsBreeder();
        uint256 assignedAnimal = nft.declareAnimal(
            evaluator.readSex(user), evaluator.readLegs(user), evaluator.readWings(user), evaluator.readName(user)
        );
        nft.transferFrom(user, EVALUATOR, assignedAnimal);
        evaluator.ex2b_testDeclaredAnimal(assignedAnimal);

        evaluator.ex3_testRegisterBreeder();
        evaluator.ex4_testDeclareAnimal();

        uint256 keeperAnimal = nft.declareAnimal(1, 2, true, "Keeper");
        evaluator.ex5_declareDeadAnimal();

        evaluator.ex6a_auctionAnimal_offer();
        uint256 saleAnimal = nft.declareAnimal(2, 4, false, "For sale");
        nft.offerForSale(saleAnimal, PRICE);
        evaluator.ex6b_auctionAnimal_buy(saleAnimal);

        uint256 reproductionAnimal = nft.declareAnimal(1, 2, true, "For reproduction");
        uint256 evaluatorParent = nft.tokenOfOwnerByIndex(EVALUATOR, 0);
        evaluator2.ex2a_getAnimalToCreateAttributes();
        evaluator2.ex7a_breedAnimalWithParents(keeperAnimal, evaluatorParent);
        evaluator2.ex7b_offerAnimalForReproduction();
        nft.offerForReproduction(reproductionAnimal, PRICE);
        evaluator2.ex7c_payForReproduction(reproductionAnimal);

        vm.stopBroadcast();

        console2.log("NFT deployed at", address(nft));
        console2.log("Simulated points balance; verify after broadcast", IPointsBalance(POINTS).balanceOf(user));
    }
}
