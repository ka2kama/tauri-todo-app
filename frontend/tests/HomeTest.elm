module HomeTest exposing (..)

import Expect
import Helpers.ElementHelpers exposing (elementToHtml)
import Pages.Home_ exposing (Model, Msg(..), view)
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Home Page"
        [ describe "View Elements"
            [ test "shows welcome title" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has [ Selector.text "Welcome to Tauri Todo App" ]
            , test "shows description" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has [ Selector.text "This is a simple todo application built with Tauri, Elm, and SQLite." ]
            ]
        , describe "Styling"
            [ test "has correct background color" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has [ Selector.class "bg-250-250-250-255" ]
            , test "has rounded corners" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has [ Selector.class "br-15" ]
            ]
        ]


initialModel : Model
initialModel =
    {}
