module SharedTest exposing (..)

import Browser
import Expect
import Shared exposing (Msg(..))
import Json.Encode as Encode
import Router exposing (Page(..))
import Test exposing (..)
import Url



-- TYPES


{-| A simplified model for testing that omits the navigation key
-}
type alias TestModel =
    { page : Page
    }



-- HELPERS


{-| Create a test model with default values that can be overridden
-}
createTestModel : String -> TestModel
createTestModel path =
    let
        url =
            createTestUrl path
    in
    { page = Router.fromUrl url
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
        UrlChanged url ->
            ( { model
                | page = Router.fromUrl url
              }
            , Cmd.none
            )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal _ ->
                    ( model, Cmd.none )

                Browser.External _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- TESTS


suite : Test
suite =
    describe "Global"
        [ describe "Initial State"
            [ test "starts with home route by default" <|
                \_ ->
                    createTestModel "/"
                        |> .page
                        |> Expect.equal HomePage
            ]
        , describe "URL Changes"
            [ test "updates route when URL changes" <|
                \_ ->
                    let
                        ( updatedModel, _ ) =
                            createTestModel "/"
                                |> testUpdate (UrlChanged (createTestUrl "/about"))
                    in
                    updatedModel.page
                        |> Expect.equal AboutPage
            ]
        , describe "Flags Handling"
            [ test "can encode and decode empty flags" <|
                \_ ->
                    Encode.object []
                        |> Encode.encode 0
                        |> Expect.equal "{}"
            ]
        ]
