#ifndef MODULES_DIRECTORY
    #define MODULES_DIRECTORY modules
#endif

class GRAD_makeFire {
    class common {
        file = MODULES_DIRECTORY\grad-makeFire\functions;

        class addBurnTime {};
        class addInteractions {};
        class addLeaves {};
        class allowBuilding {};
        class burnOutTimer {};
        class createSmoke {};
        class getModuleRoot {};
        class initModule {postInit = 1;};
        class inspectFire {};
        class isNearTrees {};
        class makeFire {};
        class onUIEH {};
        class spawnFire {};
        class upgradeFire {};
    };
};

class C9J {
    class common {
        file = MODULES_DIRECTORY\grad-makeFire\functions;

        class createSmokeColumn {};
    };
};

class KK {
    class common {
        file = MODULES_DIRECTORY\grad-makeFire\functions;

        class inHouse {};
    };
};
