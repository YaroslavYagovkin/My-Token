pragma solidity ^0.4.17;

import "./SimpleTokenCoin.sol";
import "./SafeMath.sol";

/**
 * @title Crowdsale 
 * @dev Based on references from OpenZeppelin: https://github.com/OpenZeppelin/zeppelin-solidity
 */
contract Crowdsale is SimpleTokenCoin {
    
    using SafeMath for uint;
    
    uint public startPreICO;
    
    uint public startICO;
    
    uint public periodPreICO;
    
    uint public firstPeriodOfICO;
    
    uint public secondPeriodOfICO;
    
    uint public thirdPeriodOfICO;

    uint public hardcap;

    uint public rate;
    
    uint public softcap;
    
    uint public maxTokensAmount;
    
    uint public availableTokensAmount;
    
    mapping(address => uint) ethBalance;
    
    /**
    * @dev Data type to save bonus system's information.
    */
    struct BonusSystem {
        //Period number
        uint period;
        // UNIX timestamp of period start
        uint start;
        // UNIX timestamp of period finish
        uint end;
        //Amount of tokens available per period
        uint tokensPerPeriod;
        //Sold tokens Amount
        uint soldTokens;
        // How many % tokens will add
        uint bonus;
    }
    
    BonusSystem[] public bonus;
    
    /**
    * @dev Function to change bonus system.
    * @param percentageOfTokens Percentage of tokens for each period.
    * @param bonuses Percentage of bonus for each period.
    */
    function changeBonusSystem(uint[] percentageOfTokens, uint[] bonuses) public onlyOwner{
        for (uint i = 0; i < bonus.length; i++) {
            bonus[i].tokensPerPeriod = availableTokensAmount / 100 * percentageOfTokens[i];
            bonus[i].bonus = bonuses[i];
        }
    }
    
    /**
    * @dev Function to set bonus system.
    * @param preICOtokens , firstPeriodTokens, secondPeriodTokens, thirdPeriodTokens Percentage of tokens for each period.
    * @param preICObonus , firstPeriodBonus, secondPeriodBonus, thirdPeriodBonus Percentage of bonus for each period.
    */
    function setBonusSystem(uint preICOtokens, uint preICObonus, uint firstPeriodTokens, uint firstPeriodBonus, 
                            uint secondPeriodTokens, uint secondPeriodBonus, uint thirdPeriodTokens, uint thirdPeriodBonus) private {
        bonus.push(BonusSystem(0, startPreICO, startPreICO + periodPreICO * 1 days, availableTokensAmount / 100 * preICOtokens, 0, preICObonus));
        bonus.push(BonusSystem(1, startICO, startICO + firstPeriodOfICO * 1 days, availableTokensAmount / 100 * firstPeriodTokens, 0, firstPeriodBonus));
        bonus.push(BonusSystem(2, startICO + firstPeriodOfICO * 1 days, startICO + (firstPeriodOfICO + secondPeriodOfICO) * 1 days, availableTokensAmount / 100 * secondPeriodTokens, 0, secondPeriodBonus));
        bonus.push(BonusSystem(3, startICO + (firstPeriodOfICO + secondPeriodOfICO) * 1 days, startICO + (firstPeriodOfICO + secondPeriodOfICO + thirdPeriodOfICO) * 1 days, availableTokensAmount / 100 * thirdPeriodTokens, 0, thirdPeriodBonus));
    }
    
    /**
    * @dev Gets current bonus system.
    */
    function getCurrentBonusSystem() public constant returns (BonusSystem) {
      for (uint i = 0; i < bonus.length; i++) {
        if (bonus[i].start <= now && bonus[i].end >= now) {
          return bonus[i];
        }
      }
    }

    /**
    * @dev Sets values of periods.
    * @param PreICO_start The value of pre ICO start.
    * @param PreICO_period The duration of pre ICO period.
    * @param ICO_firstPeriod , ICO_secondPeriod, ICO_thirdPeriod The duration of each period.
    */
    function setPeriods(uint PreICO_start, uint PreICO_period, uint ICO_start, uint ICO_firstPeriod, uint ICO_secondPeriod, uint ICO_thirdPeriod) public onlyOwner {
        startPreICO = PreICO_start;
        periodPreICO = PreICO_period;
        startICO = ICO_start;
        firstPeriodOfICO = ICO_firstPeriod;
        secondPeriodOfICO = ICO_secondPeriod;
        thirdPeriodOfICO = ICO_thirdPeriod;
        bonus[0].start = PreICO_start;
        bonus[0].end = PreICO_start + PreICO_period * 1 days;
        bonus[1].start = ICO_start;
        bonus[1].end = ICO_start + ICO_firstPeriod * 1 days;
        bonus[2].start = bonus[1].end;
        bonus[2].end = bonus[2].start + ICO_secondPeriod * 1 days;
        bonus[3].start = bonus[2].end;
        bonus[3].end = bonus[2].end + ICO_thirdPeriod * 1 days;
    }
    
    /**
    * @dev Sets the rate of Token.
    */
    function setRate (uint _rate) public onlyOwner {
        rate = _rate * 10**8 ;
    }
    
    /**
    * @dev The Crowdsale constructor sets the first values to variables.
    */
    function Crowdsale() public{
        rate = 16000 * 10**8 ;
        startPreICO = 1522065600; // 03.26.2018 12:00
        periodPreICO = 14;
        startICO = 1525089600; // 04.30.2018 12:00
        firstPeriodOfICO = secondPeriodOfICO = thirdPeriodOfICO = 10;
        hardcap = 59694 * 10**17;
        softcap = 400 * 10**18;
        maxTokensAmount = 100000000 * 10**8;
        availableTokensAmount = maxTokensAmount - totalSupply;
        setBonusSystem(20, 40, 25, 25, 25, 15, 30, 0);
    }
    
    /**
    * @dev Throws if called when the period or tokens are over.
    */
    modifier isUnderPeriodLimit() {
        require(getCurrentBonusSystem().start <= now && getCurrentBonusSystem().end >= now && getCurrentBonusSystem().tokensPerPeriod - getCurrentBonusSystem().soldTokens > 0);
        _;
    }

    /**
    * @dev Function to mint tokens.
    * @param _to The address that will recieve the minted tokens.
    * @param _amount The amount of tokens to mint.
    */
    function buyTokens(address _to, uint256 _amount) internal canMint isNotFrozen returns (bool) {
        totalSupply = totalSupply.add(_amount);
        bonus[getCurrentBonusSystem().period].soldTokens = getCurrentBonusSystem().soldTokens.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        return true;
    }
    
    /**
    * @dev Refund 'msg.sender' in the case the Token Sale didn't 
    * reach the minimum funding goal.
    */
    function refund() restrictionOnUse isNotFrozen public {
        require(this.balance < softcap);
        uint value = ethBalance[msg.sender]; 
        ethBalance[msg.sender] = 0; 
        msg.sender.transfer(value); 
    }
    
    /**
    * @dev Ñalculates the required amount of tokens to be minted. 
    */
    function createTokens()private isUnderPeriodLimit isNotFrozen {
        uint tokens = rate.mul(msg.value).div(1 ether);
        uint bonusTokens = tokens / 100 * getCurrentBonusSystem().bonus;
        tokens += bonusTokens;
        if (msg.value < 10 finney || (tokens > getCurrentBonusSystem().tokensPerPeriod.sub(getCurrentBonusSystem().soldTokens))) {
            msg.sender.transfer(msg.value);
        }
        else {
            forTeamETH.transfer(msg.value);
            buyTokens(msg.sender, tokens);
            ethBalance[msg.sender] = ethBalance[msg.sender].add(msg.value);
        }
    }
    
    /**
    * Called when ETH comes to the contract.
    */
    function() external payable {
        createTokens();
    }
}