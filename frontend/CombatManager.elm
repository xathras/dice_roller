module CombatManager exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events.Extra exposing (targetValueIntParse)
import Http
import Json.Decode as Decode
import List


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { combatants : List Combatant
    , blankCombatant : Combatant
    , currentCombatantIdx : Int
    , rounds : Int
    }


type alias Combatant =
    { name : String
    , initiative : Int
    }


init : ( Model, Cmd Msg )
init =
    ( Model [] (Combatant "" 0) 0 0, Cmd.none )



-- UPDATE


type Msg
    = AddCombatant
    | ChangeName String
    | ChangeInitiative Int
    | NextCombatant


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddCombatant ->
            let
                newModel =
                    model
                        |> addCombatant
                        |> resetForm
            in
                ( newModel, Cmd.none )

        ChangeName newName ->
            let
                newCombatant =
                    model.blankCombatant |> updateCombatantName newName
            in
                ( { model | blankCombatant = newCombatant }, Cmd.none )

        ChangeInitiative newInitiative ->
            let
                newCombatant =
                    model.blankCombatant |> updateCombatantInitiative newInitiative
            in
                ( { model | blankCombatant = newCombatant }, Cmd.none )

        NextCombatant ->
            let
                newModel =
                    model |> nextCombatant
            in
                ( newModel, Cmd.none )


addCombatant : Model -> Model
addCombatant model =
    let
        newCombatants =
            List.append model.combatants [ model.blankCombatant ]
                |> List.sortBy (\c -> c.initiative)
                |> List.reverse
    in
        { model | combatants = newCombatants }


resetForm : Model -> Model
resetForm model =
    { model | blankCombatant = (Combatant "" 0) }


updateCombatantName : String -> Combatant -> Combatant
updateCombatantName newName model =
    { model | name = newName }


updateCombatantInitiative : Int -> Combatant -> Combatant
updateCombatantInitiative newInitiative model =
    { model | initiative = newInitiative }


nextCombatant : Model -> Model
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



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "row" ] [ h1 [] [ text "Combat Manager" ] ]
        , div [ class "row" ]
            [ div [ class "input-group" ]
                [ input
                    [ class "form-control"
                    , value (toString model.blankCombatant.initiative)
                    , on "input" (Decode.map ChangeInitiative targetValueIntParse)
                    ]
                    []
                ]
            , div [ class "input-group" ]
                [ input [ class "form-control", value model.blankCombatant.name, onInput ChangeName ] []
                , span [ class "input-group-btn" ] [ button [ class "btn btn-primary", onClick AddCombatant ] [ text "Add Combatant" ] ]
                ]
            ]
        , div [ class "row" ] [ hr [] [] ]
        , div [ class "row" ]
            [ div [ class "col-10" ] [ text (toString model.rounds) ]
            , div [ class "col-2" ] [ button [ class "btn btn-info", onClick NextCombatant ] [ text "Next" ] ]
            ]
        , div [ class "row" ]
            [ ul [ class "list-group" ] (List.indexedMap (showCombatant model.currentCombatantIdx) model.combatants)
            ]
        ]


showCombatant : Int -> Int -> Combatant -> Html Msg
showCombatant currentIdx idx combatant =
    li [ classList [ ( "list-group-item", True ), ( "active", currentIdx == idx ) ] ] [ text combatant.name ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- HTTP
