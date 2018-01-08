module Routing exposing (..)

import Navigation exposing (Location)
import Models exposing (Route(..))
import UrlParser exposing (..)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map HomeRoute top
        , map RollerRoute (s "calc")
        , map CombatRoute (s "combat")
        , map StatListRoute (s "stat-list")
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


calculatorPath : String
calculatorPath =
    "#calc"


combatPath : String
combatPath =
    "#combat"


statListPath : String
statListPath =
    "#stat-list"
