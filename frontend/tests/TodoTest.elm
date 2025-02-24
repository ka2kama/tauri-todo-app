module TodoTest exposing (..)

import Expect
import Pages.Todo_ exposing (Model, Msg(..), Todo, update)
import Ports
import Test exposing (..)


-- HELPERS


initialModel : Model
initialModel =
    { todos = []
    , newTodoInput = ""
    }


createTodo : Int -> String -> Bool -> Todo
createTodo id title completed =
    { id = id
    , title = title
    , completed = completed
    }


createModelWithTodos : List Todo -> Model
createModelWithTodos todos =
    { initialModel | todos = todos }


createModelWithInput : String -> Model
createModelWithInput input =
    { initialModel | newTodoInput = input }


expectCmd : Cmd Msg -> Cmd Msg -> Expect.Expectation
expectCmd expected actual =
    Expect.equal expected actual


expectModelAndCmd : Model -> Cmd Msg -> ( Model, Cmd Msg ) -> Expect.Expectation
expectModelAndCmd expectedModel expectedCmd ( actualModel, actualCmd ) =
    Expect.all
        [ \_ -> actualModel |> Expect.equal expectedModel
        , \_ -> actualCmd |> expectCmd expectedCmd
        ]
        ()


-- TESTS


suite : Test
suite =
    describe "Todo Page"
        [ describe "Initial State"
            [ test "model starts with empty todos and input" <|
                \_ ->
                    initialModel
                        |> Expect.equal
                            { todos = []
                            , newTodoInput = ""
                            }
            ]
        , describe "Todo List Management"
            [ test "LoadTodos replaces existing todos with new list" <|
                \_ ->
                    let
                        todos =
                            [ createTodo 1 "Test Todo" False
                            , createTodo 2 "Another Todo" True
                            ]
                    in
                    update (LoadTodos todos) initialModel
                        |> Tuple.first
                        |> .todos
                        |> Expect.equal todos
            , test "LoadTodos with empty list clears existing todos" <|
                \_ ->
                    createModelWithTodos [ createTodo 1 "Task 1" False ]
                        |> update (LoadTodos [])
                        |> Tuple.first
                        |> .todos
                        |> Expect.equal []
            ]
        , describe "Input Field Handling"
            [ test "SetNewTodoInput updates input while preserving todos" <|
                \_ ->
                    let
                        todos =
                            [ createTodo 1 "Existing Task" False ]

                        model =
                            createModelWithTodos todos
                    in
                    update (SetNewTodoInput "New Input") model
                        |> Tuple.first
                        |> Expect.all
                            [ .newTodoInput >> Expect.equal "New Input"
                            , .todos >> Expect.equal todos
                            ]
            ]
        , describe "Todo Creation"
            [ describe "invalid inputs"
                [ test "empty input is ignored" <|
                    \_ ->
                        createModelWithInput ""
                            |> update AddTodo
                            |> expectModelAndCmd
                                (createModelWithInput "")
                                Cmd.none
                , test "whitespace-only input is ignored" <|
                    \_ ->
                        createModelWithInput "   "
                            |> update AddTodo
                            |> expectModelAndCmd
                                (createModelWithInput "   ")
                                Cmd.none
                ]
            , test "valid input sends command and clears input" <|
                \_ ->
                    let
                        input =
                            "  New Task  "

                        model =
                            createModelWithInput input
                    in
                    update AddTodo model
                        |> expectModelAndCmd
                            { model | newTodoInput = "" }
                            (Ports.addTodo "New Task")
            ]
        , describe "Todo Modifications"
            [ describe "delete operations"
                [ test "sends delete command for existing id" <|
                    \_ ->
                        update (DeleteTodo 1) initialModel
                            |> Tuple.second
                            |> expectCmd (Ports.deleteTodo 1)
                , test "sends delete command for non-existent id" <|
                    \_ ->
                        update (DeleteTodo 999) initialModel
                            |> Tuple.second
                            |> expectCmd (Ports.deleteTodo 999)
                ]
            , describe "update operations"
                [ test "sends update command for existing todo" <|
                    \_ ->
                        let
                            todo =
                                createTodo 1 "Task" True
                        in
                        update (UpdateTodo todo) initialModel
                            |> Tuple.second
                            |> expectCmd (Ports.updateTodo todo)
                , test "sends update command for non-existent todo" <|
                    \_ ->
                        let
                            todo =
                                createTodo 999 "Non-existent" True
                        in
                        update (UpdateTodo todo) initialModel
                            |> Tuple.second
                            |> expectCmd (Ports.updateTodo todo)
                ]
            ]
        , describe "Port Event Handling"
            (let
                portEventCases =
                    [ ( TodoAdded True, "todo added" )
                    , ( TodoDeleted True, "todo deleted" )
                    , ( TodoUpdated True, "todo updated" )
                    ]
             in
             [ describe "success events trigger reload" <|
                List.map
                    (\( msg, description ) ->
                        test description <|
                            \_ ->
                                update msg initialModel
                                    |> expectModelAndCmd initialModel (Ports.getTodos ())
                    )
                    portEventCases
             , describe "non-port commands return Cmd.none" <|
                [ test "LoadTodos" <|
                    \_ ->
                        update (LoadTodos []) initialModel
                            |> Tuple.second
                            |> expectCmd Cmd.none
                , test "SetNewTodoInput" <|
                    \_ ->
                        update (SetNewTodoInput "test") initialModel
                            |> Tuple.second
                            |> expectCmd Cmd.none
                ]
             ]
            )
        ]
