//=============================================================================
//
//	NanoBot - AI "Personality" Profiles
//		Author: Brock 'McGlaspie' Gillespie
//
//	Bot profiles are ultra simplified representations of a Player's personality.
//	These are used to act as logical gates, mutations of values, and decision
//	augmentations.
//
//=============================================================================


assert( Server )


//???: Max mutation limiter?

kNanoBotProfiles = enum({ 'Cautious', 'Aggressive', 'Timid', 'Balanced', 'Supportive' })
//todo add first letter of enum string, lowercase, to [BOT(p)], Ex: [BOTc]

//-----------------------------------------------------------------------------


/*
--todo describe purpose & usage
*/
class 'NanoBotProfile'


function NanoBotProfile:Randomize()

end


function NanoBotProfile:Initialize( profileType )

	

end


function NanoBotProfile:GetProfile()

end


function NanoBotProfile:SetProfile( profileType )

	assert(profileName)
	
	self.profile = profileType
	
end


function NanoBotProfile:MutateValue( value, botState, isAction )

end




