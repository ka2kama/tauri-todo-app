module HomeTest exposing (..)

import Expect
import Helpers.ElementHelpers exposing (elementToHtml)
import Pages.Home_ exposing (Model, Msg(..), view)
import Test exposing (..)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Home Page"
        [ describe "Counter Logic"
            [ test "initial counter value is 0" <|
                \_ ->
                    initialModel
                        |> .counter
                        |> Expect.equal 0
            ]
        , describe "View Elements"
            [ test "displays counter value" <|
                \_ ->
                    { counter = 42, saved = False }
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has [ Selector.text "42" ]
            , test "shows title" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has [ Selector.text "Counter Example with Ports" ]
            , test "shows increment button" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has [ Selector.text "+" ]
            , test "shows decrement button" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has [ Selector.text "-" ]
            , test "shows save button" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has [ Selector.text "Save Counter" ]
            ]
        , describe "Button Interactions"
            [ test "clicking + button triggers Increment" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.find [ Selector.class "cptr", Selector.containing [ Selector.text "+" ] ]
                        |> Event.simulate Event.click
                        |> Event.expect Increment
            , test "clicking - button triggers Decrement" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.find [ Selector.class "cptr", Selector.containing [ Selector.text "-" ] ]
                        |> Event.simulate Event.click
                        |> Event.expect Decrement
            , test "clicking Save Counter triggers SaveCounter" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.find [ Selector.class "bg-0-120-215-255", Selector.class "cptr", Selector.containing [ Selector.text "Save Counter" ] ]
                        |> Event.simulate Event.click
                        |> Event.expect SaveCounter
            ]
        , describe "Save Functionality"
            [ test "shows save confirmation when saved" <|
                \_ ->
                    { counter = 0, saved = True }
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has [ Selector.text "Counter saved!" ]
            , test "hides save confirmation when not saved" <|
                \_ ->
                    { counter = 0, saved = False }
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.hasNot [ Selector.text "Counter saved!" ]
            ]
        , describe "Styling"
            [ test "save confirmation has correct color" <|
                \_ ->
                    { counter = 0, saved = True }
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has [ Selector.class "fc-0-150-0-255" ]
            , test "save button has correct color" <|
                \_ ->
                    initialModel
                        |> view
                        |> elementToHtml
                        |> Query.fromHtml
                        |> Query.has [ Selector.class "bg-0-120-215-255" ]
            ]
        ]


initialModel : Model
initialModel =
    { counter = 0
    , saved = False
    }
