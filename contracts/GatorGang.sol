// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title GatorGang
 * @author EG
 * @dev GatorGang NFT Token Contract
 */

contract GatorGang is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;

    // token counter
    Counters.Counter private _tokenIds;

    // NFT Name
    string public constant TOKEN_NAME = "Gator Gang";
    // NFT Symbol
    string public constant TOKEN_SYMBOL = "GG";

    // total NFT number
    uint256 public maxTotalSupply;

    // total mint nft number in presale
    uint256 public totalMintNumberPresale;

    // total mint nft number in public sale
    uint256 public totalMintNumberPublicSale;

    // total mint nft number in airdrop
    uint256 public totalMintNumberAirDrop;

    // presale max counter
    uint256 public presaleMaxCounter;
    // public sale max number
    uint256 public publicSaleMaxCounter;

    // presale price
    uint256 public presalePrice;
    // public sale price
    uint256 public publicSalePrice;

    // Presale requires presaleStatus true
    bool public presaleStatus;
    /**
     *  Public Sale requries publicSaleStatus true
     *  Public Sale requries this variable true
     */
    bool public publicSaleStatus;

    // NFT toke `baseURI`
    string public baseURI;

    // mapping address to flag of White Address
    mapping(address => bool) private _whiteList;

    // mapping nft number to flag of sold
    mapping(uint256 => bool) private _nftSaledList;

    // totla current in this contract
    uint256 private _totalCurrency;

    /**
     * indicator of `_nftSaledList`
     */
    uint256 private _indicatorNFT;

    /**
     *  Emitted when `_tokenBaseURI` updated
     */
    event BaseURI(string bseURI);

    /**
     *  Emitted when `publicSaleStatus` updated
     */
    event PublicSaleStatus(bool status);

    /**
     *  Emitted when `presaleStatus` updated
     */
    event PresaleStatus(bool status);

    /**
     *  Emitted when `presaleMaxCounter` updated
     */
    event PresaleMaxCounter(uint256 counter);

    /**
     *  Emitted when `publicSaleMaxCounter` updated
     */
    event PublicSaleMaxCounter(uint256 counter);

    /**
     *  Emitted when `presalePrice` updated
     */
    event PresalePrice(uint256 price);

    /**
     *  Emitted when `publicSalePrice` updated
     */
    event PublicSalePrice(uint256 price);

    /**
     *  Emitted when client added to `_whiteList`
     */
    event ClientAddedToWhiteList(address[] clients);

    /**
     *  Emitted when client removed to `_whiteList`
     */
    event ClientRemovedFromWhiteList(address[] clients);

    /**
     *  Emitted when token sold in presale
     */
    event Presale(address indexed client, uint256 amount, uint256 price);

    /**
     *  Emitted when token sold in public sale
     */
    event PublicSale(address indexed client, uint256 amount, uint256 price);

    /**
     *  Emitted when Airdrop
     */
    event Airdrop(address indexed client, uint256[] tokensIds);

    /**
     *  Emitted when Withdray
     */
    event Withdraw(address indexed owner, address indexed to, uint256 amount);

    // https://eg-nft-api-dev.herokuapp.com/api/v1/nft/
    constructor(string memory BASEURI) ERC721(TOKEN_NAME, TOKEN_SYMBOL) {
        baseURI = BASEURI;
        maxTotalSupply = 8888;
        totalMintNumberPresale = 0;
        totalMintNumberPublicSale = 0;
        totalMintNumberAirDrop = 0;
        _totalCurrency = 0;
        presaleMaxCounter = 5;
        publicSaleMaxCounter = 20;
        presalePrice = 6 * 1e16; // 0.06
        publicSalePrice = 16 * 1e16; // 0.16
        _indicatorNFT = 0;

        publicSaleStatus = true;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    /**
     *  set `baseURI`
     */
    function setBaseURI(string calldata uri) external onlyOwner {
        baseURI = uri;
        emit BaseURI(uri);
    }

    /**
     *  set `presaleMaxCounter`
     */
    function setPresaleMaxCounter(uint256 counter) external onlyOwner {
        require(counter > 0, "setPresaleMaxCounter: amount cannot be zero");
        if (presaleMaxCounter != counter) {
            presaleMaxCounter = counter;
        }
        emit PresaleMaxCounter(counter);
    }

    /**
     *  set `publicSaleMaxCounter`
     */
    function setPublicSaleMaxCounter(uint256 counter) external onlyOwner {
        require(
            counter > 0,
            "setPublicSaleMaxCounter: amount cannot be zero"
        );
        if (publicSaleMaxCounter != counter) {
            publicSaleMaxCounter = counter;
        }
        emit PublicSaleMaxCounter(counter);
    }

    /**
     *  set `presalePrice`
     */
    function setPresalePrice(uint256 price) external onlyOwner {
        require(price > 0, "setPresalePrice: amount cannot be zero");
        if(presalePrice != price){
            presalePrice = price;
        }
        emit PresalePrice(price);
    }

    /**
     *  set `publicSalePrice`
     */
    function setPublicSalePrice(uint256 price) external onlyOwner {
        require(price > 0, "setPublicSalePrice: amount cannot be zero");
        if (publicSalePrice != price) {
            publicSalePrice = price;
        }
        emit PublicSalePrice(price);
    }

    /**
     *  set `publicSaleStatus`
     */
    function setPublicSaleStatus(bool status) external onlyOwner {
        if (publicSaleStatus != status) {
            publicSaleStatus = status;
        }
        emit PublicSaleStatus(status);
    }

    /**
     *  set `presaleStatus`
     */
    function setPresaleStatus(bool status) external onlyOwner {
        if (presaleStatus != status) {
            presaleStatus = status;
        }
        emit PresaleStatus(status);
    }

    /**
     *  @param clients list array for white list
     *  insert clients to WhiteList
     *  set true for `_whiteList[clients[i]]`
     */
    function addClientToWhiteList(address[] calldata clients)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < clients.length; i++) {
            require(
                clients[i] != address(0),
                "addClientToWhiteList: Client not become zero address for Whitelist."
            );
            if (_whiteList[clients[i]] != true) {
                _whiteList[clients[i]] = true;
            }
        }
        emit ClientAddedToWhiteList(clients);
    }

    /**
     *  @param clients is amount for insertion to white list
     *  remove clients from WhiteList
     *  set false for `_whiteList[clients[i]]`
     */
    function removeClientFromWhiteList(address[] calldata clients)
        external
        onlyOwner
    {
        for (uint256 i; i < clients.length; i++) {
            require(
                clients[i] != address(0),
                "removeClientFromWhiteList: Client not become zero address for Whitelist Removing."
            );
            if (_whiteList[clients[i]] == true) {
                _whiteList[clients[i]] = false;
            }
        }
        emit ClientRemovedFromWhiteList(clients);
    }

    function presaleMint(uint256 amount) internal {
        require(
            _whiteList[msg.sender] == true,
            "presaleMint: Not in whitelist"
        );
        require(
            presalePrice * amount == msg.value,
            "presaleMint: Not fit price for presale"
        );
        require(
            amount <= presaleMaxCounter,
            "presaleMint: Not fit amount, less than max presale number."
        );
        for (uint256 i = 0; i < amount; i++) {
            while (_nftSaledList[_tokenIds.current()] == true) {
                _tokenIds.increment();
            }
            _safeMint(msg.sender, _tokenIds.current());
            _nftSaledList[_tokenIds.current()] = true;
            _tokenIds.increment();
        }
        _totalCurrency += presalePrice * amount;
        totalMintNumberPresale += amount;
        emit Presale(msg.sender, amount, msg.value * amount);
    }

    function publicSaleMint(uint256 amount) internal {
        require(
            publicSaleStatus == true,
            "publicSaleMint: Public sale status off"
        );
        require(
            publicSalePrice * amount == msg.value,
            "publicSaleMint: Not fit price for public sale"
        );
        require(
            amount <= publicSaleMaxCounter,
            "publicSaleMint: Not fit amount, less thant max presale number."
        );
        for (uint256 i = 0; i < amount; i++) {
            while (_nftSaledList[_tokenIds.current()] == true) {
                _tokenIds.increment();
            }
            _safeMint(msg.sender, _tokenIds.current());
            _nftSaledList[_tokenIds.current()] = true;
            _tokenIds.increment();
        }
        _totalCurrency += publicSalePrice * amount;
        totalMintNumberPublicSale += amount;
        emit PublicSale(msg.sender, amount, amount * msg.value);
    }

    /**
     *  @param amount is amount for minting
     *  access by admin
     */
    function clientMint(uint256 amount) external payable {
        require(
            (_tokenIds.current() + amount) < maxTotalSupply,
            "clientMint: Rest token not fit your Amount"
        );

        if (presaleStatus == true) {
            presaleMint(amount);
        } else {
            publicSaleMint(amount);
        }
    }

    /**
     *  @param client airdrop address
     *  @param tokenIdArray token number address for airdrop
     * access by admin
     */
    function adminAirdrop(address client, uint256[] calldata tokenIdArray)
        external
        payable
        onlyOwner
    {
        require(
            (_tokenIds.current() + tokenIdArray.length) <= maxTotalSupply,
            "adminAirdrop: Rest token not fit your Amount"
        );
        for (uint256 i = 0; i < tokenIdArray.length; i++) {
            require(
                _nftSaledList[tokenIdArray[i]] == false,
                "adminAirdrop: Token alreay sold"
            );
        }
        for (uint256 i = 0; i < tokenIdArray.length; i++) {
            // _tokenIds.increment();
            _safeMint(client, tokenIdArray[i]);
            _nftSaledList[i] = true;
        }
        totalMintNumberAirDrop += tokenIdArray.length;
        emit Airdrop(client, tokenIdArray);
    }

    /**
     * get total currency number in this smart contract address
     * access admin
     */
    function getTotalCurrency() public view onlyOwner returns (uint256) {
        return _totalCurrency;
    }

    /**
     * get total mint number
     */
    function getTotalMintNumber() public view returns (uint256) {
        return
            totalMintNumberAirDrop +
            totalMintNumberPresale +
            totalMintNumberPublicSale;
    }

    /**
     * @param to money receiver address
     * @param value transer amount
     * access admin
     */
    function withdrawAdmin(address payable to, uint256 value)
        external
        onlyOwner
    {
        require(
            value <= address(this).balance,
            "withdrawAdmin: withdraw amount less than balance of this smart contract"
        );
        to.transfer(value);
        emit Withdraw(owner(), to, value);
    }
}
