module Helpers.ElementHelpers exposing (elementToHtml)

import Element exposing (Element)
import Html exposing (Html)


elementToHtml : Element msg -> Html msg
elementToHtml element =
    Element.layout [] element
