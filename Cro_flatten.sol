yarn run v1.22.17
$ E:\gitwork\conexio-smart-contract\node_modules\.bin\hardhat flatten ./contracts/CroToken1.sol
// Sources flattened with hardhat v2.9.2 https://hardhat.org

// File contracts/util/Context.sol

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


// File contracts/ERC20/IBEP20.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File contracts/ERC20/IBEP20Metadata.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;
interface IBEP20Metadata is IBEP20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


// File contracts/ERC20/BEP20.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;
contract BEP20 is Context, IBEP20, IBEP20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {BEP20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IBEP20-balanceOf} and {IBEP20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IBEP20-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    /**
     * @dev See {IBEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IBEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
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

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
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

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
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

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
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

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
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

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
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

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


// File contracts/access/Ownable.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// File contracts/ReentrancyGuard.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// File contracts/SafeMath.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

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


// File contracts/CroToken1.sol

// SPDX-License-Identifier: MIT

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
Done in 1.97s.
