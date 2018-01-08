module Commands exposing (..)

import Http
import Json.Decode as Decode
import Msgs exposing (Msg)
import Models exposing (StatList, DiceCalculator)


rollDice : DiceCalculator -> Cmd Msg
rollDice model =
    let
        url =
            "/roll?num=" ++ (toString model.number) ++ "&sides=" ++ (toString model.sides) ++ "&mod=" ++ (toString model.modifier)
    in
        Http.send Msgs.Rolled (Http.get url decodeDiceRoll)


decodeDiceRoll : Decode.Decoder String
decodeDiceRoll =
    Decode.at [ "data", "output" ] Decode.string


rollStats : Cmd Msg
rollStats =
    let
        url =
            "/generate-stats"
    in
        Http.send Msgs.StatsRolled (Http.get url decodeStats)


decodeStats : Decode.Decoder (List Int)
decodeStats =
    Decode.at [ "data", "output" ] (Decode.list Decode.int)
