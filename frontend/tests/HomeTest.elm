module HomeTest exposing (..)

import Expect
import Helpers.ElementHelpers exposing (hasText, renderView)
import Html.Attributes
import Pages.Home_ exposing (Model, Msg(..), view)
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector as Selector



-- HELPERS


initialModel : Model
initialModel =
    {}


hasLink : { text : String, href : String } -> Query.Single Msg -> Expect.Expectation
hasLink { text, href } query =
    query
        |> Query.has
            [ Selector.tag "a"
            , Selector.attribute (Html.Attributes.href href)
            , Selector.text text
            ]



-- TESTS


suite : Test
suite =
    describe "Home Page"
        [ describe "Navigation"
            (let
                navigationLinks =
                    [ { text = "Counter", href = "/counter" }
                    , { text = "Todo", href = "/todo" }
                    , { text = "About", href = "/about" }
                    ]
             in
             [ test "displays all navigation links" <|
                \_ ->
                    let
                        query =
                            renderView view initialModel
                    in
                    navigationLinks
                        |> List.map hasLink
                        |> (\expectations -> Expect.all expectations query)
             , test "has exactly three navigation links" <|
                \_ ->
                    renderView view initialModel
                        |> Query.findAll [ Selector.tag "a" ]
                        |> Query.count (Expect.equal 3)
             ]
            )
        , describe "Content"
            [ test "displays welcome message and description" <|
                \_ ->
                    let
                        query =
                            renderView view initialModel
                    in
                    Expect.all
                        [ hasText "Welcome to Tauri Todo App"
                        , hasText "This is a simple todo application built with Tauri, Elm, and SQLite."
                        ]
                        query
            ]
        ]
