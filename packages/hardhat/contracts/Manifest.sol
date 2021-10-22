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

    constructor() {
        // multisigAddress = multisig;
    }

    // parameters: NFTContract - contract of the NFT to manifest, source: Moralis NFT API (user.getUserNFTS)
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

    function _manifest() public onlyOwner {
        for (uint256 i = 0; i < ManifestList.length; i++) {
            address sender = ManifestList[i].sender;
            address NFTContract = ManifestList[i].NFTContract;
            hasRedeemed[sender][NFTContract] = true;
            emit manifestNFT(sender, NFTContract);
        }
    }

    // function that can be called by the deployer to send funds to multisig
    function _withdraw() public onlyOwner {
        multisigAddress.transfer(address(this).balance);
    }
}
