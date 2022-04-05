// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;
import "./ERC20/BEP20.sol";
import "./ERC20/IBEP20.sol";
import "./ERC20/SafeBEP20.sol";
import "./access/Ownable.sol";
import "./ReentrancyGuard.sol";
import "./SafeMath.sol";

contract CroToken is BEP20, Ownable, ReentrancyGuard {

    using SafeBEP20 for IBEP20;
    using SafeMath for uint256;
    uint256 public maxTotalSupply;
    uint256 public immutable MAX_WALLET_BALANCE; 
    // airdrop 
    uint256 public constant AIRDROP_CAP = 5; // 15%
    uint256 private totalAirdropMinted;
    
    // private sale    
    uint256 public constant PIRVATE_CAP = 15; // 15%
    uint256 public constant PRIVATE_TGE_RELEASE = 15;
    uint256 public constant PRIVATE_TGE_CLIFF = 86400 * 30 * 3; //3 months
    uint256 public constant PRIVATE_VESTING_DURATION = 86400 * 30 * 15; //15 months
    uint256 public PRIVATE_CRO_PRICE = 10; // per fund
    uint256 private private_totalMinted;

    uint256 public private_startTime;
    uint256 public private_endTime;

    // address coldWallet;
    uint8 public private_stage;
    address[] private whitelist;
    mapping(address => uint256) private private_locks;
    mapping(address => uint256) private private_released;

    // team sale
    uint256 public constant TEAM_CAP = 15; // 15%
    uint256 public TEAM_FULL_LOCK = 86400 * 30 * 6; //6 months
    uint256 public TEAM_VESTING_DURATION = 86400 * 30 * 18; //18 months    
    
    uint256 public team_startTime;
    uint256 public team_endTime;

    uint8 public team_stage;

    address public constant TEAM_ADVISOR_ADDRESS =
        0xda9D2d8e320f4C05e41C0ACEb92B89F1c347BFeA;
    uint256 team_lock;
    uint256 team_released;

    uint256 public constant MARKET_CAP = 15;
    uint256 public MARKET_TGE_RELEASE = 15;
    uint256 public MARKET_VESTING_DURATION = 86400 * 30 * 24; // 24 months

    uint256 public market_startTime;
    uint256 public market_endTime;

    uint8 public market_stage;
    address public MARKETING_ADDRESS =
        0xda9D2d8e320f4C05e41C0ACEb92B89F1c347BFeA;
    uint256 market_lock;
    uint256 market_released;
    
    uint256 public LIQUIDITY_CAP = 15;
    uint256 public LIQUIDITY_TGE_RELEASE = 15;
    uint256 public LIQUIDITY_VESTING_DURATION = 86400 * 30 * 12; // 12 months

    uint256 public liquidity_startTime;
    uint256 public liquidity_endTime;

    uint8 public liquidity_stage;
    address public  LIQUIDITY_ADDRESS =
        0xda9D2d8e320f4C05e41C0ACEb92B89F1c347BFeA;
    uint256 private liquidity_lock;
    uint256 private liquidity_released;

    //public sale
    uint256 constant PUBLIC_CAP = 35;
    uint256 totalPublicMinted;
    bool public  publicSale_stage;    

    uint256 public public_price;

    event PrivateClaim(address indexed account, uint256 amount, uint256 time);
    event TeamClaim(address indexed account, uint256 amount, uint256 time);
    event MarketClaim(address indexed account, uint256 amount, uint256 time);
    event LiquidityClaim(address indexed account, uint256 amount, uint256 time);

    constructor() BEP20("CroToken", "CROT") {  

        private_stage = 0;            
        maxTotalSupply = 1000000 * (10 ** decimals());
        MAX_WALLET_BALANCE = maxTotalSupply.div(100);
        team_lock = maxTotalSupply.mul(TEAM_CAP).div(100);
        market_lock = maxTotalSupply.mul(MARKET_CAP).mul(MARKET_TGE_RELEASE).div(10000);
        liquidity_lock = maxTotalSupply.mul(LIQUIDITY_CAP).mul(LIQUIDITY_TGE_RELEASE).div(10000);

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

    // team sale

    function setTeamTgeTime(uint256 _tge) external onlyOwner {
        require(team_stage == 0, "Can't setup tge");
        team_startTime = _tge + TEAM_FULL_LOCK;
        team_endTime = team_startTime + TEAM_VESTING_DURATION;

        team_stage = 1;
    }

    function teamClaim() external nonReentrant() {
        require(team_stage == 1, "Cannot Claim now");
        require(block.timestamp > team_startTime, "ERROR: still Locked");
        require(_msgSender() == TEAM_ADVISOR_ADDRESS, "Invalid Address");
        require(team_lock > team_released, "No claimable");

        uint256 amount = teamCanUnlockAmount();
        require(amount > 0, "Nothing to Claim");
        team_released += amount;        
        _mint(_msgSender(), amount);
    }

    function teamCanUnlockAmount() public view returns (uint256) {

        if (block.timestamp < team_startTime) {
            return 0;
        } else if (block.timestamp >= team_endTime) {
            return team_lock - team_released;
        } else {
            uint256 releasedTime = releasedTimes(team_startTime, team_endTime);
            uint256 totalVestingTime = team_endTime - team_startTime;
            return ((team_lock * releasedTime) / totalVestingTime) - team_released;
        }
    }
    
    function teamInfo() external view returns (uint8, uint256, uint256, uint256, uint256, uint256) {
        if(team_stage == 0) return (team_stage, team_startTime, team_endTime, team_lock, team_released, 0);
        return (team_stage, team_startTime, team_endTime, team_lock, team_released, teamCanUnlockAmount());
    }

    // marketing sale 

    function marketSetTgeTime(uint256 _tge) external onlyOwner {
        require(market_stage == 0, "Cannot setup tge");
        market_startTime = _tge;
        market_endTime = _tge + MARKET_VESTING_DURATION;

        market_stage = 1;

        //transfer 15% for MARKETING_ADDRESS
        uint256 croUnlockAtTge = market_lock.mul(MARKET_TGE_RELEASE).div(100);    
        market_lock -= croUnlockAtTge;
        transfer(MARKETING_ADDRESS, croUnlockAtTge);
    }

    function marketClaim() external nonReentrant {
        require(market_stage == 1, "Can not claim now");
        require(block.timestamp > market_startTime, "Still locked" );
        require(_msgSender() == MARKETING_ADDRESS, "Invalid Address");
        require(market_lock > market_released, "no locked");

        uint256 amount = marketCanUnlockAmount();
        require(amount > 0, "Nothing to Claim");
        
        market_released += amount;
        transfer(_msgSender(), amount);
        
        emit MarketClaim(_msgSender(), amount, block.timestamp);
    }

    function marketCanUnlockAmount() public view returns (uint256) {
        if (block.timestamp < market_startTime) {
            return 0;
        } else if (block.timestamp >= market_endTime) {
            return market_lock - market_released;
        } else {
            uint256 releasedTime = releasedTimes(market_startTime, market_endTime);
            uint256 totalVestingTime = market_endTime - market_startTime;
            return market_lock.mul(releasedTime).div(totalVestingTime) - market_released;
        }
    }   

    function marketInfo() external view returns (uint8, uint256, uint256, uint256, uint256, uint256) {
        if(market_stage == 0) return (market_stage, market_startTime, market_endTime, market_lock, market_released, 0);
        return (market_stage, market_startTime, market_endTime, market_lock, market_released, marketCanUnlockAmount());
    }

    function liquiditySetTgeTime(uint256 _tge) external onlyOwner {
        require(liquidity_stage == 0, "Cannot setup tge");
        liquidity_startTime = _tge;
        liquidity_endTime = _tge + LIQUIDITY_VESTING_DURATION;

        liquidity_stage = 1;

        //transfer 15% for liquidityING_ADDRESS
        uint256 croUnlockAtTge = liquidity_lock.mul(LIQUIDITY_TGE_RELEASE).div(100);    
        liquidity_lock -= croUnlockAtTge;
        transfer(LIQUIDITY_ADDRESS, croUnlockAtTge);
    }

    function liquidityClaim() external nonReentrant {
        require(liquidity_stage == 1, "Can not claim now");
        require(block.timestamp > liquidity_startTime, "Still locked" );
        require(_msgSender() == LIQUIDITY_ADDRESS, "Invalid Address");
        require(liquidity_lock > liquidity_released, "no locked");

        uint256 amount = liquidityCanUnlockAmount();
        require(amount > 0, "Nothing to Claim");
        
        liquidity_released += amount;
        transfer(_msgSender(), amount);
        
        emit LiquidityClaim(_msgSender(), amount, block.timestamp);
    }

    function liquidityCanUnlockAmount() public view returns (uint256) {
        if (block.timestamp < liquidity_startTime) {
            return 0;
        } else if (block.timestamp >= liquidity_endTime) {
            return liquidity_lock - liquidity_released;
        } else {
            uint256 releasedTime = releasedTimes(liquidity_startTime, liquidity_endTime);
            uint256 totalVestingTime = liquidity_endTime - liquidity_startTime;
            return liquidity_lock.mul(releasedTime).div(totalVestingTime) - liquidity_released;
        }
    }

    function liquidityInfo() external view returns (uint8, uint256, uint256, uint256, uint256, uint256) {
        if(liquidity_stage == 0) return (liquidity_stage, liquidity_startTime, liquidity_endTime, liquidity_lock, liquidity_released, 0);
        return (liquidity_stage, liquidity_startTime, liquidity_endTime, liquidity_lock, liquidity_released, liquidityCanUnlockAmount());
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
    

    /* ========== EMERGENCY ========== */
    /*
    Users make mistake by transfering usdt/busd ... to contract address. 
    This function allows contract owner to withdraw those tokens and send back to users.
    */
    function rescueStuckErc20(address _token) external onlyOwner {
        uint256 _amount = IBEP20(_token).balanceOf(address(this));
        IBEP20(_token).safeTransfer(owner(), _amount);
    }
}
