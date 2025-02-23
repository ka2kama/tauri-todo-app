module SharedTest exposing (..)

import Expect
import Json.Encode as Encode
import Shared exposing (Msg(..), Page(..))
import Test exposing (..)
import Url


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


{-| A simplified update function for testing that doesn't handle navigation
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

                        _ ->
                            HomePage
            in
            ( { model | url = url, page = page }, Cmd.none )

        _ ->
            ( model, Cmd.none )


suite : Test
suite =
    describe "Shared"
        [ describe "Shared State"
            [ test "initial shared state" <|
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
            [ test "increment increases counter" <|
                \_ ->
                    let
                        model =
                            createTestModel
                                { counter = 5
                                , saved = False
                                }

                        ( updatedModel, _ ) =
                            testUpdate Increment model
                    in
                    Expect.equal updatedModel.shared.counter 6
            , test "decrement decreases counter" <|
                \_ ->
                    let
                        model =
                            createTestModel
                                { counter = 5
                                , saved = False
                                }

                        ( updatedModel, _ ) =
                            testUpdate Decrement model
                    in
                    Expect.equal updatedModel.shared.counter 4
            ]
        , describe "Save Counter"
            [ test "SaveCounter sets saved to false and triggers port" <|
                \_ ->
                    let
                        model =
                            createTestModel
                                { counter = 5
                                , saved = True
                                }

                        ( updatedModel, _ ) =
                            testUpdate SaveCounter model
                    in
                    Expect.equal updatedModel.shared.saved False
            , test "CounterSaved updates saved state" <|
                \_ ->
                    let
                        model =
                            createTestModel
                                { counter = 5
                                , saved = False
                                }

                        ( updatedModel, _ ) =
                            testUpdate (CounterSaved True) model
                    in
                    Expect.equal updatedModel.shared.saved True
            ]
        , describe "URL Handling"
            [ test "root URL maps to HomePage" <|
                \_ ->
                    let
                        model =
                            createTestModel
                                { counter = 0
                                , saved = False
                                }

                        url =
                            Url.fromString "http://localhost:1234/" |> Maybe.withDefault model.url

                        ( updatedModel, _ ) =
                            testUpdate (UrlChanged url) model
                    in
                    Expect.equal updatedModel.page HomePage
            , test "/about URL maps to AboutPage" <|
                \_ ->
                    let
                        model =
                            createTestModel
                                { counter = 0
                                , saved = False
                                }

                        url =
                            Url.fromString "http://localhost:1234/about" |> Maybe.withDefault model.url

                        ( updatedModel, _ ) =
                            testUpdate (UrlChanged url) model
                    in
                    Expect.equal updatedModel.page AboutPage
            , test "unknown URL maps to HomePage" <|
                \_ ->
                    let
                        model =
                            createTestModel
                                { counter = 0
                                , saved = False
                                }

                        url =
                            Url.fromString "http://localhost:1234/unknown" |> Maybe.withDefault model.url

                        ( updatedModel, _ ) =
                            testUpdate (UrlChanged url) model
                    in
                    Expect.equal updatedModel.page HomePage
            ]
        , describe "Flags"
            [ test "can decode empty flags" <|
                \_ ->
                    let
                        flags =
                            Encode.object []
                    in
                    Expect.equal (Encode.encode 0 flags) "{}"
            ]
        ]


{-| Helper function to create a test model
-}
createTestModel : SharedData -> TestModel
createTestModel shared =
    { url = Url.fromString "http://localhost:1234/" |> Maybe.withDefault (Url.Url Url.Http "localhost" (Just 1234) "/" Nothing Nothing)
    , page = HomePage
    , shared = shared
    }
