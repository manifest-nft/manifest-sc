pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Manifest is Ownable {
    mapping(address => mapping(address => bool)) public hasRedeemed;

    event manifestNFT(address sender, address NFTContractAddress);

    address payable multisigAddress;

    constructor(address payable multisig) {
        multisigAddress = multisig;
    }

    // only call from our UI, don't call the method from Polygonscan, you won't get merch nor a refund. Yours truly, the ManifestArt team.
    // parameters: NFTContract - contract of the NFT to manifest, source: Moralis NFT API (user.getUserNFTS)
    function submitManifest(address NFTContract) public payable {
        require(
            hasRedeemed[msg.sender][NFTContract] == false,
            "NFT has already been manifested."
        );

        hasRedeemed[msg.sender][NFTContract] = true;
        emit manifestNFT(msg.sender, NFTContract);
    }

    // function that can be called by the deployer to send funds to multisig
    function _withdraw() public {
        (bool success, ) = multisigAddress.call{value: address(this).balance}(
            ""
        );
        require(success, "Transfer failed.");
    }
}
