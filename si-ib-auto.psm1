using module '.\New-FunctionFromConstructors\New-FunctionFromConstructors.psm1'

CLASS SpiritIslandGameInvaderBoard {
#region properties


#endregion properties


#region constructors
    SpiritIslandGameInvaderBoard () {}


#endregion constructors

#region methods

#endregion methods

}

#region Class Card        
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
    [ConstructorName('Empty')]
    Card () {}

    [ConstructorName('Default')]
    Card ([String[]]$CardText,
    [String]$CardTitle,
    [GameSet]$CardGameSet,
    [CardType]$CardType,
    [ScriptBlock[]]$OnPlayScripts,
    [ScriptBlock[]]$OnDiscardScripts
    ) {
        $this.CardText         = $CardText
        $this.CardTitle        = $CardTitle
        $this.CardGameSet      = $CardGameSet
        $this.CardType         = $CardType
        $this.OnPlayScripts    = $OnPlayScripts
        $this.OnDiscardScripts = $OnDiscardScripts
    
    }


#endregion constructors
 
#region methods
    [String[]] ReadCard(){
        Return @($this.CardTitle) + $this.CardText
    }<#End Method ReadCard#>

    [Object] OnPlay(){
        $returnable = foreach ($s in $this.OnPlayScripts) { $(Add-Member -InputObject $this -MemberType ScriptMethod -Name 'TempMethod' -Value $s -Force -PassThru).TempMethod()  }
        Return @($returnable)
    }<#End Method OnPlay#>

    [Object] OnDiscard(){
        $returnable = foreach ($s in $this.OnDiscardScripts) { $(Add-Member -InputObject $this -MemberType ScriptMethod -Name 'TempMethod' -Value $s -Force -PassThru).TempMethod()  }
        Return @($returnable)
    }<#End Method OnDiscard#>

#endregion methods

}

        FUNCTION New-Object-Card-Empty {
        [CmdletBinding()]
        PARAM()
        BEGIN{}
        PROCESS{
        $([Card].GetConstructors() | Where-Object {$_.GetCustomAttributes('ConstructorName').Name -Like 'Empty'} ).Invoke(@())
        }
        END{}
        }
        

        FUNCTION New-Object-Card-Default {
        [CmdletBinding()]
        PARAM([PARAMETER(Mandatory=$True,ValueFromPipelineByPropertyName=$True)][string[]]$CardText,[PARAMETER(Mandatory=$True,ValueFromPipelineByPropertyName=$True)][string]$CardTitle,[PARAMETER(Mandatory=$True,ValueFromPipelineByPropertyName=$True)][GameSet]$CardGameSet,[PARAMETER(Mandatory=$True,ValueFromPipelineByPropertyName=$True)][CardType]$CardType,[PARAMETER(Mandatory=$True,ValueFromPipelineByPropertyName=$True)][scriptblock[]]$OnPlayScripts,[PARAMETER(Mandatory=$True,ValueFromPipelineByPropertyName=$True)][scriptblock[]]$OnDiscardScripts)
        BEGIN{}
        PROCESS{
        $([Card].GetConstructors() | Where-Object {$_.GetCustomAttributes('ConstructorName').Name -Like 'Default'} ).Invoke(@($CardText,$CardTitle,$CardGameSet,$CardType,$OnPlayScripts,$OnDiscardScripts))
        }
        END{}
        }
        

#endregion Class Card        
    

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

