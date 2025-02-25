module Pages.About_ exposing (Model, Msg(..), view)

import Element exposing (..)
import Styles exposing (defaultTheme)


type alias Model =
    {}


type Msg
    = NoOp


view : Model -> Element Msg
view _ =
    Styles.containerCard defaultTheme [ spacing 25 ] <|
        column [ width fill, spacing 25 ]
            [ Styles.heading1 defaultTheme "About"
            , Styles.paragraph defaultTheme
                { text = "Welcome to our Elm Single Page Application! This is a sample project demonstrating the power and simplicity of Elm for building web applications."
                , maxWidth = 600
                }
            , Styles.paragraph defaultTheme
                { text = "The application showcases various Elm features including:"
                , maxWidth = 600
                }
            , column
                [ centerX
                , spacing 12
                , padding 20
                , width (fill |> maximum 600)
                ]
                (List.map (Styles.featureItem defaultTheme)
                    [ "Type-safe routing"
                    , "Component-based architecture"
                    , "Ports for JavaScript interop"
                    , "Elegant UI with elm-ui"
                    ]
                )
            ]
