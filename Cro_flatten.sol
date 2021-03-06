// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity 0.8.6;

interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity 0.8.6;
interface IBEP20Metadata is IBEP20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

pragma solidity 0.8.6;
contract BEP20 is Context, IBEP20, IBEP20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "BEP20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "BEP20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "BEP20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

pragma solidity 0.8.6;
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity 0.8.6;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

pragma solidity 0.8.6;

 library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {

            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

pragma solidity 0.8.6;
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

    SaleInfo[] private saleInfos;

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

    //tax for first claim within 20s
    uint256 public constant ANTIBOT_TAX = 10;
    uint256 private TAX_APPLY_START;
    
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
    event Claim(address indexed account, uint256 amount, uint256 time);

    constructor() BEP20("CroToken", "CROT") {
        maxTotalSupply = 1000000 * (10 ** decimals());
        MAX_WALLET_BALANCE = maxTotalSupply.div(100);
        public_price = 20;
        init();
    }

    function init() private {

        SaleInfo memory _teamSale = SaleInfo({
            stage : false,
            tge_address : 0xc2e24CE1a1820AfEd0Dedf3856e08CDdEddD1b0a,
            tge_cap : maxTotalSupply.mul(15).div(100),
            tge_release : 15,
            tge_vesting_duration : 86400,//86400 * 30 * 12,
            tge_lockTime : 30,//86400 * 30 * 6,
            tge_released : 15,
            tge_startTime : 0,
            tge_endTime : 0
        });
        SaleInfo memory _marketSale = SaleInfo({
            stage : false,
            tge_address : 0x88f1c1EE1Fa2e25cE61aa8bD21C7ec4c03376f2B,
            tge_cap : maxTotalSupply.mul(15).div(100),
            tge_release : 15,
            tge_vesting_duration : 86400,//86400 * 30 * 12,
            tge_lockTime : 40,//86400 * 30 * 6,
            tge_released : 0,
            tge_startTime : 0,
            tge_endTime : 0
        });
        SaleInfo memory _liquiditySale = SaleInfo({
            stage : false,
            tge_address : 0x241CfB3a2fAe17b143e20958483225fC1C461A15,
            tge_cap : maxTotalSupply.mul(15).div(100),
            tge_release : 15,
            tge_vesting_duration : 86400,//86400 * 30 * 12,
            tge_lockTime : 50,//86400 * 30 * 6,
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

    function releasedTimes(uint256 _startTime , uint256 _endTime) internal view returns (uint256) {
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
        require(_amount > 0, "Invalid amount");
        require(totalAirdropMinted+_amount < AIRDROP_CAP.mul(maxTotalSupply).div(100), "Amount Overflow");
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
            _mint(_saleInfo.tge_address, croUnlockAtTge);
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

        emit Claim(_msgSender(), amount, block.timestamp);
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
        if (publicSale_stage) {
            TAX_APPLY_START = block.timestamp;
        }
        return true;
    }
    
    function publicClaim(uint256 _amount) external payable returns (bool) {
        require(_amount > 0, "ERROR: Invalid Amount");    
        require(publicSale_stage == true, "ERROR: public sale locked");
        require(_amount.add(balanceOf(_msgSender())) + totalPublicMinted <= maxTotalSupply.mul(PUBLIC_CAP), "ERROR: Public sale OverFlow");
        require(balanceOf(_msgSender()) + _amount <= MAX_WALLET_BALANCE, "ERROR:OverBalance");     
        require(msg.value == public_price.mul(_amount), "ERROR: Invalid Fund");
        
        // apply tax for the first claim within 20s        
        if (block.timestamp <= TAX_APPLY_START + 20) {
            uint256 netPercent = 100 - ANTIBOT_TAX;
            _mint(_msgSender(), _amount.mul(netPercent).div(100));    
            _mint(owner(), _amount.mul(ANTIBOT_TAX).div(100));   
            return true; 
        }
        _mint(_msgSender(), _amount);
        return true;
    }

    function publicInfo() external view returns (bool, uint256) {
        if(publicSale_stage == true) return (publicSale_stage, 0);
        return (publicSale_stage, totalPublicMinted);
    }

    function setPublicPrice(uint256 _price) external onlyOwner returns (bool) {
        require(_price > 0, "ERROR: Invalid Price");
        public_price = _price;
        return true;
    }

    function burn(uint256 _amount) external onlyOwner returns (bool) {
        require(balanceOf(owner()) >= _amount, "ERROR: Insufficient balance");
        _burn(owner(), _amount);
        return true;
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

