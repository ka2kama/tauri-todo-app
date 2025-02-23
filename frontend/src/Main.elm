module Main exposing (main)

import Browser
import Element exposing (..)
import Pages.About_
import Pages.Home_
import Pages.Todo_
import Shared


main : Program Shared.Flags Shared.Model Shared.Msg
main =
    Browser.application
        { init = Shared.init
        , view = view
        , update = Shared.update
        , subscriptions = Shared.subscriptions
        , onUrlRequest = Shared.LinkClicked
        , onUrlChange = Shared.UrlChanged
        }


mapHomeMsg : Pages.Home_.Msg -> Shared.Msg
mapHomeMsg msg =
    case msg of
        Pages.Home_.Increment ->
            Shared.Increment

        Pages.Home_.Decrement ->
            Shared.Decrement

        Pages.Home_.SaveCounter ->
            Shared.SaveCounter

        Pages.Home_.CounterSaved saved ->
            Shared.CounterSaved saved


mapAboutMsg : Pages.About_.Msg -> Shared.Msg
mapAboutMsg _ =
    Shared.NoOp


mapTodoMsg : Pages.Todo_.Msg -> Shared.Msg
mapTodoMsg msg =
    case msg of
        Pages.Todo_.LoadTodos todos ->
            Shared.LoadTodos todos

        Pages.Todo_.AddTodo ->
            Shared.AddTodo

        Pages.Todo_.DeleteTodo id ->
            Shared.DeleteTodo id

        Pages.Todo_.UpdateTodo todo ->
            Shared.UpdateTodo todo

        Pages.Todo_.SetNewTodoInput input ->
            Shared.SetNewTodoInput input


view : Shared.Model -> Browser.Document Shared.Msg
view model =
    { title = "Elm SPA Example"
    , body =
        [ Element.layout [] <|
            column [ width fill, height fill ]
                [ row [ width fill, padding 20, spacing 20 ]
                    [ link [] { url = "/", label = text "Home" }
                    , link [] { url = "/about", label = text "About" }
                    , link [] { url = "/todo", label = text "Todo" }
                    ]
                , el [ width fill, height fill ] <|
                    case model.page of
                        Shared.HomePage ->
                            Element.map mapHomeMsg <|
                                Pages.Home_.view
                                    { counter = model.shared.counter
                                    , saved = model.shared.saved
                                    }

                        Shared.AboutPage ->
                            Element.map mapAboutMsg <|
                                Pages.About_.view {}

                        Shared.TodoPage ->
                            Element.map mapTodoMsg <|
                                Pages.Todo_.view
                                    { todos = model.shared.todos
                                    , newTodoInput = model.shared.newTodoInput
                                    }
                ]
        ]
    }
