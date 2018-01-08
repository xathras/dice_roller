module Models exposing (..)

-- import RemoteData exposing (WebData)


type alias Model =
    { route : Route
    , calculator : DiceCalculator
    , stats : StatList
    , combat : Combat
    }


type alias StatList =
    List Int


type alias DiceCalculator =
    { number : Int
    , sides : Int
    , modifier : Int
    , output : String
    }


type alias Combat =
    { combatants : List Combatant
    , newCombatant : Combatant
    , currentCombatantIdx : Int
    , rounds : Int
    }


type alias Combatant =
    { name : String
    , initiative : Int
    }


type alias NavigationItem =
    { route : Route
    , path : String
    , label : String
    }


initialModel : Route -> Model
initialModel route =
    { route = route
    , calculator = initialDiceCalculator
    , stats = []
    , combat = initialCombat
    }


initialDiceCalculator : DiceCalculator
initialDiceCalculator =
    DiceCalculator 1 6 0 ""


initialCombatant : Combatant
initialCombatant =
    Combatant "" 0


initialCombat : Combat
initialCombat =
    Combat [] initialCombatant 0 0


type Route
    = HomeRoute
    | NotFoundRoute
    | RollerRoute
    | CombatRoute
    | StatListRoute
