//SPDX-License-Identifier:MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NftMarketPlace is ERC721{
    struct TokenInfo {
        uint256 price;
        address owner;
        address creater;
        bool listed;
        string tokenURI;
    }

    mapping(uint256 => TokenInfo) public Listing;
    mapping(uint256 => address) private nftApproval;

    uint256 public tokenId = 0;

    event nftMinted(
        uint256 indexed tokenId,
        address indexed owner
  
    );
    event nftListed(uint256 indexed tokenId, uint256 price);
    event nftbought(uint256 indexed  tokenId,address indexed buyer,uint256 price);

    constructor() ERC721("nft","nft") {}

    function mintNFT(string memory _tokenURI) public {
        uint256 id=tokenId;
        Listing[id] = TokenInfo({
            price: 0,
            owner: msg.sender,
            creater: msg.sender,
            listed: false,
            tokenURI: _tokenURI
        });
        _mint(msg.sender, id);
       
        tokenId++;
        emit nftMinted(id, msg.sender);
    }

    function list(uint256 _tokenId, uint256 _price) public {
        require(_price > 0, "Price must be more than zero.");
        require(Listing[_tokenId].listed == false, "Nft already listed.");
        require(Listing[_tokenId].owner == msg.sender, "Only owner can list");

        Listing[_tokenId].price = _price;
        Listing[_tokenId].listed = true;

        approve(address(this), _tokenId);
 

        emit nftListed(_tokenId, _price);
    }

    function buy(uint256 _tokenId) public payable {
        require(_tokenId >= 0 && _tokenId <= tokenId, "Invalid NFT");
        require(Listing[_tokenId].listed, "NFT not listed yet");
        require(msg.value >= Listing[_tokenId].price, "Insufficient funds");

        address owner=Listing[_tokenId].owner;
        address creater=payable(Listing[_tokenId].creater);

        uint256 royalityToOwner = Listing[_tokenId].price*2/100;
        payable(creater).transfer(royalityToOwner);

        payable(owner).transfer(msg.value-royalityToOwner);

        transferFrom(owner, msg.sender, _tokenId);

        Listing[_tokenId].listed = false;
        emit nftbought(_tokenId,msg.sender,msg.value);
    }

    function tokenURI(uint256 _tokenId) public view override returns(string memory){
        string memory  tokenUri = Listing[_tokenId].tokenURI;
        return tokenUri;
    }
    
}
