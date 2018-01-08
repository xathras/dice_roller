module Update exposing (update)

import Commands exposing (..)
import Models exposing (Model, StatList, DiceCalculator, Combat, Combatant)
import Msgs exposing (Msg)
import Routing exposing (parseLocation)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msgs.OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )

        Msgs.ChangeNumber newVal ->
            let
                newCalc =
                    model.calculator
                        |> updateDiceNumber newVal
            in
                ( { model | calculator = newCalc }, Cmd.none )

        Msgs.ChangeSides newVal ->
            let
                newCalc =
                    model.calculator |> updateDiceSides newVal
            in
                ( { model | calculator = newCalc }, Cmd.none )

        Msgs.ChangeModifier newVal ->
            let
                newCalc =
                    model.calculator |> updateDiceModifier newVal
            in
                ( { model | calculator = newCalc }, Cmd.none )

        Msgs.RollDice ->
            ( model, rollDice model.calculator )

        Msgs.Rolled (Ok output) ->
            let
                newCalc =
                    model.calculator |> updateDiceOutput output
            in
                ( { model | calculator = newCalc }, Cmd.none )

        Msgs.Rolled (Err _) ->
            ( model, Cmd.none )

        Msgs.RollStats ->
            ( model, rollStats )

        Msgs.StatsRolled (Ok output) ->
            ( { model | stats = output }, Cmd.none )

        Msgs.StatsRolled (Err _) ->
            ( model, Cmd.none )

        Msgs.AddCombatant ->
            let
                newCombat =
                    model.combat |> addCombatant |> resetCombatantForm
            in
                ( { model | combat = newCombat }, Cmd.none )

        Msgs.ChangeName newName ->
            let
                newCombatant =
                    model.combat
                        |> .newCombatant
                        |> updateCombatantName newName

                newCombat =
                    updateCombatantForm model.combat newCombatant
            in
                ( { model | combat = newCombat }, Cmd.none )

        Msgs.ChangeInitiative newInitiative ->
            let
                newCombatant =
                    model.combat
                        |> .newCombatant
                        |> updateCombatantInitiative newInitiative

                newCombat =
                    updateCombatantForm model.combat newCombatant
            in
                ( { model | combat = newCombat }, Cmd.none )

        Msgs.NextCombatant ->
            let
                newCombat =
                    model.combat |> nextCombatant
            in
                ( { model | combat = newCombat }, Cmd.none )


updateDiceNumber : Int -> DiceCalculator -> DiceCalculator
updateDiceNumber newVal calc =
    { calc | number = newVal }


updateDiceSides : Int -> DiceCalculator -> DiceCalculator
updateDiceSides newVal calc =
    { calc | sides = newVal }


updateDiceModifier : Int -> DiceCalculator -> DiceCalculator
updateDiceModifier newVal calc =
    { calc | modifier = newVal }


updateDiceOutput : String -> DiceCalculator -> DiceCalculator
updateDiceOutput newVal calc =
    { calc | output = newVal }


addCombatant : Combat -> Combat
addCombatant model =
    let
        newCombatants =
            List.append model.combatants [ model.newCombatant ]
                |> List.sortBy (\c -> c.initiative)
                |> List.reverse
    in
        { model | combatants = newCombatants }


resetCombatantForm : Combat -> Combat
resetCombatantForm model =
    { model | newCombatant = Models.initialCombatant }


updateCombatantForm : Combat -> Combatant -> Combat
updateCombatantForm model combatant =
    { model | newCombatant = combatant }


updateCombatantName : String -> Combatant -> Combatant
updateCombatantName newName model =
    { model | name = newName }


updateCombatantInitiative : Int -> Combatant -> Combatant
updateCombatantInitiative newInitiative model =
    { model | initiative = newInitiative }


nextCombatant : Combat -> Combat
nextCombatant model =
    let
        roundNumber =
            if model.currentCombatantIdx < ((List.length model.combatants) - 1) then
                model.rounds
            else
                model.rounds + 1

        newIdx =
            if model.currentCombatantIdx < ((List.length model.combatants) - 1) then
                model.currentCombatantIdx + 1
            else
                0
    in
        { model | rounds = roundNumber, currentCombatantIdx = newIdx }
