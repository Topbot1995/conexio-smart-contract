// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "./ERC721/IERC721Enumerable.sol";
import "./util/SafeMath.sol";
import "./access/Ownable.sol";

contract CroNFTStaking is Ownable  {
    using SafeMath for uint256;
    
    // Info of each user
    struct UserInfo {
        uint256[] tokenIds;
        uint256 amount;
        uint256 pendingAmount,                        
    }

    mapping(address => UserInfo) public userInfo;
    
    IERC721Enumerable public immutable croNFT;    
    uint256 public totalStakedAmount;
    uint256 public rewardPerToken;
    uint256 public minDays;       
    uint256 public harvestFee;
    address private feeWallet;
    uint256 private _rewardBalance;

    mapping(uint256 => uint256) StakedTimes;    

    event Stake(address indexed user, uint256 amount);    
    event DepositReward(address indexed user, uint256 amount);
    event UnStake(address indexed user, uint256 amount, uint256 unStakeFee);
    event Harvest(address indexed user, uint256 amount, uint256 harvestFee);
    event SetFeeWallet(address indexed _feeWallet);    
    event SetHarvestFee(uint256 _harvestFee);

    constructor(
        IERC721Enumerable _croNFT,
        address _feeWallet
    ) {
        croNFT = _croNFT;
        feeWallet = _feeWallet;
    }

    function setFeeWallet(address _feeWallet) external onlyOwner {
        feeWallet = _feeWallet;
        emit SetFeeWallet(feeWallet);
    }

    function setHarvestFee(uint256 _feePercent) external onlyOwner {
        require(_feePercent <= 40, "setHarvestFee: feePercent > 40");
        harvestFee = _feePercent;
        emit SetHarvestFee(_feePercent);
    }

    function getPending(address _user) public view returns (uint256) {
        uint256 pending = _getPending(_user);
        uint256 _harvestFee = pending.mul(harvestFee).div(100);
        return pending - _harvestFee;
    }

    function _getPending(address _user) private view returns (uint256) {
        require(_user != address(0), "ERROR: Invalid Address");
        UserInfo storage user = userInfo[_user];        
        uint256 rewardNumber = 0;
        for (uint256 i = 0; i < user.tokenIds.length; i++) {
            uint256 _tokenId = user.tokenIds[i];
            if((block.timestamp -  StakedTimes[_tokenId]) > 7 days) {
                rewardNumber += 1;
            }            
        }        

        return rewardNumber.mul(rewardPerToken).add(user.pendingAmount);
    }
    
    function depositReward(uint256 _amount) external onlyOwner payable {
        require(_amount > 0, "ERROR: Invalid Amount");
        emit DepositReward(msg.sender, _amount);
        _rewardBalance = _rewardBalance.add(_amount);
    }   

    function stake(uint256[] memory _tokenIds) public {
        require(_tokenIds.length > 0 , "ERROR: No token ids");                
        UserInfo storage user = userInfo[msg.sender];
        for (uint256 i = 0; i < _tokenIds.length; i++) {              

            croNFT.safeTransferFrom(msg.sender, address(this), _tokenIds[i]);
            user.tokenIds.push(_tokenIds[i]);
            StakedTimes[_tokenIds[i]] = block.timestamp;
            totalStakedAmount += 1;
            user.amount += 1;
        }
        
        emit Stake(_tokenIds.length, _amount);
    }

    function unStake(uint256[] memory _tokenIds) public {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "unStake: not good");  
        
        uint256 rewardNumber;        
        for (uint256 i = 0; i < _tokenIds.length; i++) {           
            
            uint256 index = itemIndex(user.tokenIds, _tokenIds[i]);                       
            arrayPop(user.tokenIds, index);
            if((block.timestamp -  StakedTimes[_tokenId[index]]) > 7 days) {
                rewardNumber += 1;
            } 

            croNFT.safeTransferFrom(address(this), msg.sender, _tokenIds[i]);
            
        }

        totalStakedAmount -= _tokenIds.length;
        user.amount -= _tokenIds.length; 
        _rewardBalance = _rewardBalance.sub(rewardPerToken.mul(rewardNumber));        
        user.pendingAmount += rewardPerToken.mul(rewardNumber);

        emit Stake(msg.sender, _tokenIds.length);
                
    }

    function harvest() external {
        UserInfo storage user = userInfo[msg.sender];
        require(userInfo.amount > 0, "ERROR: No Staked Tokens");
        uint256 pending = getPending(msg.sender);
        if (pending > _rewardBalance) {
            pending = _rewardBalance;
        }
        _rewardBalance = _rewardBalance.sub(pending);
        user.pendingAmount = user.pendingAmount.sub(pending);
        payable(msg.sender).send(pending);                    
    }

    function arrayPop(uint256[] storage array, uint256 _index) internal pure returns (uint256[] storage) {
        for (uint256 i = _index; i < array.length - 1; i++) {
            array[i] = array[i+1];
        }
        array.pop();
        return array;
    }
    function itemIndex(uint256[] memory array, uint256 _item) internal pure returns (uint256) {
        for (uint256 i = 0; i < array.length - 1; i++) {
            if(array[i] == _item) {
                return i;
            }
        }        
        return 0;
    }

}

