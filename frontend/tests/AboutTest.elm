module AboutTest exposing (..)

import Expect
import Helpers.ElementHelpers exposing (elementToHtml)
import Pages.About_ exposing (Model, Msg(..), view)
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "About Page"
        [ describe "View Elements"
            [ test "shows title" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has [ Selector.text "About" ]
            , test "shows welcome message" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has [ Selector.text "Welcome to our Elm Single Page Application!" ]
            , test "shows features list" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.containing [ Selector.text "Type-safe routing" ] ]
                        |> Query.count (Expect.equal 1)
            , test "shows component architecture feature" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has [ Selector.text "Component-based architecture" ]
            , test "shows ports feature" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has [ Selector.text "Ports for JavaScript interop" ]
            , test "shows elm-ui feature" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has [ Selector.text "Elegant UI with elm-ui" ]
            ]
        , describe "Styling"
            [ test "has correct background color" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has [ Selector.class "bg-240-240-240-255" ]
            , test "has correct border radius" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has [ Selector.class "br-10" ]
            ]
        ]


initialModel : Model
initialModel =
    {}
