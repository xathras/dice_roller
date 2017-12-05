module StatList exposing (..)

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
    { statList : List Int
    }


init : ( Model, Cmd Msg )
init =
    ( Model [], Cmd.none )



-- UPDATE


type Msg
    = RollDice
    | Rolled (Result Http.Error (List Int))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RollDice ->
            ( model, rollDice model )

        Rolled (Ok output) ->
            ( { model | statList = output }, Cmd.none )

        Rolled (Err _) ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "row" ] [ h3 [] [ text "Stat List" ] ]
        , div [ class "row" ]
            [ div [ class "input-group" ]
                [ select [ class "form-control" ] [ option [] [ text "Class Name" ] ]
                , span [ class "input-group-btn" ] [ button [ class "btn btn-primary", onClick RollDice ] [ text "Roll Stats" ] ]
                ]
            ]
        , div [ class "row" ] [ statListing model.statList ]
        ]


statListing : List Int -> Html Msg
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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- HTTP


rollDice : Model -> Cmd Msg
rollDice model =
    let
        url =
            "/generate-stats"
    in
        Http.send Rolled (Http.get url decodeStats)


decodeStats : Decode.Decoder (List Int)
decodeStats =
    Decode.at [ "data", "output" ] (Decode.list Decode.int)
