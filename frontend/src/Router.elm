module Router exposing
    ( Page(..)
    , Route
    , fromUrl
    , parser
    , toString
    )

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Page
    = HomePage
    | AboutPage
    | TodoPage
    | CounterPage


type alias Route =
    { page : Page
    }


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map { page = HomePage } Parser.top
        , Parser.map { page = AboutPage } (Parser.s "about")
        , Parser.map { page = TodoPage } (Parser.s "todo")
        , Parser.map { page = CounterPage } (Parser.s "counter")
        ]


fromUrl : Url -> Route
fromUrl url =
    Parser.parse parser url
        |> Maybe.withDefault { page = HomePage }


toString : Route -> String
toString route =
    case route.page of
        HomePage ->
            "/"

        AboutPage ->
            "/about"

        TodoPage ->
            "/todo"

        CounterPage ->
            "/counter"
