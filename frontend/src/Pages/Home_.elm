module Pages.Home_ exposing (Model, Msg(..), view)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input


type alias Model =
    { counter : Int
    , saved : Bool
    }


type Msg
    = Increment
    | Decrement
    | SaveCounter
    | CounterSaved Bool


view : Model -> Element Msg
view model =
    column
        [ centerX
        , width (fill |> maximum 800)
        , height fill
        , padding 30
        , spacing 25
        , Background.color (rgb255 250 250 250)
        , Border.rounded 15
        , Border.shadow
            { offset = ( 0, 2 )
            , size = 0
            , blur = 10
            , color = rgba 0 0 0 0.1
            }
        ]
        [ el
            [ centerX
            , Font.size 36
            , Font.bold
            , Font.color (rgb255 51 51 51)
            , paddingXY 0 10
            ]
            (text "Counter")
        , el
            [ centerX
            , Font.size 48
            , Font.bold
            , Font.color (rgb255 51 51 51)
            , paddingXY 0 20
            ]
            (text (String.fromInt model.counter))
        , row
            [ centerX
            , spacing 20
            ]
            [ button "-" Decrement
            , button "+" Increment
            ]
        , Input.button
            [ centerX
            , padding 12
            , Background.color (rgb255 130 180 255)
            , Font.color (rgb255 255 255 255)
            , Border.rounded 10
            , mouseOver
                [ Background.color (rgb255 100 150 255)
                , Border.shadow
                    { offset = ( 0, 2 )
                    , size = 0
                    , blur = 4
                    , color = rgba 0 0 0 0.1
                    }
                ]
            ]
            { onPress = Just SaveCounter
            , label = text "Save Counter"
            }
        , if model.saved then
            el
                [ centerX
                , Font.color (rgb255 34 197 94)
                , Font.size 14
                , paddingXY 0 10
                ]
                (text "Counter saved successfully!")

          else
            none
        ]


button : String -> Msg -> Element Msg
button label msg =
    el
        [ padding 15
        , Background.color (rgb255 255 255 255)
        , Border.rounded 10
        , Border.width 1
        , Border.color (rgb255 230 230 230)
        , mouseOver
            [ Border.color (rgb255 130 180 255)
            , Border.shadow
                { offset = ( 0, 2 )
                , size = 0
                , blur = 4
                , color = rgba 0 0 0 0.05
                }
            ]
        , onClick msg
        , pointer
        , Font.size 20
        , Font.color (rgb255 51 51 51)
        , width (px 50)
        , height (px 50)
        ]
        (el [ centerX, centerY ] (text label))
