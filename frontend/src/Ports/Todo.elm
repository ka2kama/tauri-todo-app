port module Ports.Todo exposing
    ( addTodo
    , deleteTodo
    , getTodos
    , todoAdded
    , todoDeleted
    , todoUpdated
    , todosLoaded
    , updateTodo
    )

import Domain.Todo exposing (Todo)


port getTodos : () -> Cmd msg


port addTodo : String -> Cmd msg


port deleteTodo : Int -> Cmd msg


port updateTodo : Todo -> Cmd msg


port todosLoaded : (List Todo -> msg) -> Sub msg


port todoAdded : (Bool -> msg) -> Sub msg


port todoDeleted : (Bool -> msg) -> Sub msg


port todoUpdated : (Bool -> msg) -> Sub msg
