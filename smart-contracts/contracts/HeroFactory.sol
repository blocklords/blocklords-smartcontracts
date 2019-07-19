pragma solidity ^0.5.0;

import "./HeroToken.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
* @title HeroFactory
* @author Arseny Kin
* @notice Contract for Hero creation
*/

contract HeroFactory is Ownable {

	HeroToken public heroToken;

    constructor(address _heroToken) public { 
        heroToken = HeroToken(_heroToken);        
    }

    event HeroCreated(uint indexed id, address receiver);
    event HeroMadeOlder(uint indexed id);
    event HeroDied(uint indexed id);

    enum HeroAge {KID, YOUNG, MID, OLD}

    struct Hero{
        uint    GENERATION;   // Hero generation
        uint    FACE;         // Hero looks
        uint    LEADERSHIP;   // Leadership Stat value
        uint    INTELLIGENCE; // Intelligence Stat value
        uint    STRENGTH;     // Strength Stat value
        uint    SPEED;        // Speed Stat value
        uint    DEFENSE;      // Defense Stat value
        uint    CREATED_TIME;
        HeroAge AGE;          // kid, young, mid, old
        bool    ALIVE;        // indicates if the hero alive
    }

    mapping (uint => Hero) heroes;

    /**
    * @dev Adds a hero and mints a token
    * @param receiver address which token is being minted to
    * @return bool true if the hero was added succesfully
    */

    function addHero(address receiver, uint[8] memory stats) public payable onlyOwner returns(bool) {

        HeroAge age;

        if (stats[7] == 0) age = HeroAge.KID;
        else if (stats[7] == 1) age = HeroAge.YOUNG;
        else if (stats[7] == 2) age = HeroAge.MID;  
        else if (stats[7] == 3) age = HeroAge.OLD;
                 
        uint id = heroToken.mintTo(receiver);					
        heroes[id] = Hero({
                            GENERATION: stats[0],
                            FACE: stats[1],
                            LEADERSHIP: stats[2],     
                            INTELLIGENCE: stats[3],
                            STRENGTH: stats[4],
                            SPEED: stats[5],
                            DEFENSE: stats[6],
                            CREATED_TIME: block.number,
                            AGE: age,
                            ALIVE: true
                        });

        emit HeroCreated(id, receiver);

        return true;
    }

    /**
    * @dev Returns hero's basic information by id 
    * @param id token/hero id
    * @return Hero a hero with the given id
    */

    function getHero(uint id) public view returns(uint,uint,uint,HeroAge, bool){
        return (heroes[id].GENERATION, 
                heroes[id].FACE, 
                heroes[id].CREATED_TIME,
                heroes[id].AGE,
                heroes[id].ALIVE
                );
    }


    /**
    * @dev Returns hero's stats by id 
    * @param id token/hero id
    * @return Hero a hero with the given id
    */

    function getHeroStats(uint id) public view returns(uint,uint,uint,uint,uint){
        return (heroes[id].LEADERSHIP, 
                heroes[id].INTELLIGENCE, 
                heroes[id].STRENGTH,
                heroes[id].SPEED,
                heroes[id].DEFENSE
                );
    }

    /**
    * @dev Makes hero older 
    * @param id token/hero id
    */
    function makeOlder(uint id) public onlyOwner {
        require(heroToken.exists(id),
                "Hero does not exist");
        require(heroes[id].ALIVE,
                "Hero is already dead");
        if (heroes[id].AGE == HeroAge.KID) heroes[id].AGE = HeroAge.YOUNG;
        else if (heroes[id].AGE == HeroAge.YOUNG) heroes[id].AGE = HeroAge.MID;  
        else if (heroes[id].AGE == HeroAge.MID) heroes[id].AGE = HeroAge.OLD;
        
        emit HeroMadeOlder(id);
    }

    /**
    * @dev Kills a hero 
    * @param id token/hero id
    */    
    function killHero(uint id) public onlyOwner {
        require(heroToken.exists(id),
                "Hero does not exist");
        require(heroes[id].ALIVE,
                "Hero is already dead");
        heroes[id].ALIVE = false;
    
        emit HeroDied(id);
    }

    // TODO: add inheritance

}