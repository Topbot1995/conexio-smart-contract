// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;
import "./ERC20/BEP20.sol";
import "./access/Ownable.sol";
import "./ReentrancyGuard.sol";
import "./SafeMath.sol";


contract CroToken1 is BEP20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    // sale state

    struct SaleInfo {
        bool stage;
        address tge_address;
        uint256 tge_cap;
        uint256 tge_release;
        uint256 tge_lockTime;
        uint256 tge_vesting_duration;                
        uint256 tge_released;
        uint256 tge_startTime;        
        uint256 tge_endTime;
    }

    SaleInfo[] public saleInfos;

    uint256 public maxTotalSupply;
    uint256 public immutable MAX_WALLET_BALANCE; 
    
    // airdrop 
    uint256 public constant AIRDROP_CAP = 5; // 15%
    uint256 private totalAirdropMinted;

    //public sale
    uint256 constant PUBLIC_CAP = 35;
    uint256 totalPublicMinted;
    bool public  publicSale_stage;    
    uint256 public public_price;
    
    // private sale    
    uint256 public constant PIRVATE_CAP = 15; // 15%
    uint256 public constant PRIVATE_TGE_RELEASE = 15;
    uint256 public constant PRIVATE_TGE_CLIFF = 86400 * 30 * 3; //3 months
    uint256 public constant PRIVATE_VESTING_DURATION = 86400 * 30 * 15; //15 months
    uint256 public PRIVATE_CRO_PRICE = 10; // per fund
    uint256 private private_totalMinted;

    uint256 public private_startTime;
    uint256 public private_endTime;  
    
    uint8 public private_stage;
    address[] private whitelist;
    mapping(address => uint256) private private_locks;
    mapping(address => uint256) private private_released;

    //event
    event PrivateClaim(address indexed account, uint256 amount, uint256 time);
    event TeamClaim(address indexed account, uint256 amount, uint256 time);
    event MarketClaim(address indexed account, uint256 amount, uint256 time);
    event LiquidityClaim(address indexed account, uint256 amount, uint256 time);

    constructor() BEP20("CroToken", "CROT") {
        maxTotalSupply = 1000000 * (10 ** decimals());
        MAX_WALLET_BALANCE = maxTotalSupply.div(100);
        public_price = 20;
        init();
    }

    function init() private {

        SaleInfo memory _teamSale = SaleInfo({
            stage : false,
            tge_address : 0xda9D2d8e320f4C05e41C0ACEb92B89F1c347BFeA,
            tge_cap : maxTotalSupply.mul(15),
            tge_release : maxTotalSupply.mul(15),
            tge_vesting_duration : 86400 * 30 * 12,
            tge_lockTime : 86400 * 30 * 6,
            tge_released : 0,
            tge_startTime : 0,
            tge_endTime : 0
        });
        SaleInfo memory _marketSale = SaleInfo({
            stage : false,
            tge_address : 0xda9D2d8e320f4C05e41C0ACEb92B89F1c347BFeA,
            tge_cap : maxTotalSupply.mul(15),
            tge_release : maxTotalSupply.mul(15),
            tge_vesting_duration : 86400 * 30 * 12,
            tge_lockTime : 86400 * 30 * 6,
            tge_released : 0,
            tge_startTime : 0,
            tge_endTime : 0
        });
        SaleInfo memory _liquiditySale = SaleInfo({
            stage : false,
            tge_address : 0xda9D2d8e320f4C05e41C0ACEb92B89F1c347BFeA,
            tge_cap : maxTotalSupply.mul(15),
            tge_release : maxTotalSupply.mul(15),
            tge_vesting_duration : 86400 * 30 * 12,
            tge_lockTime : 86400 * 30 * 6,
            tge_released : 0,
            tge_startTime : 0,
            tge_endTime : 0
        });

        saleInfos.push(_teamSale);
        saleInfos.push(_marketSale);
        saleInfos.push(_liquiditySale);
    }

    modifier canPrivateClaim() {
        require(private_stage == 1, "Can not claim now");
        _;
    }

    modifier canPrivateSetup() {
        require(private_stage == 0, "Can not setup now");
        _;
    }    

    function setPrivateTgeTime(uint256 _tge) external canPrivateSetup onlyOwner {
        private_startTime = _tge + PRIVATE_TGE_CLIFF;
        private_endTime = private_startTime + PRIVATE_VESTING_DURATION;

        private_stage = 1;

        //transfer 15% for whilelists;
        for (uint256 i = 0; i < whitelist.length; i++) {            
            uint256 croAmount = (private_locks[whitelist[i]] * PRIVATE_TGE_RELEASE) / 100;
            //private_locks[whitelist[i]] -= croAmount;
            private_released[whitelist[i]] += croAmount;
            _mint(whitelist[i], croAmount);            
        }
    }

    function setWhiteList(address[] calldata _users, uint256[] calldata funds)
        external
        canPrivateSetup
        onlyOwner
    {
        require(_users.length == funds.length,"Invalid input");        
        uint256 _totalfund = 0;
        for(uint256 i = 0; i < funds.length; i++) {
            _totalfund += funds[i];
        }
        
        if(_totalfund.div(PRIVATE_CRO_PRICE).add(private_totalMinted) > maxTotalSupply.mul(PIRVATE_CAP).div(100)) {
            revert("ERROR: Over flow");
        }        

        for(uint256 i = 0; i < _users.length; i++) {    
               
            uint256 _croAmount = funds[i].div(PRIVATE_CRO_PRICE);
            if (balanceOf(_users[i])+_croAmount > MAX_WALLET_BALANCE) {
                revert("ERROR: Over Balanced");
            }
            private_locks[_users[i]] += _croAmount;
            private_totalMinted += _croAmount;
            whitelist.push(_users[i]);
        }
    }

    function isWhitelisted(address _address) internal view returns (bool) {
        for(uint256 i = 0; i < whitelist.length; i++) {
            if (_address == whitelist[i]) {
                return true;
            }
        }
        return false;
    }

    function privateClaim() external canPrivateClaim nonReentrant {
        require(block.timestamp > private_startTime, "still locked");
        require(private_locks[_msgSender()] > 0, "No locked");   
        require(isWhitelisted(_msgSender()), "ERROR: is not WhiteListed");     

        uint256 amount = privateCanUnlockAmount(_msgSender());
        require(amount > 0, "Nothing to claim");
        require(amount.add(balanceOf(_msgSender())) <= MAX_WALLET_BALANCE, "ERROR: OverBalanced!!!");
        private_released[_msgSender()] += amount;
        //private_locks[_msgSender()] -= amount;
        _mint(_msgSender(), amount);

        emit PrivateClaim(_msgSender(), amount, block.timestamp);
    }

    function privateCanUnlockAmount(address _account) internal view returns (uint256) {
        if(block.timestamp < private_startTime) {
            return 0;
        } else if(block.timestamp >= private_endTime) {
            return private_locks[_account];
        } else {
            uint256 releasedTime = releasedTimes(private_startTime, private_endTime);
            uint256 totalVestingTime = private_endTime - private_startTime;
            return 
                (((private_locks[_account]) * releasedTime) / totalVestingTime) - private_released[_account];
        }
    }

    function releasedTimes(uint256 _startTime , uint256 _endTime) public view returns (uint256) {
        uint256 targetNow = (block.timestamp >= _endTime) ? _endTime : block.timestamp;
        uint256 _releasedTime = targetNow - _startTime;
        return _releasedTime;
    }

    function privateInfo() external view returns (uint8, uint256, uint256, uint256) {
        return (private_stage, private_startTime, private_endTime, private_totalMinted);
    }

    function setprivatePrice(uint256 _amount) external {
        require(_amount > 0, "Invalid Price");
        PRIVATE_CRO_PRICE = _amount;
    }

    //airdrop function 
    
    function airdrop(address _address, uint256 _amount) external onlyOwner {
        require(_address != address(0), "Invalid Address");
        require(_amount > 0, "Invalid Address");
        require(totalAirdropMinted+_amount < AIRDROP_CAP.mul(maxTotalSupply).div(100), "Invalid Address");
        require(balanceOf(_address).add(_amount) <= MAX_WALLET_BALANCE, "ERROR: OverBalance");
        _mint(_address, _amount);
        totalAirdropMinted += _amount;
    }

    function setTgeTime(uint256 _tge, uint8 _index) external onlyOwner {
        SaleInfo memory _saleInfo = saleInfos[_index];
        require(_saleInfo.stage == false, "Can't setup tge");
        _saleInfo.tge_startTime = _tge + _saleInfo.tge_lockTime;
        _saleInfo.tge_endTime = _saleInfo.tge_startTime + _saleInfo.tge_vesting_duration;



        _saleInfo.stage = true;

        if (_saleInfo.tge_release != 0 ) {
            uint256 croUnlockAtTge = _saleInfo.tge_cap.mul(_saleInfo.tge_release).div(100);    
            _saleInfo.tge_released += croUnlockAtTge;
            transfer(_saleInfo.tge_address, croUnlockAtTge);
        }        

        saleInfos[_index] = _saleInfo;                 
    }

    function claim(uint8 _index) external nonReentrant {
        SaleInfo memory _saleInfo = saleInfos[_index];
        require(_saleInfo.stage == true, "Cannot Claim now");
        require(_msgSender() == _saleInfo.tge_address, "Invalid Address");
        require(_saleInfo.tge_cap > _saleInfo.tge_released, "No claimable");

        uint256 amount = canUnlockAmount(_index);
        require(amount > 0, "Nothing to Claim");
        _saleInfo.tge_released += amount;
        saleInfos[_index] = _saleInfo;    
        _mint(_msgSender(), amount);
    }

    function canUnlockAmount(uint8 _index) internal view returns (uint256) {
        SaleInfo storage _saleInfo = saleInfos[_index];
        if (block.timestamp < _saleInfo.tge_startTime) {
            return 0;
        } else if (block.timestamp >= _saleInfo.tge_endTime) {
            return _saleInfo.tge_cap - _saleInfo.tge_released;
        } else {
            uint256 releasedTime = releasedTimes(_saleInfo.tge_endTime, _saleInfo.tge_startTime);
            uint256 totalVestingTime = _saleInfo.tge_endTime - _saleInfo.tge_startTime;
            return ((_saleInfo.tge_cap * releasedTime) / totalVestingTime) - _saleInfo.tge_released;
        }
    }

    function saleInfo(uint8 _index) external view returns (bool, uint256, uint256, uint256, uint256){
        SaleInfo storage _saleInfo = saleInfos[_index];
        if(_saleInfo.stage == false) return (_saleInfo.stage, _saleInfo.tge_startTime, _saleInfo.tge_endTime, _saleInfo.tge_cap, 0);
        return (_saleInfo.stage, _saleInfo.tge_startTime, _saleInfo.tge_endTime, _saleInfo.tge_cap, _saleInfo.tge_released);
    }
    
    function setPublicStage() external onlyOwner returns (bool) {
        bool stage = publicSale_stage;
        publicSale_stage = !stage;
        return true;
    }
    
    function publicClaim(uint256 _amount) external payable {
        require(_amount > 0, "ERROR: Invalid Amount");        
        require(publicSale_stage == true, "ERROR: public sale locked");
        require(_amount.add(balanceOf(_msgSender())) + totalPublicMinted <= maxTotalSupply.mul(PUBLIC_CAP), "ERROR: Public sale OverFlow");
        require(balanceOf(_msgSender()) + _amount <= MAX_WALLET_BALANCE, "ERROR:OverBalance");     
        require(msg.value == public_price.mul(_amount), "ERROR: Invalid Fund");
        _mint(_msgSender(), _amount);
    }

    function publicInfo() external view returns (bool, uint256) {
        if(publicSale_stage == true) return (publicSale_stage, 0);
        return (publicSale_stage, totalPublicMinted);
    }

    function burn(uint256 _amount) external onlyOwner returns (bool) {
        require(balanceOf(owner()) >= _amount, "ERROR: Insufficient balance");
        _burn(owner(), _amount);
    }

    function withdraw(address payable to, uint256 value)
        external
        onlyOwner
    {
        require(
            value <= address(this).balance,
            "withdrawAdmin: withdraw amount less than balance of this smart contract"
        );
        to.transfer(value);
    }
}