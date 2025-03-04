module Router exposing
    ( Page(..)
    , Route
    , fromUrl
    , parser
    , toPath
    )

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Page
    = HomePage
    | AboutPage
    | TodoPage
    | CounterPage
    | ChartsPage


type alias Route =
    { page : Page
    }


parser : Parser (Page -> a) a
parser =
    Parser.oneOf
        [ Parser.map HomePage Parser.top
        , Parser.map AboutPage (Parser.s "about")
        , Parser.map TodoPage (Parser.s "todo")
        , Parser.map CounterPage (Parser.s "counter")
        , Parser.map ChartsPage (Parser.s "charts")
        ]


fromUrl : Url -> Page
fromUrl url =
    Parser.parse parser url
        |> Maybe.withDefault HomePage


toPath : Page -> String
toPath page =
    case page of
        HomePage ->
            "/"

        AboutPage ->
            "/about"

        TodoPage ->
            "/todo"

        CounterPage ->
            "/counter"

        ChartsPage ->
            "/charts"
