// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract MyErc721 is ERC721Enumerable, IERC721Receiver {
    struct Animal {
        string name;
        bool wings;
        uint256 legs;
        uint256 sex;
    }

    address private constant EVALUATOR = 0xa39ac9c5eF0582f5D0b21770e34c4c54d6e46Fa6;

    mapping(address => bool) private _breeders;
    mapping(uint256 => Animal) private _animals;
    mapping(uint256 => uint256) private _parent1;
    mapping(uint256 => uint256) private _parent2;
    mapping(uint256 => bool) private _isForSale;
    mapping(uint256 => uint256) private _animalPrice;
    mapping(uint256 => uint256) private _reproductionPrice;
    mapping(uint256 => address) private _authorizedBreederToReproduce;

    uint256 private _nextAnimalNumber = 2;

    modifier onlyBreeder() {
        require(_breeders[msg.sender], "Caller is not a breeder");
        _;
    }

    constructor() ERC721("My NFT", "MNFT") {
        _mint(EVALUATOR, 1);
    }

    function isBreeder(address account) external view returns (bool) {
        return _breeders[account];
    }

    function registrationPrice() external pure returns (uint256) {
        return 0;
    }

    function registerMeAsBreeder() external payable {
        require(msg.value == 0, "Incorrect registration payment");
        _breeders[msg.sender] = true;
    }

    function declareAnimal(uint256 sex, uint256 legs, bool wings, string calldata name)
        external
        onlyBreeder
        returns (uint256)
    {
        return _createAnimal(msg.sender, sex, legs, wings, name);
    }

    function getAnimalCharacteristics(uint256 animalNumber)
        external
        view
        returns (string memory name, bool wings, uint256 legs, uint256 sex)
    {
        Animal storage animal = _animals[animalNumber];
        return (animal.name, animal.wings, animal.legs, animal.sex);
    }

    function declareDeadAnimal(uint256 animalNumber) external {
        require(ownerOf(animalNumber) == msg.sender, "Caller does not own animal");

        _burn(animalNumber);
        delete _animals[animalNumber];
        delete _parent1[animalNumber];
        delete _parent2[animalNumber];
        delete _isForSale[animalNumber];
        delete _animalPrice[animalNumber];
        delete _reproductionPrice[animalNumber];
        delete _authorizedBreederToReproduce[animalNumber];
    }

    function offerForSale(uint256 animalNumber, uint256 price) external {
        require(ownerOf(animalNumber) == msg.sender, "Caller does not own animal");
        require(price > 0, "Price must be greater than zero");

        _isForSale[animalNumber] = true;
        _animalPrice[animalNumber] = price;
    }

    function isAnimalForSale(uint256 animalNumber) external view returns (bool) {
        return _isForSale[animalNumber];
    }

    function animalPrice(uint256 animalNumber) external view returns (uint256) {
        return _animalPrice[animalNumber];
    }

    function buyAnimal(uint256 animalNumber) external payable {
        address seller = ownerOf(animalNumber);
        require(_isForSale[animalNumber], "Animal is not for sale");
        require(seller != msg.sender, "Owner cannot buy own animal");

        uint256 price = _animalPrice[animalNumber];
        require(msg.value == price, "Incorrect purchase payment");

        delete _isForSale[animalNumber];
        delete _animalPrice[animalNumber];
        _transfer(seller, msg.sender, animalNumber);

        (bool success,) = payable(seller).call{value: msg.value}("");
        require(success, "Seller payment failed");
    }

    function declareAnimalWithParents(
        uint256 sex,
        uint256 legs,
        bool wings,
        string calldata name,
        uint256 parent1,
        uint256 parent2
    ) external returns (uint256 animalNumber) {
        ownerOf(parent1);
        ownerOf(parent2);

        _consumeReproductionAuthorization(parent1);
        if (parent2 != parent1) {
            _consumeReproductionAuthorization(parent2);
        }

        animalNumber = _createAnimal(msg.sender, sex, legs, wings, name);
        _parent1[animalNumber] = parent1;
        _parent2[animalNumber] = parent2;
    }

    function getParents(uint256 animalNumber) external view returns (uint256, uint256) {
        return (_parent1[animalNumber], _parent2[animalNumber]);
    }

    function canReproduce(uint256 animalNumber) external view returns (bool) {
        return _ownerOf(animalNumber) != address(0) && _reproductionPrice[animalNumber] > 0;
    }

    function reproductionPrice(uint256 animalNumber) external view returns (uint256) {
        return _reproductionPrice[animalNumber];
    }

    function offerForReproduction(uint256 animalNumber, uint256 priceOfReproduction) external returns (uint256) {
        require(ownerOf(animalNumber) == msg.sender, "Caller does not own animal");
        require(priceOfReproduction > 0, "Price must be greater than zero");

        _reproductionPrice[animalNumber] = priceOfReproduction;
        return animalNumber;
    }

    function authorizedBreederToReproduce(uint256 animalNumber) external view returns (address) {
        return _authorizedBreederToReproduce[animalNumber];
    }

    function payForReproduction(uint256 animalNumber) external payable {
        require(_reproductionPrice[animalNumber] > 0, "Animal is not available for reproduction");
        require(_authorizedBreederToReproduce[animalNumber] == address(0), "Reproduction already authorized");

        uint256 price = _reproductionPrice[animalNumber];
        require(msg.value == price, "Incorrect reproduction payment");

        _authorizedBreederToReproduce[animalNumber] = msg.sender;
        address owner = ownerOf(animalNumber);
        (bool success,) = payable(owner).call{value: msg.value}("");
        require(success, "Owner payment failed");
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function _createAnimal(address owner, uint256 sex, uint256 legs, bool wings, string calldata name)
        private
        returns (uint256 animalNumber)
    {
        animalNumber = _nextAnimalNumber++;
        _animals[animalNumber] = Animal(name, wings, legs, sex);
        _mint(owner, animalNumber);
    }

    function _consumeReproductionAuthorization(uint256 parent) private {
        if (_reproductionPrice[parent] > 0 && ownerOf(parent) != msg.sender) {
            require(_authorizedBreederToReproduce[parent] == msg.sender, "Reproduction is not authorized");
            delete _authorizedBreederToReproduce[parent];
            delete _reproductionPrice[parent];
        }
    }
}
