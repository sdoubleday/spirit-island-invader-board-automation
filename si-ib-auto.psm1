CLASS SpiritIslandGameInvaderBoard {
#region properties


#endregion properties


#region constructors
    SpiritIslandGameInvaderBoard () {}


#endregion constructors

#region methods

#endregion methods

}


CLASS Card {
#region properties
    [String[]]$CardText
    [String]$CardTitle
    [GameSet]$CardGameSet
    [CardType]$CardType
    [ScriptBlock[]]$OnPlayScripts
    [ScriptBlock[]]$OnDiscardScripts
    [Ref]$Parent <#To access the parent, use $this.Parent.Value#>
    [Ref]$InvaderBoard <#To access the InvaderBoard, use $this.InvaderBoard.Value#>
#endregion properties


#region constructors
    Card () {}

    Card ([String[]]$CardText,
    [String]$CardTitle,
    [GameSet]$CardGameSet,
    [CardType]$CardType,
    [ScriptBlock[]]$OnPlayScripts,
    [ScriptBlock[]]$OnDiscardScripts
    ) {
#        $this.CardText         = $CardText
#        $this.CardTitle        = $CardTitle
#        $this.CardGameSet      = $CardGameSet
#        $this.CardType         = $CardType
#        $this.OnPlayScripts    = $OnPlayScripts
#        $this.OnDiscardScripts = $OnDiscardScripts
    
    }


#endregion constructors
 
#region methods
    [String[]] ReadCard(){
        Return 'asdf'
#        Return @($this.CardTitle, $this.CardText)
    }<#End Method ReadCard#>

    OnPlay(){}<#End Method OnPlay#>

    OnDiscard(){}<#End Method OnDiscard#>

#endregion methods

}
    

CLASS Deck {
#region properties


#endregion properties


#region constructors
    Deck () {}


#endregion constructors

#region methods

#endregion methods

}


CLASS TurnPhase {
#region properties


#endregion properties


#region constructors
TurnPhase () {}


#endregion constructors

#region methods

#endregion methods

}        


CLASS CardRegister {
#region properties
    [Card]$Card
#endregion properties


#region constructors
    CardRegister () {}


#endregion constructors

#region methods
#    GetCard ([Card]$card) {
#        [ref]$me = $this
#        $card.Parent = $me
#        $this.Card = $card }
    ActivateRegister () {
#        $this.Card.ReadCard()
#        $this.Card.OnPlay()
    }<#End Method ActivateRegister ()#>

#    [Card] 
    PassCard () {
#        $return = $this.Card
#        $this.Card = $null
#        return $return
    }<#End Method PassCard ()#>
#endregion methods

}

CLASS InvaderCardRegister : CardRegister {}

ENUM GameSet {
    Core = 0
    BranchAndClaw = 1
}

ENUM CardType {
    Invader = 0
    Fear = 1
    MinorPower = 2
    MajorPower = 3
    UniquePower = 4
    Blight = 5
    Terror = 6
    Event = 7
}

