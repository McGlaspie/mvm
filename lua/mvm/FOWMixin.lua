//
//
//
//


FOWMixin = CreateMixin( ColoredSkinsMixin )
FOWMixin.type = "FogOfWar"


FOWMixin.expectedMixins = {
	Model = "Needed for setting material parameters",
	Team = "",
	LOS = ""
}


FOWMixin.expectedCallbacks = {
    
}


FOWMixin.optionalCallbacks = {
    
}

FOWMixin.networkVars = {
    
}

function FOWMixin:__initmixin()

    

end


