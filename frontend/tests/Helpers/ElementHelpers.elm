module Helpers.ElementHelpers exposing
    ( elementToHtml
    , hasText
    , renderView
    )

import Element exposing (Element)
import Expect
import Html exposing (Html)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


{-| Convert an elm-ui Element to Html for testing
-}
elementToHtml : Element msg -> Html msg
elementToHtml element =
    Element.layout [] element


{-| Render a view function's output into a Query.Single for testing
-}
renderView : (model -> Element msg) -> model -> Query.Single msg
renderView viewFn model =
    model
        |> viewFn
        |> elementToHtml
        |> Query.fromHtml


{-| Test if a query contains specific text
-}
hasText : String -> Query.Single msg -> Expect.Expectation
hasText text query =
    query |> Query.has [ Selector.text text ]
