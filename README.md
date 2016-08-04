# scripts_GRAD_makeFire
GRAD fire making system (originally for Rattrap)

* Enables you to:
  * build a fire (ACE-Selfinteraction)
  * add firewood (possible once --> fire gets bigger)
  * add leaves (possible twice --> fire smokes)
  * inspect fires (tells you how long since it was extinguished)
* Fires will:
  * burn down after X seconds
  * stop smoking when put out
  * be unable to be lit again after they have burned down
* To use this, you need to:
  * call initMakeFire.sqf on both server and clients on mission start
  * (optionally) configure fire making settings below the header in initMakeFire.sqf
  * (optionally) configure smoke pillar values in player\fn_createSmokeColumn.sqf

[YOUTUBE VIDEO](https://www.youtube.com/watch?v=HQhSVDAufb4&feature=youtu.be)
