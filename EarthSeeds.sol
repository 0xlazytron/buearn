// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract EarthSeeds is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable, Pausable, ReentrancyGuard {
    using Strings for uint256;

    uint256 public constant MAX_SUPPLY = 4999;
    uint256 public constant PRICE_PER_TOKEN = 0.005 ether;
    uint256 public constant MAX_MINT_AMOUNT = 5;
    bool public saleIsActive = true;

    uint256 private _nextTokenId;

    string internal _currentURI =
        "https://ipfs.filebase.io/ipfs/QmVevyZMH2noEXMKuGnHS6bwAP3f9ktYRY9WPfagWyQHF6/";

    event SaleStateChanged(bool newState);
    event TokenMinted(address to, uint256 tokenId);

    constructor() ERC721("EarthSeeds", "ETS") Ownable(msg.sender) {}

    function withdraw(address adr) external onlyOwner nonReentrant {
        payable(adr).transfer(address(this).balance);
    }

    modifier applyLimit() {
        require(
            balanceOf(msg.sender) < MAX_MINT_AMOUNT,
            "Only one mint allowed per wallet"
        );
        _;
    }

    modifier saleActive() {
        require(saleIsActive, "Sale is not active");
        _;
    }

    function setSaleState(bool newState) public onlyOwner {
        saleIsActive = newState;
        emit SaleStateChanged(newState);
    }

    function safeMint(address to, string memory uri) public onlyOwner whenNotPaused {
        require(_nextTokenId < MAX_SUPPLY, "Max supply reached");
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        emit TokenMinted(to, tokenId);
    }

    function mint() public payable saleActive applyLimit whenNotPaused {
        require(msg.value >= PRICE_PER_TOKEN, "Not enough Balance To Mint");
        require(_nextTokenId < MAX_SUPPLY, "Max supply reached");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
        emit TokenMinted(msg.sender, tokenId);
    }

    // The following functions are overrides required by Solidity.
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function _baseURI() internal view override returns (string memory) {
        return _currentURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        require(tokenId < MAX_SUPPLY, "Token Doest not exists!");
        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length >= 0
                ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json"))
                : "";
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
