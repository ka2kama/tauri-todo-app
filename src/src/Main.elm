port module Main exposing (main)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes
import Json.Encode as E



-- PORTS


port invoke : E.Value -> Cmd msg


port receiveGreeting : (String -> msg) -> Sub msg



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { input : String
    , greeting : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { input = "", greeting = "" }
    , Cmd.none
    )



-- UPDATE


type Msg
    = UpdateInput String
    | SubmitForm
    | ReceiveGreeting String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateInput newInput ->
            ( { model | input = newInput }
            , Cmd.none
            )

        SubmitForm ->
            ( model
            , invoke <|
                E.object
                    [ ( "cmd", E.string "greet" )
                    , ( "args", E.object [ ( "name", E.string model.input ) ] )
                    ]
            )

        ReceiveGreeting greeting ->
            ( { model | greeting = greeting }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    receiveGreeting ReceiveGreeting



-- VIEW


view : Model -> Html Msg
view model =
    layout
        [ Background.color (rgb255 246 246 246)
        , Font.family
            [ Font.typeface "Inter"
            , Font.typeface "Avenir"
            , Font.typeface "Helvetica"
            , Font.typeface "Arial"
            , Font.sansSerif
            ]
        , Font.size 16
        , Font.color (rgb255 15 15 15)
        ]
        (column
            [ centerX
            , spacing 20
            , padding 40
            , width fill
            ]
            [ el
                [ Font.size 32
                , centerX
                , Font.center
                ]
                (text "Welcome to Tauri")
            , row
                [ centerX
                , spacing 20
                ]
                [ link []
                    { url = "https://tauri.app"
                    , label =
                        image
                            [ width (px 96)
                            , height (px 96)
                            , mouseOver [ scale 1.1 ]
                            , Element.htmlAttribute
                                (Html.Attributes.style "transition" "transform 0.3s ease-in-out")
                            ]
                            { src = "/assets/tauri.svg"
                            , description = "Tauri logo"
                            }
                    }
                , link []
                    { url = "https://elm-lang.org"
                    , label =
                        image
                            [ width (px 96)
                            , height (px 96)
                            , mouseOver [ scale 1.1 ]
                            , Element.htmlAttribute
                                (Html.Attributes.style "transition" "transform 0.3s ease-in-out")
                            ]
                            { src = "/assets/elm.svg"
                            , description = "Elm logo"
                            }
                    }
                ]
            , paragraph
                [ centerX
                , Font.center
                ]
                [ text "Click on the Tauri logo to learn more about the framework" ]
            , row
                [ centerX
                , spacing 10
                ]
                [ Input.text
                    [ width (px 200)
                    , Border.rounded 8
                    , Border.width 1
                    , Border.color (rgba 0 0 0 0)
                    , padding 10
                    , Background.color (rgb255 255 255 255)
                    , Font.color (rgb255 15 15 15)
                    , mouseOver
                        [ Border.color (rgb255 57 108 216)
                        ]
                    ]
                    { onChange = UpdateInput
                    , text = model.input
                    , placeholder = Just (Input.placeholder [] (text "Enter a name..."))
                    , label = Input.labelHidden "Name input"
                    }
                , Input.button
                    [ Border.rounded 8
                    , Border.width 1
                    , Border.color (rgba 0 0 0 0)
                    , padding 10
                    , Background.color (rgb255 255 255 255)
                    , Font.color (rgb255 15 15 15)
                    , mouseOver
                        [ Border.color (rgb255 57 108 216)
                        ]
                    , Events.onClick SubmitForm
                    ]
                    { onPress = Just SubmitForm
                    , label = text "Greet"
                    }
                ]
            , el
                [ centerX
                , Font.center
                ]
                (text model.greeting)
            ]
        )
