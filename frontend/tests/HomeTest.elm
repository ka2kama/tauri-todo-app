module HomeTest exposing (..)

import Expect
import Helpers.ElementHelpers exposing (elementToHtml)
import Html.Attributes
import Pages.Home_ exposing (Model, Msg(..), view)
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Home Page"
        [ describe "Navigation Links"
            [ test "shows Counter link" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has
                            [ Selector.tag "a"
                            , Selector.attribute (Html.Attributes.href "/counter")
                            , Selector.text "Counter"
                            ]
            , test "shows Todo link" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has
                            [ Selector.tag "a"
                            , Selector.attribute (Html.Attributes.href "/todo")
                            , Selector.text "Todo"
                            ]
            , test "shows About link" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has
                            [ Selector.tag "a"
                            , Selector.attribute (Html.Attributes.href "/about")
                            , Selector.text "About"
                            ]
            , test "links have correct styling" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.tag "a" ]
                        |> Query.count (Expect.equal 3)
            , test "links have correct background color" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.tag "a" ]
                        |> Query.first
                        |> Query.has [ Selector.class "bg-59-130-246-255" ]
            , test "links have rounded corners" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.tag "a" ]
                        |> Query.first
                        |> Query.has [ Selector.class "br-8" ]
            ]
        , describe "View Elements"
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
