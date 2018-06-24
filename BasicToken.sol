pragma solidity ^0.4.17;

import "./ERC20Basic.sol";
import "./SafeMath.sol";


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
    
    using SafeMath for uint256;
    
    bool freeze = false;
    
    mapping(address => uint256) balances;
    
    uint endOfICO = 1527681600; // 05.30.2018 12:00
    
    /**
    * @dev Sets the date of the ICO end.
    * @param ICO_end The date of the ICO end.
    */
    function setEndOfICO(uint ICO_end) public onlyOwner {
        endOfICO = ICO_end;
    }
    
    /**
    * @dev Throws if called before the end of ICO.
    */
    modifier restrictionOnUse() {
        require(now > endOfICO);
        _;
    }
    
    /**
    * @dev Transfers tokens to a specified address.
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public restrictionOnUse isNotFrozen returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
    
    /**
    * @dev Changes the value of freeze variable.
    */
    function freezeToken()public onlyOwner {
        freeze = !freeze;
    }
    
    /**
    * @dev Throws if called when contract is frozen.
    */
    modifier isNotFrozen(){
        require(!freeze);
        _;
    }
    
    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the balance of.
    */
    function balanceOf(address _owner)public constant returns (uint256 balance) {
        return balances[_owner];
    }
}