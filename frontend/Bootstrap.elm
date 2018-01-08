module Bootstrap exposing (..)

import Html
import Html.Attributes


row : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
row attributes elements =
    Html.div (List.append [ (Html.Attributes.class "row") ] attributes) elements


col_12 : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
col_12 =
    col "12"


col : String -> List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
col width attributes elements =
    Html.div (List.append [ Html.Attributes.class ("col-" ++ width) ] attributes) elements
