module RouterTest exposing (..)

import Expect
import Router exposing (Page(..), fromUrl, toPath)
import Test exposing (..)
import Url


createTestUrl : String -> Url.Url
createTestUrl path =
    Url.fromString ("http://localhost:1234" ++ path)
        |> Maybe.withDefault
            (Url.Url Url.Http "localhost" (Just 1234) "/" Nothing Nothing)


suite : Test
suite =
    describe "Router"
        [ describe "URL to Route"
            (let
                testCases =
                    [ ( "/", HomePage, "root path" )
                    , ( "/about", AboutPage, "about page" )
                    , ( "/todo", TodoPage, "todo page" )
                    , ( "/counter", CounterPage, "counter page" )
                    , ( "/charts", ChartsPage, "charts page" )
                    , ( "/unknown", HomePage, "unknown path" )
                    ]
             in
             List.map
                (\( path, expectedPage, description ) ->
                    test ("maps " ++ description ++ " correctly") <|
                        \_ ->
                            createTestUrl path
                                |> fromUrl
                                |> Expect.equal expectedPage
                )
                testCases
            )
        , describe "Route to String"
            (let
                testCases =
                    [ ( HomePage, "/", "home route" )
                    , ( AboutPage, "/about", "about route" )
                    , ( TodoPage, "/todo", "todo route" )
                    , ( CounterPage, "/counter", "counter route" )
                    , ( ChartsPage, "/charts", "charts route" )
                    ]
             in
             List.map
                (\( route, expectedPath, description ) ->
                    test ("converts " ++ description ++ " correctly") <|
                        \_ ->
                            toPath route
                                |> Expect.equal expectedPath
                )
                testCases
            )
        ]
