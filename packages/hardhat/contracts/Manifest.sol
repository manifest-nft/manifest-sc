pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./ManifestNFT.sol";

contract Manifest is Ownable {
    mapping(address => mapping(address => bool)) public hasRedeemed;

    event manifestNFT(address sender, address NFTContractAddress);

    address payable multisigAddress;

    ManifestNFT collection;

    constructor(address payable multisig, address manifestedNFTContract) {
        multisigAddress = multisig;
        collection = ManifestNFT(manifestedNFTContract);
    }

    // only call from our UI, don't call the method from Polygonscan, you won't get merch nor a refund. Yours truly, the ManifestArt team.
    // parameters: NFTContract - contract of the NFT to manifest, source: Moralis NFT API (user.getUserNFTS)
    function submitManifest721(
        address NFTContract,
        uint256 _tokenId,
        string memory _tokenURI
    ) public payable {
        require(
            IERC721(NFTContract).ownerOf(_tokenId) == msg.sender,
            "You're not the owner of this NFT"
        );
        require(
            hasRedeemed[msg.sender][NFTContract] == false,
            "NFT has already been manifested."
        );
        hasRedeemed[msg.sender][NFTContract] = true;

        _mint721(msg.sender, _tokenURI);
        emit manifestNFT(msg.sender, NFTContract);
    }

    function _mint721(address _sender, string memory _tokenURI) internal {
        collection.mintItem(_sender, _tokenURI);
    }

    // TODO
    function manifest(address NFTContractAddress) public {}

    // function that can be called by the deployer to send funds to multisig
    function _withdraw() public {
        (bool success, ) = multisigAddress.call{value: address(this).balance}(
            ""
        );
        require(success, "Transfer failed.");
    }
}
