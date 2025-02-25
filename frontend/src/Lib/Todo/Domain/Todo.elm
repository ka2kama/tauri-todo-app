module Lib.Todo.Domain.Todo exposing
    ( Todo
    , TodoId
    , create
    , markAsCompleted
    , markAsUncompleted
    , updateTitle
    )


type alias TodoId =
    Int


type alias Todo =
    { id : TodoId
    , title : String
    , completed : Bool
    }


create : TodoId -> String -> Todo
create id title =
    { id = id
    , title = title
    , completed = False
    }


markAsCompleted : Todo -> Todo
markAsCompleted todo =
    { todo | completed = True }


markAsUncompleted : Todo -> Todo
markAsUncompleted todo =
    { todo | completed = False }


updateTitle : String -> Todo -> Todo
updateTitle newTitle todo =
    { todo | title = newTitle }
