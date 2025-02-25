module CounterTest exposing (..)

import Expect
import Helpers.ElementHelpers exposing (renderView)
import Pages.Counter_ exposing (Model, Msg(..), view)
import Test exposing (..)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector
import Router exposing (Page(..))


-- HELPERS

initialModel : Model
initialModel =
    { counter = 0
    , saved = False
    }


hasButton : String -> Query.Single Msg -> Expect.Expectation
hasButton label query =
    query
        |> Query.findAll [ Selector.class "cptr", Selector.containing [ Selector.text label ] ]
        |> Query.count (Expect.equal 1)


clickButton : String -> Query.Single Msg -> Event.Event Msg
clickButton label query =
    query
        |> Query.find [ Selector.class "cptr", Selector.containing [ Selector.text label ] ]
        |> Event.simulate Event.click



-- TESTS


suite : Test
suite =
    describe "Counter Page"
        [ describe "Initial State"
            [ test "counter starts at 0" <|
                \_ ->
                    initialModel
                        |> .counter
                        |> Expect.equal 0
            , test "save status starts as false" <|
                \_ ->
                    initialModel
                        |> .saved
                        |> Expect.equal False
            ]
        , describe "Display Elements"
            [ test "shows page title" <|
                \_ ->
                    initialModel
                        |> renderView view
                        |> Query.has [ Selector.text "Counter Example with Ports" ]
            , test "displays current counter value" <|
                \_ ->
                    { initialModel | counter = 42 }
                        |> renderView view
                        |> Query.has [ Selector.text "42" ]
            , test "renders all control buttons" <|
                \_ ->
                    let
                        query =
                            initialModel |> renderView view
                    in
                    Expect.all
                        [ hasButton "+"
                        , hasButton "-"
                        , hasButton "Save Counter"
                        ]
                        query
            ]
        , describe "Button Interactions"
            [ test "increment button triggers Increment msg" <|
                \_ ->
                    initialModel
                        |> renderView view
                        |> clickButton "+"
                        |> Event.expect Increment
            , test "decrement button triggers Decrement msg" <|
                \_ ->
                    initialModel
                        |> renderView view
                        |> clickButton "-"
                        |> Event.expect Decrement
            , test "save button triggers SaveCounter msg" <|
                \_ ->
                    initialModel
                        |> renderView view
                        |> clickButton "Save Counter"
                        |> Event.expect SaveCounter
            ]
        , describe "Save Status Display"
            [ test "shows success message when counter is saved" <|
                \_ ->
                    { initialModel | saved = True }
                        |> renderView view
                        |> Query.has [ Selector.text "Counter saved!" ]
            , test "hides success message when counter is not saved" <|
                \_ ->
                    initialModel
                        |> renderView view
                        |> Query.hasNot [ Selector.text "Counter saved!" ]
            ]
        ]
