port module Ports exposing
    ( addTodo
    , counterSaved
    , deleteTodo
    , getTodos
    , loadedCounter
    , saveCounter
    , todoAdded
    , todoDeleted
    , todoUpdated
    , todosLoaded
    , updateTodo
    )

-- Counter ports


port saveCounter : Int -> Cmd msg


port counterSaved : (Bool -> msg) -> Sub msg


port loadedCounter : (Int -> msg) -> Sub msg



-- Todo ports


port getTodos : () -> Cmd msg


port addTodo : String -> Cmd msg


port deleteTodo : Int -> Cmd msg


port updateTodo : { id : Int, title : String, completed : Bool } -> Cmd msg


port todosLoaded : (List { id : Int, title : String, completed : Bool } -> msg) -> Sub msg


port todoAdded : (Bool -> msg) -> Sub msg


port todoDeleted : (Bool -> msg) -> Sub msg


port todoUpdated : (Bool -> msg) -> Sub msg
