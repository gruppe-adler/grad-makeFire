# GRAD MakeFire

* Enables you to:
  * build a fire (ACE-Selfinteraction)
  * add firewood (possible once --> fire gets bigger)
  * add leaves (possible twice --> fire smokes)
  * inspect fires (tells you how long since it was extinguished/burned down)
* Fires will:
  * burn down after X seconds
  * be unable to be lit again after they have burned down

GRAD MakeFire is multiplayer and JIP proof.

[![YOUTUBE VIDEO](http://i.imgur.com/uar5QUi.png)](https://www.youtube.com/watch?v=HQhSVDAufb4&feature=youtu.be)

## Dependencies
* [CBA_A3](https://github.com/CBATeam/CBA_A3)
* [ACE3](https://github.com/acemod/ACE3)


## Installation
### Manually
1. Create a folder in your mission root folder and name it `modules`. Then create one inside there and call it `grad-makeFire`.
2. Download the contents of this repository ( there's a download link at the side ) and put it into the directory you just created.
3. see step 3 below in the npm part

### Via `npm`
_for details about what npm is and how to use it, look it up on [npmjs.com](https://www.npmjs.com/)_

1. Install package `grad-makeFire` : `npm install --save grad-makeFire`
2. Prepend your mission's `description.ext` with `#define MODULES_DIRECTORY node_modules`
3. Append the following lines of code to the `description.ext`:

```sqf
class CfgFunctions {
    #include "node_modules\grad-makeFire\cfgFunctions.hpp"
};
```


## Usage
To make a fire you need to open up your ACE selfinteraction menu, go to "Equipment" and select "Make fire". You can interact with burning fires with ACE interaction and either "Add firewood" (making the fire bigger) or "Add leaves" (making the fire smoke). Both will add burn time to the fire. On non-burning fires you can select the "Inspect" interaction to see what happened to the fireplace. Use the vanilla mouse wheel interaction to light/extinguish fires.

Use this function to enable/disable a unit to build fires (default is true):
`[unit, allow] call GRAD_makeFire_allowBuilding;`

Use this function to manually add burn time to a fire (server only):
`[fire, time] call GRAD_makeFire_fnc_addBurnTime;`

| Parameter | Type   | Explanation |
| ----------|--------|-------------|
| unit      | object | The unit this applies to |
| allow     | bool   | Enable or disable this ability |
| fire      | object | The fire to which you want to add burn time. |
| time      | number | The time to add. |



## Configuration
You can configure this module in your `description.ext`. This is entirely optional however, since every setting has a default value.

Add the class `GRAD_makeFire` to your `description.ext`, then add any of these attributes to configure the module:

| Attribute       | Default Value         | Explanation                                                  |
|-----------------|-----------------------|--------------------------------------------------------------|
| treeRadius      | 40                    | max. distance to trees in order to be able to build a fire   |
| buildTime       | 15                    | time it takes to build a fire                                |
| upgradeTime     | 15                    | time it takes to add firewood                                |
| addLeavesTime   | 10                    | time it takes to add leaves                                  |
| burntimeSmall   | 180                   | time that a small fire will burn                             |
| burntimeBig     | 300                   | time that a big fire will burn                               |
| burntimeLeaves  | 30                    | time that adding leaves will add to burn time                |
| canBuildDefault | 1                     | can everyone build fires by default? (1/0)                   |
| playerDist      | 2                     | distance to player that a fire will be spawned on completion |
| classSmall      | "FirePlace_burning_F" | classname of small fire object                               |
| classBig        | "Campfire_burning_F"  | classname of big fire object                                 |
| actOffset[]     | {0,0,0.2}             | interaction point offset on fire                             |
| actDist         | 2.5                   | interaction distance on fire                                 |

Example:  

```sqf
class GRAD_makeFire {
    treeRadius = 40;                                
    buildTime = 15;                                 
    upgradeTime = 15;                               
    addLeavesTime = 10;                             
    burntimeSmall = 180;                            
    burntimeBig = 300;                              
    burntimeLeaves = 30;                            
    canBuildDefault = 1;                            

    playerDist = 2;                                 
    classSmall = "FirePlace_burning_F";             
    classBig = "Campfire_burning_F";                
    actOffset[] = {0,0,0.2};                        
    actDist = 2.5;                                  
};
```
