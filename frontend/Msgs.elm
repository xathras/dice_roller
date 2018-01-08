module Msgs exposing (..)

import Http
import Models exposing (StatList)
import Navigation exposing (Location)


type Msg
    = OnLocationChange Location
    | ChangeNumber Int
    | ChangeSides Int
    | ChangeModifier Int
    | RollDice
    | Rolled (Result Http.Error String)
    | RollStats
    | StatsRolled (Result Http.Error (List Int))
    | AddCombatant
    | ChangeName String
    | ChangeInitiative Int
    | NextCombatant
