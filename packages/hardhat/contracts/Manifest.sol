pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Manifest is Ownable {
    mapping(address => mapping(address => bool)) public hasRedeemed;

    event manifestSubmitted(address sender, address NFTContractAddress);
    event manifestNFT(address sender, address NFTContractAddress);

    struct ManifestSubmission {
        address sender;
        address NFTContract;
    }

    ManifestSubmission[] ManifestList;

    address payable multisigAddress;

    constructor(address payable multisig) {
        multisigAddress = multisig;
    }

    function submitManifest(address NFTContract) public payable {
        require(
            hasRedeemed[msg.sender][NFTContract] == false,
            "NFT has already been manifested."
        );
        ManifestSubmission memory currManifest = ManifestSubmission(
            msg.sender,
            NFTContract
        );
        // submitManifest will be called with
        ManifestList.push(currManifest);

        emit manifestSubmitted(msg.sender, NFTContract);
    }

    function _manifest(address NFTContractAddress) public onlyOwner {
        for (uint256 i = 0; i < ManifestList.length; i++) {}
        hasRedeemed[msg.sender][NFTContractAddress] = true;
        // backend listens for this event to send request to scalablePressQuote
        emit manifestNFT(msg.sender, NFTContractAddress);
    }

    // function that can be called by the deployer to send funds to multisig
    function _withdraw() public onlyOwner {
        multisigAddress.transfer(address(this).balance);
    }
}
