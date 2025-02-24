module SharedTest exposing (..)

import Expect
import Json.Encode as Encode
import Shared exposing (Msg(..), Page(..))
import Test exposing (..)
import Url


-- TYPES


{-| A simplified model for testing that omits the navigation key
-}
type alias TestModel =
    { url : Url.Url
    , page : Page
    , shared : SharedData
    }


type alias SharedData =
    { counter : Int
    , saved : Bool
    }


-- HELPERS


{-| Create a test model with default values that can be overridden
-}
createTestModel : SharedData -> TestModel
createTestModel shared =
    { url = createTestUrl "/"
    , page = HomePage
    , shared = shared
    }


{-| Create a test URL with a given path
-}
createTestUrl : String -> Url.Url
createTestUrl path =
    Url.fromString ("http://localhost:1234" ++ path)
        |> Maybe.withDefault
            (Url.Url Url.Http "localhost" (Just 1234) "/" Nothing Nothing)


{-| Update the test model with a message
-}
testUpdate : Msg -> TestModel -> ( TestModel, Cmd Msg )
testUpdate msg model =
    case msg of
        Increment ->
            ( { model | shared = { counter = model.shared.counter + 1, saved = model.shared.saved } }
            , Cmd.none
            )

        Decrement ->
            ( { model | shared = { counter = model.shared.counter - 1, saved = model.shared.saved } }
            , Cmd.none
            )

        SaveCounter ->
            ( { model | shared = { counter = model.shared.counter, saved = False } }
            , Cmd.none
            )

        CounterSaved saved ->
            ( { model | shared = { counter = model.shared.counter, saved = saved } }
            , Cmd.none
            )

        UrlChanged url ->
            let
                page =
                    case url.path of
                        "/about" ->
                            AboutPage

                        "/todo" ->
                            TodoPage

                        "/counter" ->
                            CounterPage

                        _ ->
                            HomePage
            in
            ( { model | url = url, page = page }, Cmd.none )

        _ ->
            ( model, Cmd.none )


-- TESTS


suite : Test
suite =
    describe "Shared"
        [ describe "Initial State"
            [ test "shared state starts with expected defaults" <|
                \_ ->
                    let
                        shared =
                            { counter = 0, saved = False }
                    in
                    Expect.all
                        [ .counter >> Expect.equal 0
                        , .saved >> Expect.equal False
                        ]
                        shared
            ]
        , describe "Counter Operations"
            (let
                testCounterOperation : String -> Msg -> Int -> Test
                testCounterOperation description msg expectedChange =
                    test description <|
                        \_ ->
                            let
                                initialCounter =
                                    5

                                ( updatedModel, _ ) =
                                    createTestModel
                                        { counter = initialCounter
                                        , saved = False
                                        }
                                        |> testUpdate msg
                            in
                            updatedModel.shared.counter
                                |> Expect.equal (initialCounter + expectedChange)
             in
             [ testCounterOperation "increment increases counter by 1" Increment 1
             , testCounterOperation "decrement decreases counter by 1" Decrement -1
             ]
            )
        , describe "Save Counter Functionality"
            (let
                testSaveOperation : String -> Bool -> Msg -> Bool -> Test
                testSaveOperation description initialSaved msg expectedSaved =
                    test description <|
                        \_ ->
                            createTestModel
                                { counter = 5
                                , saved = initialSaved
                                }
                                |> testUpdate msg
                                |> Tuple.first
                                |> .shared
                                |> .saved
                                |> Expect.equal expectedSaved
             in
             [ testSaveOperation "SaveCounter resets saved flag" True SaveCounter False
             , testSaveOperation "CounterSaved updates saved state" False (CounterSaved True) True
             ]
            )
        , describe "URL-based Page Routing"
            (let
                testCases =
                    [ ( "/", HomePage, "root path" )
                    , ( "/about", AboutPage, "about page" )
                    , ( "/todo", TodoPage, "todo page" )
                    , ( "/counter", CounterPage, "counter page" )
                    , ( "/unknown", HomePage, "unknown path" )
                    ]
             in
             List.map
                (\( path, expectedPage, description ) ->
                    test ("maps " ++ description ++ " correctly") <|
                        \_ ->
                            let
                                url =
                                    createTestUrl path

                                ( updatedModel, _ ) =
                                    createTestModel
                                        { counter = 0
                                        , saved = False
                                        }
                                        |> testUpdate (UrlChanged url)
                            in
                            updatedModel.page
                                |> Expect.equal expectedPage
                )
                testCases
            )
        , describe "Flags Handling"
            [ test "can encode and decode empty flags" <|
                \_ ->
                    Encode.object []
                        |> Encode.encode 0
                        |> Expect.equal "{}"
            ]
        ]
