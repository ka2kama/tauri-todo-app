module Pages.Home_ exposing (Model, Msg(..), view)

import Element exposing (..)
import Element.Font as Font
import Styles exposing (defaultTheme)


type alias Model =
    {}


type Msg
    = NoOp


view : Model -> Element Msg
view _ =
    Styles.containerCard defaultTheme [ spacing 25 ] <|
        column [ width fill, spacing 25 ]
            [ Styles.heading1 defaultTheme "Welcome to Tauri Todo App"
            , paragraph
                [ centerX
                , Font.size 18
                , Font.color defaultTheme.colors.textLight
                , paddingXY 0 20
                , width (fill |> maximum 600)
                , Font.center
                ]
                [ text "This is a simple todo application built with Tauri, Elm, and SQLite. Use the navigation menu to explore different features." ]
            , row
                [ centerX
                , spacing 20
                , paddingXY 0 10
                ]
                [ Styles.linkButton defaultTheme
                    { url = "/counter"
                    , label = "Counter"
                    }
                , Styles.linkButton defaultTheme
                    { url = "/todo"
                    , label = "Todo"
                    }
                , Styles.linkButton defaultTheme
                    { url = "/about"
                    , label = "About"
                    }
                ]
            ]
