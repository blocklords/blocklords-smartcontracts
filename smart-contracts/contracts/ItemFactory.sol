pragma solidity ^0.5.0;

import "./HeroToken.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
* @title ItemFactory
* @author Arseny Kin
* @notice Contract for Item creation
*/

contract ItemFactory is Ownable {

	HeroToken public heroToken;

    constructor(address _heroToken) public { 
        heroToken = HeroToken(_heroToken);        
    }

	event ItemCreated(uint indexed id);
	event ItemStatUpgraded(uint indexed id, uint newValue);
	event ItemLevelUp(uint indexed id, uint newLevel);
	event ItemXpGained(uint indexed id, uint newXpAmount);
	event ItemBurned(uint indexed id);

	struct Item{

        uint OWNER;      
        uint STAT_TYPE;  
        uint QUALITY;    
        uint GENERATION; 
        uint STAT_VALUE;
        uint LEVEL;
        uint XP;         // Each battle where, Item was used by Hero, increases Experience (XP). Experiences increases Level. Level increases Stat value of Item
        bool BURNED;
    }

    uint[] itemIds = [0]; // a list of item ids, item ids start from 1
    mapping (uint => Item) public items;

    /**
    * @dev Creates an item
    * @param heroId id of a hero owner- ERC721 id
    * @param statType Item can increase only one stat of Hero, there are five: Leadership, Defense, Speed, Strength and Intelligence
	* @param quality Item can be in different Quality. Used in Gameplay.
	* @param generation generation of an item
	* @param statValue value of a stat improvement for the item
    */
    function addItem(uint heroId,
    				 uint statType,
      				 uint quality,
      				 uint generation,
      				 uint statValue) public onlyOwner {
        require(heroToken.exists(heroId),
                "Hero does not exist");

        uint id = itemIds.length;
		itemIds.push(id);        

        items[id] = Item({
                        OWNER: heroId,
                        STAT_TYPE: statType,
                        QUALITY: quality,     
                        GENERATION: generation,
                        STAT_VALUE: statValue,
                        LEVEL: 0,
                        XP: 0,
                        BURNED: false
                    });
        emit ItemCreated(id);
    }

    /**
    * @dev Returns a number of total items
    */
    function totalItems() public view returns(uint){
    	return itemIds.length-1; // kill 0 element
    }

    /**
    * @dev checks if the item is upgradable
    * @param id item id 
    */
    function isUpgradable(uint id) private view returns (bool){
      if (id == 0) return false;
      if (items[id].STAT_VALUE == 0) return false;

      if (items[id].QUALITY == 1 && items[id].LEVEL == 3) return false;
      if (items[id].QUALITY == 2 && items[id].LEVEL == 5) return false;
      if (items[id].QUALITY == 3 && items[id].LEVEL == 7) return false;
      if (items[id].QUALITY == 4 && items[id].LEVEL == 9) return false;
      if (items[id].QUALITY == 5 && items[id].LEVEL == 10) return false;

      return true;
    }

    /**
    * @dev Checks if the item exists
    * @param id item id
    */
    function itemExists(uint id) public view returns(bool){
    	return items[id].OWNER !=0 && items[id].STAT_VALUE != 0 && items[id].BURNED == false;
    }

    // TODO: add change owner

    /**
    * @dev Updates item stat value
    * @param id item id
    * @param newValue new stat value
    */
    function upgradeItemStatValue(uint id, uint newValue) public onlyOwner{
    	require(isUpgradable(id),
    			"This item is not upgradable");
    	require(itemExists(id),
    			"Item does not exist" );
    	items[id].STAT_VALUE = newValue;
    	
    	emit ItemStatUpgraded(id,newValue);
    }

    /**
    * @dev Updates item xp
    * @param id item id
    * @param newXp new xp value
    */
    function addItemXp(uint id, uint newXp) public onlyOwner{
    	require(isUpgradable(id),
    			"This item is not upgradable");
    	require(itemExists(id),
    			"Item does not exist" );
    	items[id].XP = newXp;

    	emit ItemXpGained(id, newXp);
    }

    /**
    * @dev Increments item level by one
    * @param id item id
    */
    function addItemLvl(uint id) public onlyOwner{
    	require(isUpgradable(id),
    			"This item is not upgradable");
    	require(itemExists(id),
    			"Item does not exist" );
    	items[id].LEVEL += 1;
    	
    	emit ItemLevelUp(id, items[id].LEVEL);
    }

    /**
    * @dev Burns item
    * @param id item id
    */
    function burnItem(uint id) public onlyOwner{
		require(itemExists(id),
	    			"Item does not exist" );
		items[id].BURNED = true;
    
		emit ItemBurned(id);
    }

}