module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Bootstrap as BS
import Models exposing (Model)
import Msgs exposing (Msg)
import Routing exposing (combatPath, statListPath, calculatorPath)
import Html.Events exposing (..)
import Html.Events.Extra exposing (targetValueIntParse)
import Json.Decode as Decode


view : Model -> Html Msg
view model =
    div []
        [ (navbar model), page model ]


page : Model -> Html Msg
page model =
    case model.route of
        Models.HomeRoute ->
            indexPage

        Models.RollerRoute ->
            calculatorPage model.calculator

        Models.CombatRoute ->
            combatPage model.combat

        Models.StatListRoute ->
            statGeneratorView model.stats

        Models.NotFoundRoute ->
            div [] []


navbar : Model -> Html Msg
navbar model =
    let
        navItems =
            [ Models.NavigationItem Models.RollerRoute calculatorPath "Dice Calculator"
            , Models.NavigationItem Models.StatListRoute statListPath "Stat Generator"
            , Models.NavigationItem Models.CombatRoute combatPath "Combat Manager"
            ]
    in
        header [ class "navbar navbar-expand-lg navbar-light bg-light" ]
            [ a [ class "navbar-brand", href "#" ] [ text "D&D Tools" ]
            , div
                [ class "collapse navbar-collapse" ]
                [ ul [ class "navbar-nav mr-auto" ]
                    (List.map (navItem model.route) navItems)
                ]
            ]


navItem : Models.Route -> Models.NavigationItem -> Html Msg
navItem currentRoute item =
    let
        current =
            currentRoute == item.route
    in
        li [ classList [ ( "nav-item", True ), ( "active", current ) ] ]
            [ a [ class "nav-link", href item.path ] [ text item.label ]
            ]


indexPage : Html Msg
indexPage =
    div [] []


calculatorPage : Models.DiceCalculator -> Html Msg
calculatorPage model =
    div [ class "container" ]
        [ BS.row [] [ BS.col_12 [] [ h1 [] [ text "Dice Roller" ] ] ]
        , BS.row []
            [ div [ class "col-2" ]
                [ input
                    [ type_ "text"
                    , class "form-control"
                    , placeholder "Enter number of dice"
                    , value (toString model.number)
                    , on "input" (Decode.map Msgs.ChangeNumber targetValueIntParse)
                    ]
                    []
                ]
            , div [ class "col-4" ]
                [ div [ class "btn-group btn-group-lg btn-group-toggle", attribute "data-toggle" "buttons" ]
                    (List.map (sidesOption model.sides) [ 4, 6, 8, 10, 12, 20 ])
                ]
            , div [ class "col-6" ]
                [ div [ class "input-group" ]
                    [ span [ class "input-group-addon" ] [ text "+" ]
                    , input
                        [ type_ "text"
                        , class "form-control"
                        , placeholder "Enter any additional modifier"
                        , value (toString model.modifier)
                        , on "input" (Decode.map Msgs.ChangeModifier targetValueIntParse)
                        ]
                        []
                    , span [ class "input-group-btn" ] [ button [ class "btn btn-primary", onClick Msgs.RollDice ] [ text "Roll!" ] ]
                    ]
                ]
            ]
        , BS.row [] [ BS.col_12 [] [ text model.output ] ]
        ]


sidesOption : Int -> Int -> Html Msg
sidesOption currentSelection numSides =
    let
        active =
            currentSelection == numSides

        msg =
            (Decode.map Msgs.ChangeSides targetValueIntParse)
    in
        label [ classList [ ( "btn btn-secondary", True ), ( "active", active ) ] ]
            [ input [ type_ "radio", name "diceType", value (toString numSides), checked active, on "change" msg, attribute "autocomplete" "off" ] []
            , text (toString numSides)
            ]


statGeneratorView : Models.StatList -> Html Msg
statGeneratorView model =
    div [ class "container" ]
        [ BS.row [] [ BS.col_12 [] [ h1 [] [ text "Stat List" ] ] ]
        , BS.row []
            [ div [ class "input-group" ]
                [ select [ class "form-control" ] [ option [] [ text "Class Name" ] ]
                , span [ class "input-group-btn" ] [ button [ class "btn btn-primary", onClick Msgs.RollStats ] [ text "Roll Stats" ] ]
                ]
            ]
        , BS.row [] [ statListing model ]
        ]


statListing : Models.StatList -> Html Msg
statListing statList =
    let
        headings =
            thead [ class "thead-light" ]
                [ tr []
                    [ th [] [ text "Stat Value" ]
                    , th [] [ text "Stat Modifier" ]
                    ]
                ]

        listItems =
            List.map statListItem statList
    in
        table [ class "table table-hover table-sm" ] [ headings, tbody [] listItems ]


statListItem : Int -> Html Msg
statListItem statValue =
    tr []
        [ td [] [ text (toString statValue) ]
        , td [] [ text ("+" ++ (toString (calculateModifier statValue))) ]
        ]


calculateModifier : Int -> Int
calculateModifier statValue =
    (statValue - 10) // 2


classStatPriorityHeaders : String -> List String
classStatPriorityHeaders className =
    case className of
        "ranger" ->
            [ "Dex", "Wis", "Str", "Con", "Chr", "Int" ]

        "paladin" ->
            [ "Str", "Chr", "Con", "Dex", "Wis", "Int" ]

        "wizard" ->
            [ "Int", "Con", "Dex", "Wis", "Chr", "Str" ]

        _ ->
            []


combatPage : Models.Combat -> Html Msg
combatPage model =
    div [ class "container" ]
        [ BS.row [] [ BS.col_12 [] [ h1 [] [ text "Combat Manager" ] ] ]
        , BS.row []
            [ div [ class "col-6" ]
                [ div [ class "input-group" ]
                    [ input
                        [ class "form-control"
                        , value (toString model.newCombatant.initiative)
                        , type_ "number"
                        , on "input" (Decode.map Msgs.ChangeInitiative targetValueIntParse)
                        ]
                        []
                    ]
                ]
            , div [ class "col-6" ]
                [ div [ class "input-group" ]
                    [ input [ class "form-control", value model.newCombatant.name, onInput Msgs.ChangeName ] []
                    , span [ class "input-group-btn" ] [ button [ class "btn btn-primary", onClick Msgs.AddCombatant ] [ text "Add Combatant" ] ]
                    ]
                ]
            ]
        , BS.row [] [ div [ class "col-12" ] [ hr [] [] ] ]
        , BS.row []
            [ div [ class "col-10" ] [ text (toString model.rounds) ]
            , div [ class "col-2" ] [ button [ class "btn btn-info", onClick Msgs.NextCombatant ] [ text "Next" ] ]
            ]
        , BS.row []
            [ div [ class "col-12" ] [ ul [ class "list-group" ] (List.indexedMap (showCombatant model.currentCombatantIdx) model.combatants) ]
            ]
        ]


showCombatant : Int -> Int -> Models.Combatant -> Html Msg
showCombatant currentIdx idx combatant =
    li [ classList [ ( "list-group-item", True ), ( "active", currentIdx == idx ) ] ] [ text combatant.name ]
