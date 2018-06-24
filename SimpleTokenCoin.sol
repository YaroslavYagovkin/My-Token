pragma solidity ^0.4.17;

import "./BurnableToken.sol";

/**
 * @title SimpleTokenCoin
 * @dev SimpleToken is a standard ERC20 token with some additional functionality
 */
contract SimpleTokenCoin is BurnableToken {
    
    address public forBounty = 0xdd5Aea206449e510A9e0c45B6b3fdAc684e0c8bD;
    address public forTeamET = 0x3FFeEcc23Dc94Fd5089A8C377a6e7Bf15F0D2f8d;
    address public forTeamETH = 0x619E27C6BfEbc1935A048Fb79B397314cfA82d89;
    address public forFund = 0x7b7c6d8ce28353e39611dD14A68DA6Af63c63FF7;
    address public forLoyalty = 0x22152A666AaD84b0eaadAD00e3F19547C30CcB02;
    
    string public constant name = "Example Token";
    
    string public constant symbol = "ET";
    
    uint32 public constant decimals = 8;
    
    address private contractAddress;
    
    /**
    * @dev Sets the address of approveAndCall contract.
    * @param _address The address of approveAndCall contract.
    */
    function setContractAddress (address _address) public onlyOwner {
        contractAddress = _address;
    }
    
    /**
    * @dev The SimpleTokenCoin constructor mints tokens to four addresses.
    */
    function SimpleTokenCoin()public {
        mint(forBounty, 4000000 * 10**8);
        mint(forTeamET, 10000000 * 10**8); 
        mint(forFund, 10000000 * 10**8);
        mint(forLoyalty, 2000000 * 10**8);
    }
    
    /**
    * @dev Function to send ETH from contract address to team ETH address.
    */
    function sendETHfromContract() public onlyOwner {
        forTeamETH.transfer(this.balance);
    }
    
    /**
     * @dev Sends to multiple addresses using two arrays which
     * include the address and the amount of tokens.
     * @param users Array of addresses to send to.
     * @param bonus Array of amount of tokens to send.
     */
    function multisend(address[] users, uint[] bonus) public {
        for (uint i = 0; i < users.length; i++) {
            transfer(users[i], bonus[i]);
        }
    }
    
    /**
     * @dev Token owner can approve for spender to execute another function.
     * @param tokens Amount of tokens to execute function.
     * @param data Additional data.
     */
    function approveAndCall(uint tokens, bytes data) public restrictionOnUse returns (bool success) {
        approve(contractAddress, tokens);
        ApproveAndCallFallBack(contractAddress).receiveApproval(msg.sender, tokens, data);
        return true;
    }
}

interface ApproveAndCallFallBack { function receiveApproval(address from, uint256 tokens, bytes data) external; }