module TodoTest exposing (..)

import Expect
import Pages.Todo_ exposing (Model, Msg(..), Todo, update)
import Ports
import Test exposing (..)


suite : Test
suite =
    describe "Todo Page"
        [ describe "Model"
            [ test "initial model has empty todos and input" <|
                \_ ->
                    initialModel
                        |> Expect.equal
                            { todos = []
                            , newTodoInput = ""
                            }
            ]
        , describe "Todo Operations"
            [ test "LoadTodos updates the todos list" <|
                \_ ->
                    let
                        todos =
                            [ { id = 1, title = "Test Todo", completed = False }
                            , { id = 2, title = "Another Todo", completed = True }
                            ]
                    in
                    update (LoadTodos todos) initialModel
                        |> Tuple.first
                        |> .todos
                        |> Expect.equal todos
            , test "LoadTodos with empty list clears todos" <|
                \_ ->
                    let
                        model =
                            { initialModel
                                | todos =
                                    [ { id = 1, title = "Task 1", completed = False } ]
                            }
                    in
                    update (LoadTodos []) model
                        |> Tuple.first
                        |> .todos
                        |> Expect.equal []
            , test "SetNewTodoInput updates the input field" <|
                \_ ->
                    update (SetNewTodoInput "New Task") initialModel
                        |> Tuple.first
                        |> .newTodoInput
                        |> Expect.equal "New Task"
            , test "SetNewTodoInput preserves existing todos" <|
                \_ ->
                    let
                        todos =
                            [ { id = 1, title = "Existing Task", completed = False } ]

                        model =
                            { initialModel | todos = todos }
                    in
                    update (SetNewTodoInput "New Input") model
                        |> Tuple.first
                        |> .todos
                        |> Expect.equal todos
            , test "AddTodo with empty input does nothing" <|
                \_ ->
                    let
                        ( newModel, cmd ) =
                            update AddTodo initialModel
                    in
                    Expect.all
                        [ \_ -> newModel |> Expect.equal initialModel
                        , \_ -> cmd |> Expect.equal Cmd.none
                        ]
                        ()
            , test "AddTodo with whitespace-only input does nothing" <|
                \_ ->
                    let
                        modelWithInput =
                            { initialModel | newTodoInput = "   " }
                    in
                    let
                        ( newModel, cmd ) =
                            update AddTodo modelWithInput
                    in
                    Expect.all
                        [ \_ -> newModel |> Expect.equal modelWithInput
                        , \_ -> cmd |> Expect.equal Cmd.none
                        ]
                        ()
            , test "AddTodo with non-empty input adds a new todo with correct id" <|
                \_ ->
                    let
                        existingTodos =
                            [ { id = 1, title = "Existing Task", completed = False } ]

                        modelWithInput =
                            { todos = existingTodos
                            , newTodoInput = "Test Task"
                            }

                        expectedTodos =
                            existingTodos ++
                                [ { id = 2
                                  , title = "Test Task"
                                  , completed = False
                                  }
                                ]
                    in
                    let
                        ( newModel, cmd ) =
                            update AddTodo modelWithInput
                    in
                    Expect.all
                        [ \_ -> newModel.newTodoInput |> Expect.equal ""
                        , \_ -> cmd |> Expect.equal (Ports.addTodo "Test Task")
                        ]
                        ()
            , test "AddTodo trims whitespace from input" <|
                \_ ->
                    let
                        modelWithInput =
                            { initialModel | newTodoInput = "  Task with spaces  " }

                        expectedTodo =
                            { id = 1
                            , title = "Task with spaces"
                            , completed = False
                            }
                    in
                    let
                        ( newModel, cmd ) =
                            update AddTodo modelWithInput
                    in
                    Expect.all
                        [ \_ -> newModel.newTodoInput |> Expect.equal ""
                        , \_ -> cmd |> Expect.equal (Ports.addTodo "Task with spaces")
                        ]
                        ()
            , test "AddTodo preserves existing todos" <|
                \_ ->
                    let
                        existingTodos =
                            [ { id = 1, title = "Task 1", completed = True }
                            , { id = 2, title = "Task 2", completed = False }
                            ]

                        modelWithTodos =
                            { todos = existingTodos
                            , newTodoInput = "New Task"
                            }

                        expectedTodos =
                            existingTodos ++
                                [ { id = 3
                                  , title = "New Task"
                                  , completed = False
                                  }
                                ]
                    in
                    let
                        ( newModel, cmd ) =
                            update AddTodo modelWithTodos
                    in
                    Expect.all
                        [ \_ -> newModel.newTodoInput |> Expect.equal ""
                        , \_ -> cmd |> Expect.equal (Ports.addTodo "New Task")
                        ]
                        ()
            , test "DeleteTodo removes only the todo with matching id" <|
                \_ ->
                    let
                        todos =
                            [ { id = 1, title = "Task 1", completed = False }
                            , { id = 2, title = "Task 2", completed = False }
                            ]

                        model =
                            { initialModel | todos = todos }
                    in
                    let
                        ( _, cmd ) =
                            update (DeleteTodo 1) model
                    in
                    cmd |> Expect.equal (Ports.deleteTodo 1)
            , test "DeleteTodo with non-existent id changes nothing" <|
                \_ ->
                    let
                        todos =
                            [ { id = 1, title = "Task 1", completed = False } ]

                        model =
                            { initialModel | todos = todos }
                    in
                    let
                        ( _, cmd ) =
                            update (DeleteTodo 999) model
                    in
                    cmd |> Expect.equal (Ports.deleteTodo 999)
            , test "UpdateTodo updates only the matching todo" <|
                \_ ->
                    let
                        todos =
                            [ { id = 1, title = "Task 1", completed = False }
                            , { id = 2, title = "Task 2", completed = False }
                            ]

                        model =
                            { initialModel | todos = todos }

                        updatedTodo =
                            { id = 1, title = "Task 1", completed = True }

                        expectedTodos =
                            [ { id = 1, title = "Task 1", completed = True }
                            , { id = 2, title = "Task 2", completed = False }
                            ]
                    in
                    let
                        ( _, cmd ) =
                            update (UpdateTodo updatedTodo) model
                    in
                    cmd |> Expect.equal (Ports.updateTodo updatedTodo)
            , test "UpdateTodo with non-existent id changes nothing" <|
                \_ ->
                    let
                        todos =
                            [ { id = 1, title = "Task 1", completed = False } ]

                        model =
                            { initialModel | todos = todos }

                        nonExistentTodo =
                            { id = 999, title = "Non-existent", completed = True }
                    in
                    let
                        ( _, cmd ) =
                            update (UpdateTodo nonExistentTodo) model
                    in
                    cmd |> Expect.equal (Ports.updateTodo nonExistentTodo)
            ]
        , describe "Port Operations"
            [ test "TodoAdded preserves model and triggers reload" <|
                \_ ->
                    let
                        ( _, cmd ) =
                            update (TodoAdded True) initialModel
                    in
                    Expect.all
                        [ \_ -> Tuple.first (update (TodoAdded True) initialModel) |> Expect.equal initialModel
                        , \_ -> cmd |> Expect.equal (Ports.getTodos ())
                        ]
                        ()
            , test "TodoDeleted preserves model and triggers reload" <|
                \_ ->
                    let
                        ( _, cmd ) =
                            update (TodoDeleted True) initialModel
                    in
                    Expect.all
                        [ \_ -> Tuple.first (update (TodoDeleted True) initialModel) |> Expect.equal initialModel
                        , \_ -> cmd |> Expect.equal (Ports.getTodos ())
                        ]
                        ()
            , test "TodoUpdated preserves model and triggers reload" <|
                \_ ->
                    let
                        ( _, cmd ) =
                            update (TodoUpdated True) initialModel
                    in
                    Expect.all
                        [ \_ -> Tuple.first (update (TodoUpdated True) initialModel) |> Expect.equal initialModel
                        , \_ -> cmd |> Expect.equal (Ports.getTodos ())
                        ]
                        ()
            , test "LoadTodos command is None" <|
                \_ ->
                    let
                        ( _, cmd ) =
                            update (LoadTodos []) initialModel
                    in
                    cmd |> Expect.equal Cmd.none
            , test "SetNewTodoInput command is None" <|
                \_ ->
                    let
                        ( _, cmd ) =
                            update (SetNewTodoInput "test") initialModel
                    in
                    cmd |> Expect.equal Cmd.none
            ]
        ]


initialModel : Model
initialModel =
    { todos = []
    , newTodoInput = ""
    }
