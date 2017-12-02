module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events.Extra exposing (targetValueIntParse)
import Http
import Json.Decode as Decode


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { diceCount : Int
    , diceSides : Int
    , diceModifier : Int
    , diceOutput : String
    }


init : ( Model, Cmd Msg )
init =
    ( Model 1 6 0 "", Cmd.none )



-- UPDATE


type Msg
    = ChangeCount Int
    | ChangeSides Int
    | ChangeModifier Int
    | RollDice
    | Rolled (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RollDice ->
            ( model, rollDice model )

        ChangeCount newCount ->
            ( { model | diceCount = newCount }, Cmd.none )

        ChangeSides newSides ->
            ( { model | diceSides = newSides }, Cmd.none )

        ChangeModifier newModifier ->
            ( { model | diceModifier = newModifier }, Cmd.none )

        Rolled (Ok output) ->
            ( { model | diceOutput = output }, Cmd.none )

        Rolled (Err _) ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "row" ] [ h3 [] [ text "Dice Roller" ] ]
        , div [ class "row" ]
            [ div [ class "col-2" ]
                [ input
                    [ type_ "text"
                    , class "form-control"
                    , placeholder "Enter number of dice"
                    , value (toString model.diceCount)
                    , on "input" (Decode.map ChangeCount targetValueIntParse)
                    ]
                    []
                ]
            , div [ class "col-4" ]
                [ div [ class "input-group" ]
                    [ span [ class "input-group-addon" ] [ text "d" ]
                    , select [ class "form-control", on "change" (Decode.map ChangeSides targetValueIntParse) ]
                        (List.map (sidesOption model.diceSides) [ 4, 6, 8, 10, 12, 20 ])
                    ]
                ]
            , div [ class "col-6" ]
                [ div [ class "input-group" ]
                    [ span [ class "input-group-addon" ] [ text "+" ]
                    , input
                        [ type_ "text"
                        , class "form-control"
                        , placeholder "Enter any additional modifier"
                        , value (toString model.diceModifier)
                        , on "input" (Decode.map ChangeModifier targetValueIntParse)
                        ]
                        []
                    , span [ class "input-group-btn" ] [ button [ class "btn btn-primary", onClick RollDice ] [ text "Roll!" ] ]
                    ]
                ]
            ]
        , div [ class "row" ] [ text model.diceOutput ]
        ]


sidesOption : Int -> Int -> Html Msg
sidesOption currentSelection numSides =
    option [ value (toString numSides), selected (currentSelection == numSides) ] [ text (toString numSides) ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- HTTP


rollDice : Model -> Cmd Msg
rollDice model =
    let
        url =
            "/roll?num=" ++ (toString model.diceCount) ++ "&sides=" ++ (toString model.diceSides) ++ "&mod=" ++ (toString model.diceModifier)
    in
        Http.send Rolled (Http.get url decodeDiceRoll)


decodeDiceRoll : Decode.Decoder String
decodeDiceRoll =
    Decode.at [ "data", "output" ] Decode.string
