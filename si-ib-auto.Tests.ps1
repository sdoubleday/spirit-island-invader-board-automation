<#SDS Modified Pester Test file header to handle modules.#>
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = ( (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.' ) -replace '.ps1', '.psd1'
$scriptBody = "using module $here\$sut"
$script = [ScriptBlock]::Create($scriptBody)
. $script


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
            ,'InvaderCardRegister[] InvaderActionRegistry'
            ,'Deck EventDeck'
            ,'CardRegister EventRegister'
            ,'Deck EventDiscard'
            ,'TurnPhase[] TurnOrder'
            ,'Int32 TurnNumber'
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

    CONTEXT "New-Object-Card Returns a card with the appropriate values" {
        
        IT "New-Object-Card returns a Card object" {
            ( $PSCO_Card | New-Object-Card ).GetType().Name | Should Be 'Card' }

        IT "New-Object-Card CardText[0] is $($CardText[0])" {
            ( $PSCO_Card | New-Object-Card ).CardText[0] | Should Be $CardText[0] }

        IT "New-Object-Card CardText[1] is $($CardText[1])" {
            ( $PSCO_Card | New-Object-Card ).CardText[0] | Should Be $CardText[1] }

        IT "New-Object-Card CardTitle is $($CardTitle)" {
            ( $PSCO_Card | New-Object-Card ).CardTitle | Should Be $CardTitle }

        IT "New-Object-Card GameSet is $($GameSet)" {
            ( $PSCO_Card | New-Object-Card ).GameSet | Should Be $GameSet }

        IT "New-Object-Card CardType is $($CardType)" {
            ( $PSCO_Card | New-Object-Card ).CardType | Should Be CardType }

        IT "New-Object-Card Invoke-Command OnPlayScripts[0] is 'OnPlayScripts1'" {
            Invoke-Command ( $PSCO_Card | New-Object-Card ).OnPlayScripts[0] | Should Be 'OnPlayScripts1' }

        IT "New-Object-Card Invoke-Command OnPlayScripts[1] is '$CardType'" {
            Invoke-Command ( $PSCO_Card | New-Object-Card ).OnPlayScripts[1] | Should Be $CardType }

        IT "New-Object-Card Invoke-Command OnDiscardScripts[0] is 'OnDiscardScripts1'" {
            Invoke-Command ( $PSCO_Card | New-Object-Card ).OnDiscardScripts[0] | Should Be 'OnDiscardScripts1' }
        
    } <#END CONTEXT "New-Object-Card Returns a card with the appropriate values"#>
    
    CONTEXT "Card functionality" {
        
        IT  {}

    }

}<#End Describe Class Card#>

Describe "Class Deck" {
    Context "Class Basics" {
        BeforeAll {
            $obj = [Deck]::NEW()
            $classname = 'Deck'
        }

        $Properties = @(
            'Card[] Cards'
            ,'Ref Parent'
        )
        $Methods = @(
            'DrawFromTop'
            ,'DrawFromBottom'
            ,'PlaceOnTop'
            ,'PlaceOnBottom'
            ,'InsertAtPosition'
            ,'Shuffle'
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

Describe "Class InvaderCardRegister" {
    Context "Class Basics" {
        BeforeAll {
            $obj = [InvaderCardRegister]::NEW()
            $classname = 'InvaderCardRegister'
        }

        $Properties = @(
            'Card Card'
            ,'String[] Instructions'
            ,'String[] InstructionsAddendum'
            ,'String[][] StackOfInstructionsByTurn'
            ,'String[] InstructionsForUpcomingTurn'
            ,'Ref Parent'
        )
        $Methods = @(
            'ActivateRegister'
            ,'PrintInstructions'
            ,'PassCard'
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
}<#End Describe InvaderCardRegister#>

Describe "Class CardRegister" {
    Context "Class Basics" {
        BeforeAll {
            $obj = [CardRegister]::NEW()
            $classname = 'CardRegister'
        }

        $Properties = @(
            'Card Card'
            ,'Ref Parent'
        )
        $Methods = @(
            'ActivateRegister'
            ,'PrintInstructions'
            ,'PassCard'
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



