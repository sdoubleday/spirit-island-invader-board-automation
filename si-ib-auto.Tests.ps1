<#SDS Modified Pester Test file header to handle modules.#>
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = ( (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.' ) -replace '.ps1', '.psd1'
$scriptBody = "using module $here\$sut"
$script = [ScriptBlock]::Create($scriptBody)
. $script

Describe "Base Class CardContainer" {
    Context "Class Basics" {
        BeforeAll {
            $obj = [CardContainer]::NEW()
            $classname = 'CardContainer'
        }

        $Properties = @(
             'Card CurrentCard'
            ,'Ref Parent'
            ,'Ref CardContainerToDrawFrom'
            ,'Ref Self'
            ,'Lumberjack lj'
        )
        $Methods = @(
            ,'DrawCard'
            ,'RelinquishCard'
            ,'ReceiveCard'
            ,'ClearCard'
            ,'AfterClearCard'
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
} <#END Describe "Base Class CardContainer" #>

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
        [GameSet]$CardGameSet=[GameSet]::Core
        [CardType]$CardType=[CardType]::Fear
        [ScriptBlock[]]$OnPlayScripts=@({Return 'OnPlayScripts1'},{Return $this.CardType})
        [ScriptBlock[]]$OnDiscardScripts=@({Return 'OnDiscardScripts1'})

        $PSCO_Card = [PSCustomObject]@{
            CardText=$CardText;
            CardTitle=$CardTitle;
            GameSet=$CardGameSet;
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

        IT "New-Object-Card-Default CardText[0] is $($CardText[0])" {
            ( $PSCO_Card | New-Object-Card-Default ).CardText[0] | Should Be $CardText[0] }

        IT "New-Object-Card-Default CardText[1] is $($CardText[1])" {
            ( $PSCO_Card | New-Object-Card-Default ).CardText[0] | Should Be $CardText[1] }

        IT "New-Object-Card-Default CardTitle is $($CardTitle)" {
            ( $PSCO_Card | New-Object-Card-Default ).CardTitle | Should Be $CardTitle }

        IT "New-Object-Card-Default GameSet is $($GameSet)" {
            ( $PSCO_Card | New-Object-Card-Default ).GameSet | Should Be $GameSet }

        IT "New-Object-Card-Default CardType is $($CardType)" {
            ( $PSCO_Card | New-Object-Card-Default ).CardType | Should Be CardType }

        IT "New-Object-Card-Default Invoke-Command OnPlayScripts[0] is 'OnPlayScripts1'" {
            Invoke-Command ( $PSCO_Card | New-Object-Card-Default ).OnPlayScripts[0] | Should Be 'OnPlayScripts1' }

        IT "New-Object-Card-Default Invoke-Command OnPlayScripts[1] is '$CardType'" {
            Invoke-Command ( $PSCO_Card | New-Object-Card-Default ).OnPlayScripts[1] | Should Be $CardType }

        IT "New-Object-Card-Default Invoke-Command OnDiscardScripts[0] is 'OnDiscardScripts1'" {
            Invoke-Command ( $PSCO_Card | New-Object-Card-Default ).OnDiscardScripts[0] | Should Be 'OnDiscardScripts1' }
        
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

Describe "Class Deck" {
    Context "Class Basics" {
        BeforeAll {
            $obj = [Deck]::NEW()
            $classname = 'Deck'
        }

        It "$classname.GetType().BaseType | Should Be 'CardContainer'" {
            $obj.GetType().BaseType | Should Be 'CardContainer' }

        $Properties = @(
            'Card[] Cards'
            ,'ScriptBlock[] OnEmptyScripts'
        )
        $Methods = @(
            'GetFromTop'
            ,'GetFromBottom'
            ,'PutOnTop'
            ,'PutOnBottom'
            ,'InsertAtPosition'
            ,'Shuffle'
            ,'RunOnEmptyScripts'
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
}<#End Describe Class Deck#>

Describe "Class CardRegister" {
    Context "Class Basics" {
        BeforeAll {
            $obj = [CardRegister]::NEW()
            $classname = 'CardRegister'
        }
        
        It "$classname.GetType().BaseType | Should Be 'CardContainer'" {
            $obj.GetType().BaseType | Should Be 'CardContainer' }

        $Properties = @(
             'String RegisterName'
            ,'CardType CardType'
            ,'String[] Instructions'
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

    }<#END CONTEXT Class Basics#>
}<#End Describe CardRegister#>



#InvaderCardRegister subclass deemed unnecessary
<#
Describe "Class InvaderCardRegister" {
    Context "Class Basics" {
        BeforeAll {
            $obj = [InvaderCardRegister]::NEW()
            $classname = 'InvaderCardRegister'
        }
        
        It "$classname.GetType().BaseType | Should Be 'CardRegister'" {
            $obj.GetType().BaseType | Should Be 'CardRegister' }

        $Properties = @(
             'String[] Instructions'
            ,'String[] InstructionsAddendum'
            ,'String[][] StackOfInstructionsByTurn'
            ,'String[] InstructionsForUpcomingTurn'
        )
        $Methods = @(
             'ActivateRegister'
            ,'PrintInstructions'
        )

#region run basic tests
        $ActualProperties = $obj | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty @{name='nameAndType';expression={$_.name + ' - ' + $_.TypeName}}
        $ActualMethods = $obj | Get-Member -MemberType Method | Select-Object -ExpandProperty name 
        foreach ($p in $Properties) {
            IT "Class $classname should have property $p" {
                $ActualProperties -contains $p | SHOULD BE $true }
        }<#End Foreach Properties# >

        foreach ($m in $Methods) {
            IT "Class $classname should have method $m" {
                $ActualMethods -contains $m | SHOULD BE $true }
        }<#End Foreach Properties# >
#endregion run basic tests

    }<#END CONTEXT Class Basics# >
}<#End Describe InvaderCardRegister# >
#>

