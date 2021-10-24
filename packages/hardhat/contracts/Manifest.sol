pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./ManifestNFT.sol";
import "./utils/IntString.sol";

contract Manifest is Ownable, IERC721Receiver {
    event manifestNFT(
        address sender,
        address NFTContract,
        uint256 tokenId,
        uint256 lastManifestId
    );
    event mintedManifestNFT(address minter, string tokenURI);
    event burnedManifestNFT(address burner, uint256 tokenId);

    address payable multisigAddress;

    string constant baseURI =
        "https://manifest-manifest.vercel.app/api/metadata/";

    mapping(address => mapping(address => mapping(uint256 => bool)))
        public hasRedeemed;

    ManifestNFT collection;
    address collectionAddress;

    constructor(address payable multisig, address manifestedNFTContract) {
        multisigAddress = multisig;
        collection = ManifestNFT(manifestedNFTContract);
        collectionAddress = manifestedNFTContract;
    }

    // only call from our UI, don't call the method from Polygonscan, you won't get merch nor a refund. Yours truly, the ManifestArt team.
    // parameters: NFTContract - contract of the NFT to manifest, source: Moralis NFT API (user.getUserNFTS)
    function submitManifest721(address NFTContract, uint256 _tokenId)
        public
        payable
    {
        require(
            IERC721(NFTContract).ownerOf(_tokenId) == msg.sender,
            "You're not the owner of this NFT"
        );
        require(
            hasRedeemed[msg.sender][NFTContract][_tokenId] == false,
            "NFT has already been manifested."
        );
        hasRedeemed[msg.sender][NFTContract][_tokenId] = true;
        uint256 lastManifestId = collection.getCounter();
        string memory uintString = uint2str(_tokenId);
        string memory _tokenURI = string(
            abi.encodePacked(baseURI, collectionAddress, uintString)
        );

        _mint721(msg.sender, _tokenURI);
        emit manifestNFT(msg.sender, NFTContract, _tokenId, lastManifestId);
    }

    function _mint721(address _sender, string memory _tokenURI) internal {
        collection.mintItem(_sender, _tokenURI);
        emit mintedManifestNFT(_sender, _tokenURI);
    }

    // IERC721Burnable not burning
    // burn = transfer to smart contract which doesn't have NFT withdraw functionality
    function manifest(uint256 _tokenId) public {
        collection.setApprovalForAll(address(this), true);
        collection.safeTransferFrom(msg.sender, address(this), _tokenId);

        emit burnedManifestNFT(msg.sender, _tokenId);
    }

    // function that can be called by the deployer to send funds to multisig
    function _withdraw() public {
        (bool success, ) = multisigAddress.call{value: address(this).balance}(
            ""
        );
        require(success, "Transfer failed.");
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
