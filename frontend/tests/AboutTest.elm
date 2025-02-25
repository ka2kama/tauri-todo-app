module AboutTest exposing (..)

import Expect
import Helpers.ElementHelpers exposing (hasText, renderView)
import Pages.About_ exposing (Model, Msg(..), view)
import Test exposing (..)



-- HELPERS


initialModel : Model
initialModel =
    {}



-- TESTS


suite : Test
suite =
    describe "About Page"
        [ describe "Core Content"
            [ test "displays main heading and welcome message" <|
                \_ ->
                    let
                        query =
                            renderView view initialModel
                    in
                    Expect.all
                        [ hasText "About"
                        , hasText "Welcome to our Elm Single Page Application!"
                        ]
                        query
            ]
        , describe "Features List"
            (let
                features =
                    [ "Type-safe routing"
                    , "Component-based architecture"
                    , "Ports for JavaScript interop"
                    , "Elegant UI with elm-ui"
                    ]
             in
             [ test "displays all feature items" <|
                \_ ->
                    let
                        query =
                            renderView view initialModel
                    in
                    features
                        |> List.map hasText
                        |> (\expectations -> Expect.all expectations query)
             ]
            )
        ]
