// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;
import "./ERC20/BEP20.sol";
import "./ERC20/IBEP20.sol";
import "./ERC20/SafeBEP20.sol";
import "./access/Ownable.sol";
import "./ReentrancyGuard.sol";

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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
    uint256 public TEAM_FULL_LOCK = 86400 * 30 * 6; //6 months
    uint256 public TEAM_VESTING_DURATION = 86400 * 30 * 18; //18 months
    
    uint256 public team_startTime;
    uint256 public team_endTime;

    uint8 public team_stage;

    address public constant TEAM_ADVISOR_ADDRESS =
        0xda9D2d8e320f4C05e41C0ACEb92B89F1c347BFeA;
    uint256 team_lock;
    uint256 team_released;


    event PrivateClaim(address indexed account, uint256 amount, uint256 time);
    event TeamClaim(address indexed account, uint256 amount, uint256 time);

    constructor() BEP20("CroToken", "CROT") {  

        private_stage = 0;            
        maxTotalSupply = 1000000 * (10 ** decimals());
        MAX_WALLET_BALANCE = maxTotalSupply.div(100);

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
            private_locks[whitelist[i]] -= croAmount;
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
        require(!isWhitelisted(_msgSender()), "Already listed");
        uint256 _totalfund = 0;
        for(uint256 i = 0; i < funds.length; i++) {
            _totalfund += funds[i];
        }
        
        if(_totalfund.div(PRIVATE_CRO_PRICE).add(private_totalMinted) > maxTotalSupply.mul(PIRVATE_CAP).div(100)) {
            revert("ERROR: Over flow");
        }        

        for(uint256 i = 0; i < _users.length; i++) {            
            uint256 _croAmount = funds[i].div(PRIVATE_CRO_PRICE);
            if (balanceOf(_users[i])+_croAmount > MAX_WALLET_BALANCE.mul(maxTotalSupply)) {
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

        uint256 amount = privateCanUnlockAmount(_msgSender());
        require(amount > 0, "Nothing to claim");
        require(amount.add(balanceOf(_msgSender())) <= MAX_WALLET_BALANCE.mul(maxTotalSupply), "ERROR: OverBalanced!!!");
        private_released[_msgSender()] += amount;
        private_locks[_msgSender()] -= amount;
        _mint(_msgSender(), amount);

        emit PrivateClaim(_msgSender(), amount, block.timestamp);
    }

    function privateCanUnlockAmount(address _account) public view returns (uint256) {
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

    function privateInfo() external view returns (uint8, uint256, uint256) {
        return (private_stage, private_startTime, private_endTime);
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
        require(stage == 1, "Cannot Claim now");
        require(block.timestamp > team_startTime, "ERROR: still Locked");
        require(_msgSender() == TEAM_ADVISOR_ADDRESS, "Invalid Address");

        uint256 amount = teamCanUnlockAmount();
        require(amount > 0, "Nothing to Claim");
        team_released += amount;
        team_locked -= amount;
        _mint(_msgSender(), amount);
    }

    // 

    function burn(uint256 _amount) external onlyOwner returns (bool) {
        require(balanceOf(owner()) >= _amount, "ERROR: Insufficient balance");
        _burn(owner(), _amount);
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
