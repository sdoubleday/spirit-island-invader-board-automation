<#SDS Modified Pester Test file header to handle modules.#>
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = ( (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.' ) -replace '.ps1', '.psd1'
$scriptBody = "using module $here\$sut`r`nusing module $here\Lumberjack\Lumberjack.psd1"
$script = [ScriptBlock]::Create($scriptBody)
. $script

<#
all prompts to continue print the status of the invader board and offer options to add fear and to put blight on the board, 
and they reinvoke the prompt afterward.

setup take expansions array, scenario, adversary, adversary level, player array (can be extended to which spirits and include board selection. 
    some spirits might adjust the instructions, especially the most verbose instructions, such as reminders for Heart of the
    Wildfire, Ocean's Hungry Grasp, and Bringer of Dreams and Nightmares)

V1 will not actually implement the different event and fear cards, just saying "Draw and play the next card from the Fear deck) or whatever.
As such it will also not implement anything for Bringer regarding revealing fear cards.
It will also not need to support the insert into deck effect



Print setup instructions based on chosen adversary, scenario, and spirits. prompt for continue

turnphase
print intructions for spirit growth phase and prompt for continue
print intructions for spirit energy phase and prompt for continue
print intructions for spirit Power Selection and payment phase and prompt for continue
print intructions for fast powers phase and prompt for continue
CurrentLinkedBlightDeck.ActivateDeck()
CurrentLinkedEventDeck.GetTopFromUpstream()
CurrentLinkedEventDeck.ActivateDeck() 
    If not playing expansion
DiscardLinkedEventDeck.GetWholeDeckFromUpstream()
CurrentLinkedFearDeck.ActivateDeck()
DiscardLinkedFearDeck.GetWholeDeckFromUpstream()
Foreach ($invaderphasedeck in $invaderPhaseDecks) {
    if($invaderphasedeck.Type -like 'Explore') {$invaderphasedeck.GetTopFromUpstream()}
    $invaderphasedeck.ActivateDeck()
    $invaderphasedeck.Downstream.Value.GetWholeDeckFromUpstream()
}
print intructions for slow powers phase and prompt for continue
print instructions for time passes and prompt for continue

#>

Describe "Class SpiritIslandGameInvaderBoard" {
    Context "Class Basics" {
        BeforeAll {
            $obj = [SpiritIslandGameInvaderBoard]::NEW()
            $classname = 'SpiritIslandGameInvaderBoard'
        }

        $Properties = @(
            'Card Scenario'
            ,'Card Adversary'
            ,'Int32 AdversaryLevel'
            ,'Deck BlightDeck'
            ,'CardRegister BlightRegister'
            ,'Int32 BlightPool'
            ,'Deck TerrorDeck'
            ,'CardRegister TerrorRegister'
            ,'Int32 TerrorLevel'
            ,'Deck FearDeck'
            ,'Deck FearCardsEarned'
            ,'Deck FearCardsDiscarded'
            ,'Int32 FearPool'
            ,'Int32 InvaderStage'
            ,'Deck InvaderDeck'
            ,'CardRegister[] InvaderActionRegistry'
            ,'Deck EventDeck'
            ,'CardRegister EventRegister'
            ,'Deck EventDiscard'
            ,'TurnPhase[] TurnOrder'
            ,'Int32 TurnNumber'
            ,'Lumberjack lj'
        )
        $Methods = @(
            'Setup'
            ,'NextTurn'
            ,'NextTUrnPhase'
            ,'TakeBlight'
            ,'EarnFear'
            ,'CheckFearPool'
            ,'ResetFearPoolAndEarnFearCard'
            ,'CheckFearDeck'
            ,'EarnTerrorLevel'
            ,'WinAndScore'
            ,'SacrificeVictoryAndScore'
            ,'LoseAndScore'
            ,'GetRef'
        )

#region run basic tests
        $ActualProperties = $obj | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty @{name='nameAndType';expression={$_.name + ' - ' + $_.TypeName}}
        $ActualMethods = $obj | Get-Member -MemberType Method | Select-Object -ExpandProperty name 
        foreach ($p in $Properties) {
            IT "Class $classname should have property $p" {
                $ActualProperties -contains $p | SHOULD BE $true }
        }<#End Foreach Properties#>

        foreach ($m in $Methods) {
            IT "Class $classname should have method $m" {
                $ActualMethods -contains $m | SHOULD BE $true }
        }<#End Foreach Properties#>
#endregion run basic tests

    }<#END CONTEXT Class Basics#>
}<#End Describe Class SpiritIslandGameInvaderBoard#>

Describe "Class Card" {
    BEFOREALL{
        [String[]]$CardText = @("Card Text Line 1","Card Text Line 2 With`r`ncarriage return and newline.")
        [String]$CardTitle='My Test Card'
        [GameSet]$CardGameSet=[GameSet]::BranchAndClaw
        [CardType]$CardType=[CardType]::Fear
        [ScriptBlock[]]$OnPlayScripts=@({Return 'OnPlayScripts1'},{$this | out-string | write-verbose -Verbose; Return $this.CardType})
        [ScriptBlock[]]$OnDiscardScripts=@({Return 'OnDiscardScripts1'})

        $PSCO_Card = [PSCustomObject]@{
            CardText=$CardText;
            CardTitle=$CardTitle;
            CardGameSet=$CardGameSet;
            CardType=$CardType;
            OnPlayScripts=$OnPlayScripts;
            OnDiscardScripts=$OnDiscardScripts
            }
        Write-Verbose -Verbose 'Echoing PSCO_Card'
        $PSCO_Card | Write-Verbose -Verbose
    }
    
    Context "Class Basics" {
        BeforeAll {
            $obj = [Card]::NEW()
            $classname = 'Card'
        }

        $Properties = @(
            'String[] CardText'
            ,'String CardTitle'
            ,'GameSet CardGameSet'
            ,'CardType CardType'
            ,'ScriptBlock[] OnPlayScripts'
            ,'ScriptBlock[] OnDiscardScripts'
            ,'Ref Parent'
            ,'Ref InvaderBoard'
        )
        $Methods = @(
            'ReadCard'
            ,'OnPlay'
            ,'OnDiscard'
        )

#region run basic tests
        $ActualProperties = $obj | Get-Member -MemberType Property | Select-Object -ExpandProperty definition
        $ActualProperties | write-verbose -Verbose 
        $ActualMethods = $obj | Get-Member -MemberType Method | Select-Object -ExpandProperty name 
        foreach ($p in $Properties) {
            IT "Class $classname should have property $p" {
                $ActualProperties -contains "$p {get;set;}" | SHOULD BE $true }
        }<#End Foreach Properties#>

        foreach ($m in $Methods) {
            IT "Class $classname should have method $m" {
                $ActualMethods -contains $m | SHOULD BE $true }
        }<#End Foreach Properties#>
#endregion run basic tests

    }<#END CONTEXT Class Basics#>

    CONTEXT "New-Object-Card-Default Returns a card with the appropriate values" {
        
        IT "New-Object-Card-Default returns a Card object" {
            ( $PSCO_Card | New-Object-Card-Default ).GetType().Name | Should Be 'Card' }

#            ( $PSCO_Card | New-Object-Card-Default ) | out-string | Write-Verbose -Verbose

        IT "New-Object-Card-Default CardText[0] is $($CardText[0])" {
            ( $PSCO_Card | New-Object-Card-Default ).CardText[0] | Should Be $CardText[0] }

        IT "New-Object-Card-Default CardText[1] is $($CardText[1])" {
            ( $PSCO_Card | New-Object-Card-Default ).CardText[1] | Should Be $CardText[1] }

        IT "New-Object-Card-Default CardTitle is $($CardTitle)" {
            ( $PSCO_Card | New-Object-Card-Default ).CardTitle | Should Be $CardTitle }

        IT "New-Object-Card-Default GameSet is $($CardGameSet)" {
            ( $PSCO_Card | New-Object-Card-Default ).CardGameSet | Should Be $CardGameSet }

        IT "New-Object-Card-Default CardType is $($CardType)" {
            ( $PSCO_Card | New-Object-Card-Default ).CardType | Should Be $CardType }

        IT "New-Object-Card-Default Invoke-Command OnPlayScripts[0] is 'OnPlayScripts1'" {
            ( $PSCO_Card | New-Object-Card-Default ).OnPlayScripts[0] | ForEach-Object {Invoke-Command $_} | Should Be 'OnPlayScripts1' }

        <#This test is invalid here, because there's no "$this" in this context. It needs to be actually ATTACHED to an object as a member for that to work
        IT "New-Object-Card-Default Invoke-Command OnPlayScripts[1] is '$CardType'" {
            Invoke-Command ( $PSCO_Card | New-Object-Card-Default ).OnPlayScripts[1] | Should Be $CardType }
        #>

        IT "New-Object-Card-Default Invoke-Command OnDiscardScripts[0] is 'OnDiscardScripts1'" {
            ( $PSCO_Card | New-Object-Card-Default ).OnDiscardScripts[0] | ForEach-Object {Invoke-Command $_} | Should Be 'OnDiscardScripts1' }
        
    } <#END CONTEXT "New-Object-Card-Default Returns a card with the appropriate values"#>
    
    CONTEXT "Card functionality" {
        
        IT "Card.ReadCard()[0] | SHOULD BE $CardTitle" {( $PSCO_Card | New-Object-Card-Default ).ReadCard()[0] | SHOULD BE $CardTitle}

        IT "Card.ReadCard()[1] | SHOULD BE $($CardText[0])" {( $PSCO_Card | New-Object-Card-Default ).ReadCard()[1] | SHOULD BE $($CardText[0])}

        IT "Card.ReadCard()[2] | SHOULD BE $($CardText[1])" {( $PSCO_Card | New-Object-Card-Default ).ReadCard()[2] | SHOULD BE $($CardText[1])}

        IT 'Card.OnPlay()[0] | SHOULD BE "OnPlayScripts1"' {( $PSCO_Card | New-Object-Card-Default ).OnPlay()[0] | SHOULD BE "OnPlayScripts1"}

        IT "Card.OnPlay()[1] | SHOULD BE $CardType" {( $PSCO_Card | New-Object-Card-Default ).OnPlay()[1] | SHOULD BE $CardType}

        IT "Card.OnDiscard()[0] | Should Be 'OnDiscardScripts1'" {( $PSCO_Card | New-Object-Card-Default ).OnDiscard()[0] | Should Be 'OnDiscardScripts1'}

    }

}<#End Describe Class Card#>

Describe "Class Instructor" {
    Context "Class Basics" {
        BeforeAll {
            $obj = [Instructor]::NEW()
            $classname = 'Instructor'
        }
        
        It "$classname.GetType().BaseType | Should Be 'Instructor'" {
            $obj.GetType().BaseType | Should Be 'Instructor' }

        $Properties = @(
             'String[] Instructions'
            ,'String[] InstructionsAddendum'
            ,'String[][] StackOfInstructionsByTurn'
            ,'String[] InstructionsForUpcomingTurn'
        )
        $Methods = @(
             'ActivateRegisteredCard'
            ,'PrintInstructions'
        )

#region run basic tests
        $ActualProperties = $obj | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty @{name='nameAndType';expression={$_.name + ' - ' + $_.TypeName}}
        $ActualMethods = $obj | Get-Member -MemberType Method | Select-Object -ExpandProperty name 
        foreach ($p in $Properties) {
            IT "Class $classname should have property $p" {
                $ActualProperties -contains $p | SHOULD BE $true }
        }<#End Foreach Properties#>

        foreach ($m in $Methods) {
            IT "Class $classname should have method $m" {
                $ActualMethods -contains $m | SHOULD BE $true }
        }<#End Foreach Properties#>
#endregion run basic tests

    It "Has tests for constructor functions and method functionality."

    }<#END CONTEXT Class Basics#>
}<#End Describe CardRegister#>

Describe "Class LinkedDeck" {
    BEFOREALL{
        [String[]]$CardText1 = @("Card Text Line 1","Card Text Line 2 With`r`ncarriage return and newline.")
        [String]$CardTitle1='My Test Card'
        [GameSet]$CardGameSet1=[GameSet]::BranchAndClaw
        [CardType]$CardType1=[CardType]::Fear
        [ScriptBlock[]]$OnPlayScripts1=@({Return $this.CardTitle},{$this | out-string | write-verbose -Verbose; Return $this.CardType})
        [ScriptBlock[]]$OnDiscardScripts1=@({Return 'OnDiscardScripts1'})

        $PSCO_Card1 = [PSCustomObject]@{
            CardText=$CardText1;
            CardTitle=$CardTitle1;
            CardGameSet=$CardGameSet1;
            CardType=$CardType1;
            OnPlayScripts=$OnPlayScripts1;
            OnDiscardScripts=$OnDiscardScripts1
            }
        Write-Verbose -Verbose 'Echoing PSCO_Card1'
        $PSCO_Card1 | Write-Verbose -Verbose

        [String[]]$CardText2 = @("Card Text Line 1","Card Text Line 2 With`r`ncarriage return and newline.")
        [String]$CardTitle2='My Second Card'
        [GameSet]$CardGameSet2=[GameSet]::Core
        [CardType]$CardType2=[CardType]::Fear
        [ScriptBlock[]]$OnPlayScripts2=@({Return $this.CardTitle},{$this | out-string | write-verbose -Verbose; Return $this.CardType})
        [ScriptBlock[]]$OnDiscardScripts2=@({Return 'OnDiscardScripts1'})

        $PSCO_Card2 = [PSCustomObject]@{
            CardText=$CardText2;
            CardTitle=$CardTitle2;
            CardGameSet=$CardGameSet2;
            CardType=$CardType2;
            OnPlayScripts=$OnPlayScripts2;
            OnDiscardScripts=$OnDiscardScripts2
            }
        Write-Verbose -Verbose 'Echoing PSCO_Card2'
        $PSCO_Card2 | Write-Verbose -Verbose

        [Cards[]]$CardsLD1 = ( $PSCO_Card1 | New-Object-Card-Default ),( $PSCO_Card2 | New-Object-Card-Default )
        [CardType]$CardTypeLD1=[CardType]::Fear
        [String]$DeckTypeLD1 = 'Source'
        [String]$NameLD1 = 'FearDeck'
        [ScriptBlock[]]$OnEmptyScriptsLD1=@({Return "You Win!"})

        $PSCO_LinkedDeck1 = [PSCustomObject]@{
            Cards=$CardsLD1
            CardType=$CardTypeLD1
            DeckType=$DeckTypeLD1
            Name=$NameLD1
            OnEmptyScripts=$OnEmptyScriptsLD1
         }
        Write-Verbose -Verbose 'Echoing PSCO_LinkedDeck1'
        $PSCO_LinkedDeck1 | Write-Verbose -Verbose

        [CardType]$CardTypeLD2=[CardType]::Fear
        [String]$DeckTypeLD2 = 'Current'
        [String]$NameLD2 = 'CurrentFearPile'
        [ScriptBlock[]]$OnEmptyScriptsLD2=@({Return "Carry On."})

        $PSCO_LinkedDeck2 = [PSCustomObject]@{
            CardType=$CardTypeLD2
            DeckType=$DeckTypeLD2
            Name=$NameLD2
            OnEmptyScripts=$OnEmptyScriptsLD2
         }
        Write-Verbose -Verbose 'Echoing PSCO_LinkedDeck2'
        $PSCO_LinkedDeck2 | Write-Verbose -Verbose

        [CardType]$CardTypeLD3=[CardType]::Fear
        [String]$DeckTypeLD3 = 'Discard'
        [String]$NameLD3 = 'FearDiscard'
        [ScriptBlock[]]$OnEmptyScriptsLD3=@({Return "This is unlikely :-)"})

        $PSCO_LinkedDeck3 = [PSCustomObject]@{
            CardType=$CardTypeLD3
            DeckType=$DeckTypeLD3
            Name=$NameLD3
            OnEmptyScripts=$OnEmptyScriptsLD3
         }
        Write-Verbose -Verbose 'Echoing PSCO_LinkedDeck3'
        $PSCO_LinkedDeck3 | Write-Verbose -Verbose

    }

    Context "Class Basics" {
        BeforeAll {
            $obj = [LinkedDeck]::NEW()
            $classname = 'LinkedDeck'
        }

        It "$classname.GetType().BaseType | Should Be 'LinkedDeck'" {
            $obj.GetType().BaseType | Should Be 'LinkedDeck' }

        $Properties = @(
             'Card[] Cards'
            ,'CardType CardType'
            ,'String DeckType'
            ,'String Name'
            ,'Ref Upstream'
            ,'Ref Downstream'
            ,'Instructor Instructor'
            ,'Lumberjack lj'
            ,'ScriptBlock[] OnEmptyScripts'
        )
        $Methods = @(
             'ActivateDeck'
            ,'GetTopFromUpstream'
            ,'GetWholeDeckFromUpstream'
            ,'Shuffle'
            ,'ProvideTopCard'
            ,'ProvideWholeDeck'
            ,'RunOnEmptyScripts'
            ,'GetSelfRef'
        )

#region run basic tests
        $ActualProperties = $obj | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty @{name='nameAndType';expression={$_.name + ' - ' + $_.TypeName}}
        $ActualMethods = $obj | Get-Member -MemberType Method | Select-Object -ExpandProperty name 
        foreach ($p in $Properties) {
            IT "Class $classname should have property $p" {
                $ActualProperties -contains $p | SHOULD BE $true }
        }<#End Foreach Properties#>

        foreach ($m in $Methods) {
            IT "Class $classname should have method $m" {
                $ActualMethods -contains $m | SHOULD BE $true }
        }<#End Foreach Properties#>
#endregion run basic tests
    }<#END CONTEXT Class Basics#>

    CONTEXT "New-Object-LinkedDeck-Default Returns a LinkedDeck with the appropriate values" {
        
        IT "New-Object-LinkedDeck-Default Returns a LinkedDeck object" {
            ( $PSCO_LinkedDeck2 | New-Object-LinkedDeck-Default ).GetType().Name | Should Be 'LinkedDeck' }

        IT "New-Object-LinkedDeck-Default Cards is `$null" {
            ( $PSCO_LinkedDeck2 | New-Object-LinkedDeck-Default ).Cards | Should Be $null }

        IT "New-Object-LinkedDeck-Default Name is $($NameLD2)" {
            ( $PSCO_LinkedDeck2 | New-Object-LinkedDeck-Default ).Name | Should Be $NameLD2 }

        IT "New-Object-LinkedDeck-Default CardType is $($CardTypeLD2)" {
            ( $PSCO_LinkedDeck2 | New-Object-LinkedDeck-Default ).CardType | Should Be $CardTypeLD2 }

        IT "New-Object-LinkedDeck-Default DeckType is $($DeckTypeLD2)" {
            ( $PSCO_LinkedDeck2 | New-Object-LinkedDeck-Default ).DeckType | Should Be $DeckTypeLD2 }

        IT "New-Object-LinkedDeck-Default Invoke-Command OnEmptyScripts[0] is 'Carry On.'" {
            ( $PSCO_LinkedDeck2 | New-Object-LinkedDeck-Default ).OnEmptyScripts[0] | ForEach-Object {Invoke-Command $_} | Should Be 'Carry On.' }

    } <#END CONTEXT "New-Object-LinkedDeck-Default Returns a LinkedDeck with the appropriate values"#>
    
    CONTEXT "New-Object-LinkedDeck-WithCards Returns a LinkedDeck with the appropriate values" {
        
        IT "New-Object-LinkedDeck-WithCards Returns a LinkedDeck object" {
            ( $PSCO_LinkedDeck1 | New-Object-LinkedDeck-WithCards ).GetType().Name | Should Be 'LinkedDeck' }
    
        IT "New-Object-LinkedDeck-Default Cards[0].CardText[0] is $($CardText1[0])" {
            ( $PSCO_LinkedDeck1 | New-Object-LinkedDeck-WithCards ).Cards[0].CardText[0] | Should Be $CardText1[0] }

        IT "New-Object-LinkedDeck-Default Cards[1].CardText[0] is $($CardText2[0])" {
            ( $PSCO_LinkedDeck1 | New-Object-LinkedDeck-WithCards ).Cards[1].CardText[0] | Should Be $CardText2[0] }

    } <#END CONTEXT "New-Object-LinkedDeck-WithCards Returns a LinkedDeck with the appropriate values"#>

    IT "There are tests for New-Object-LinkedDeck-WithInstructor and New-Object-LinkedDeck-WithCardsAndInstructor" {$false | Should Be $True}

    CONTEXT "LinkedDeck functionality" {
        
        IT "LinkedDeck.ActivateDeck()[0] | SHOULD BE $CardTitle1" {( $PSCO_LinkedDeck1 | New-Object-LinkedDeck-WithCards ).ActivateDeck()[0] | SHOULD BE $CardTitle1}

        IT "LinkedDeck.ActivateDeck()[1] | SHOULD BE $CardType1" {( $PSCO_LinkedDeck1 | New-Object-LinkedDeck-WithCards ).ActivateDeck()[1] | SHOULD BE $CardTitle1}

        IT "LinkedDeck.ActivateDeck()[2] | SHOULD BE $CardTitle2" {( $PSCO_LinkedDeck1 | New-Object-LinkedDeck-WithCards ).ActivateDeck()[2] | SHOULD BE $CardTitle2}

        IT "LinkedDeck.ActivateDeck()[3] | SHOULD BE $CardType2" {( $PSCO_LinkedDeck1 | New-Object-LinkedDeck-WithCards ).ActivateDeck()[3] | SHOULD BE $CardType2}

        It "There are LinkedBack functionality tests for all the methods" {$false | Should Be $true}

    }

}<#End Describe Class LinkedDeck#>

#
#<#I think Lumberjack.filterbytags supercedes these#>
#$ItLjHasTag = {param([lumberjack]$lj,[string]$tag) 
#    It "Lumberjack.Logs.Tags -contains $tag | Should Be $true} " {
#        $lj.Logs.Tags -contains $tag | Should Be $true}
#}
#$ItLjHasNoTag = {param([lumberjack]$lj,[string]$tag) 
#    It "Lumberjack.Logs.Tags -contains $tag | Should Not Be $true} " {
#        $lj.Logs.Tags -contains $tag | Should Not Be $true}
#}
#
#Describe "Base Class CardContainer" {
#    BeforeAll {
#        [String]$Name1='Bob'
#        [String]$Name2='Sue'
#        [ScriptBlock[]]$AfterReceiveCardScripts=@({$this.Name})
#        [ScriptBlock[]]$AfterClearCardScripts=@({$this.Name = "Alfred"})
#
#        $PSCO_CardContainer1 = @{
#            Name=$Name1;
#            AfterReceiveCardScripts=$AfterReceiveCardScripts;
#            AfterClearCardScripts=$AfterClearCardScripts
#        }
#
#        $PSCO_CardContainer2 = @{
#            Name=$Name2;
#            AfterReceiveCardScripts=$AfterReceiveCardScripts;
#            AfterClearCardScripts=$AfterClearCardScripts
#        }
#
#        Write-Verbose -Verbose 'Echoing PSCO_CardContainer1'
#        $PSCO_CardContainer1 | Write-Verbose -Verbose
#
#        Write-Verbose -Verbose 'Echoing PSCO_CardContainer2'
#        $PSCO_CardContainer2 | Write-Verbose -Verbose
#
#        [String[]]$CardText = @("Card Text Line 1","Card Text Line 2 With`r`ncarriage return and newline.")
#        [String]$CardTitle='My Test Card'
#        [GameSet]$CardGameSet=[GameSet]::BranchAndClaw
#        [CardType]$CardType=[CardType]::Fear
#        [ScriptBlock[]]$OnPlayScripts=@({Return 'OnPlayScripts1'},{$this | out-string | write-verbose -Verbose; Return $this.CardType})
#        [ScriptBlock[]]$OnDiscardScripts=@({Return 'OnDiscardScripts1'})
#
#        $PSCO_Card = [PSCustomObject]@{
#            CardText=$CardText;
#            CardTitle=$CardTitle;
#            CardGameSet=$CardGameSet;
#            CardType=$CardType;
#            OnPlayScripts=$OnPlayScripts;
#            OnDiscardScripts=$OnDiscardScripts
#            }
#        Write-Verbose -Verbose 'Echoing PSCO_Card'
#        $PSCO_Card | Write-Verbose -Verbose
#
#    }
#
#    Context "Class Basics" {
#        BeforeAll {
#            $obj = [CardContainer]::NEW()
#            $classname = 'CardContainer'
#        }
#
#        $Properties = @(
#             'String Name'
#            ,'Card[] Cards'
#            ,'ScriptBlock[] AfterReceiveCardScripts'
#            ,'ScriptBlock[] AfterClearCardScripts'
#            ,'Ref Parent'
#            ,'Ref CardContainerToDrawFrom'
#            ,'Ref Self'
#            ,'Lumberjack lj'
#        )
#        $Methods = @(
#            ,'DrawCard'
#            ,'RelinquishCard'
#            ,'ReceiveCard'
#            ,'AfterReceiveCard'
#            ,'ClearCard'
#            ,'AfterClearCard'
#            ,'GetSelfRef'
#        )
#
##region run basic tests
#        $ActualProperties = $obj | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty @{name='nameAndType';expression={$_.name + ' - ' + $_.TypeName}}
#        $ActualMethods = $obj | Get-Member -MemberType Method | Select-Object -ExpandProperty name 
#        foreach ($p in $Properties) {
#            IT "Class $classname should have property $p" {
#                $ActualProperties -contains $p | SHOULD BE $true }
#        }<#End Foreach Properties#>
#
#        foreach ($m in $Methods) {
#            IT "Class $classname should have method $m" {
#                $ActualMethods -contains $m | SHOULD BE $true }
#        }<#End Foreach Properties#>
##endregion run basic tests
#
#    }<#END CONTEXT Class Basics#>
#
#    CONTEXT "New-Object-CardContainer-Default Returns a card container with the appropriate values" {
#        
#        IT "New-Object-CardContainer-Default returns a CardContainer object" {
#            ( $PSCO_CardContainer1 | New-Object-CardContainer-Default ).GetType().Name | Should Be 'CardContainer' }
#
#        IT "New-Object-CardContainer-Default Name is $($Name1)" {
#            ( $PSCO_CardContainer1 | New-Object-CardContainer-Default ).Name | Should Be $Name1 }
#
#    } <# END CONTEXT "New-Object-Card-Default Returns a card with the appropriate values" #>
#
#    CONTEXT "CardContainer Functionality - DrawCard()" {
#        BeforeAll{
#            $cc = $PSCO_CardContainer1 | New-Object-CardContainer-Default
#            $cc2 = $PSCO_CardContainer2 | New-Object-CardContainer-Default
#            $cc2.ReceiveCard( $( $PSCO_Card | New-Object-Card-Default ) )
#            $cc.CardContainerToDrawFrom = $cc2.GetSelfRef()
#        } <# END BeforeAll #>
#        IT "Before, cc.lj.FilterBYTags(@('ReceiveCard')).Count | Should Be 0" {
#            $cc.lj.FilterBYTags(@('ReceiveCard')).Count | Should Be 0}
#        
#        IT "Before, cc.CardContainerToDrawFrom.Value.lj.FilterByTags(@('RelinquishCard')).Count | SHOULD BE 0" {
#            $cc.CardContainerToDrawFrom.Value.lj.FilterByTags(@('RelinquishCard')).Count | SHOULD BE 0}
#
#        IT "After, cc.lj.FilterBYTags(@('ReceiveCard')).Count | Should Be 1" {
#            $cc.DrawCard()
#            $cc.lj.FilterBYTags(@('ReceiveCard')).Count | Should Be 1}
#        
#        IT "After, cc.CardContainerToDrawFrom.Value.lj.FilterByTags(@('RelinquishCard')).Count | SHOULD BE 1" {
#            $cc.CardContainerToDrawFrom.Value.lj.FilterByTags(@('RelinquishCard')).Count | SHOULD BE 1}
#    } <# END CONTEXT "CardContainer Functionality - DrawCard()" #>
#
#    CONTEXT "CardContainer Functionality - RelinquishCard()" {
#        BeforeAll{
#            $cc = $PSCO_CardContainer1 | New-Object-CardContainer-Default
#            $cc2 = $PSCO_CardContainer2 | New-Object-CardContainer-Default
#            $cc1.ReceiveCard( $( $PSCO_Card | New-Object-Card-Default ) )
#            $cc.CardContainerToDrawFrom = $cc2.GetSelfRef()
#
#        } <# END BeforeAll #>
#        IT "Before, cc.lj.FilterBYTags(@('RelinquishCard')).Count | Should Be 0" {
#            $cc.lj.FilterBYTags(@('RelinquishCard')).Count | Should Be 0}
#
#        IT "Before, cc.lj.FilterBYTags(@('ClearCard')).Count | Should Be 0" {
#            $cc.lj.FilterBYTags(@('ClearCard')).Count | Should Be 0}
#        
#        IT "cc.ReliquishCard().GetType()"
#
#        IT "After, cc.lj.FilterBYTags(@('ReceiveCard')).Count | Should Be 1" {
#            $cc.RelinquishCard()
#            $cc.lj.FilterBYTags(@('ReceiveCard')).Count | Should Be 1}
#        
#        IT "After, cc.CardContainerToDrawFrom.Value.lj.FilterByTags(@('RelinquishCard')).Count | SHOULD BE 1" {
#            $cc.CardContainerToDrawFrom.Value.lj.FilterByTags(@('RelinquishCard')).Count | SHOULD BE 1}
#    } <# END CONTEXT "CardContainer Functionality - RelinquishCard()" #>
#
#} <#END Describe "Base Class CardContainer" #>
#
#Describe "Class Deck" {
#    Context "Class Basics" {
#        BeforeAll {
#            $obj = [Deck]::NEW()
#            $classname = 'Deck'
#        }
#
#        It "$classname.GetType().BaseType | Should Be 'CardContainer'" {
#            $obj.GetType().BaseType | Should Be 'CardContainer' }
#
#        $Properties = @(
#            'Card[] Cards'
#            ,'ScriptBlock[] OnEmptyScripts'
#        )
#        $Methods = @(
#            'GetFromTop'
#            ,'GetFromBottom'
#            ,'PutOnTop'
#            ,'PutOnBottom'
#            ,'InsertAtPosition'
#            ,'Shuffle'
#            ,'RunOnEmptyScripts'
#        )
#
##region run basic tests
#        $ActualProperties = $obj | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty @{name='nameAndType';expression={$_.name + ' - ' + $_.TypeName}}
#        $ActualMethods = $obj | Get-Member -MemberType Method | Select-Object -ExpandProperty name 
#        foreach ($p in $Properties) {
#            IT "Class $classname should have property $p" {
#                $ActualProperties -contains $p | SHOULD BE $true }
#        }<#End Foreach Properties#>
#
#        foreach ($m in $Methods) {
#            IT "Class $classname should have method $m" {
#                $ActualMethods -contains $m | SHOULD BE $true }
#        }<#End Foreach Properties#>
##endregion run basic tests
#
#    }<#END CONTEXT Class Basics#>
#}<#End Describe Class Deck#>
#
#Describe "Class CardRegister" {
#    Context "Class Basics" {
#        BeforeAll {
#            $obj = [CardRegister]::NEW()
#            $classname = 'CardRegister'
#        }
#        
#        It "$classname.GetType().BaseType | Should Be 'CardContainer'" {
#            $obj.GetType().BaseType | Should Be 'CardContainer' }
#
#        $Properties = @(
#             'CardType CardType'
#            ,'Instructor Instructor'
#        )
#        $Methods = @(
#             'ActivateRegisteredCard'
#            ,'PrintInstructions'
#        )
#
##region run basic tests
#        $ActualProperties = $obj | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty @{name='nameAndType';expression={$_.name + ' - ' + $_.TypeName}}
#        $ActualMethods = $obj | Get-Member -MemberType Method | Select-Object -ExpandProperty name 
#        foreach ($p in $Properties) {
#            IT "Class $classname should have property $p" {
#                $ActualProperties -contains $p | SHOULD BE $true }
#        }<#End Foreach Properties#>
#
#        foreach ($m in $Methods) {
#            IT "Class $classname should have method $m" {
#                $ActualMethods -contains $m | SHOULD BE $true }
#        }<#End Foreach Properties#>
##endregion run basic tests
#
#    }<#END CONTEXT Class Basics#>
#}<#End Describe CardRegister#>
#
#
#
##InvaderCardRegister subclass deemed unnecessary
#<#
#Describe "Class InvaderCardRegister" {
#    Context "Class Basics" {
#        BeforeAll {
#            $obj = [InvaderCardRegister]::NEW()
#            $classname = 'InvaderCardRegister'
#        }
#        
#        It "$classname.GetType().BaseType | Should Be 'CardRegister'" {
#            $obj.GetType().BaseType | Should Be 'CardRegister' }
#
#        $Properties = @(
#             'String[] Instructions'
#            ,'String[] InstructionsAddendum'
#            ,'String[][] StackOfInstructionsByTurn'
#            ,'String[] InstructionsForUpcomingTurn'
#        )
#        $Methods = @(
#             'ActivateRegister'
#            ,'PrintInstructions'
#        )
#
##region run basic tests
#        $ActualProperties = $obj | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty @{name='nameAndType';expression={$_.name + ' - ' + $_.TypeName}}
#        $ActualMethods = $obj | Get-Member -MemberType Method | Select-Object -ExpandProperty name 
#        foreach ($p in $Properties) {
#            IT "Class $classname should have property $p" {
#                $ActualProperties -contains $p | SHOULD BE $true }
#        }<#End Foreach Properties# >
#
#        foreach ($m in $Methods) {
#            IT "Class $classname should have method $m" {
#                $ActualMethods -contains $m | SHOULD BE $true }
#        }<#End Foreach Properties# >
##endregion run basic tests
#
#    }<#END CONTEXT Class Basics# >
#}<#End Describe InvaderCardRegister# >
##>
#
#