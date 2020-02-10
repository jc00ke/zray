module DecodersTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (string)
import Interval exposing (Interval)
import Json.Decode exposing (decodeValue)
import Json.Encode as E
import Main exposing (OverlayContent(..), intervalDecoder, overlayDecoder, textOverlayDecoder)
import Test exposing (..)


suite : Test
suite =
    describe "Decoders"
        [ describe "intervalDecoder" <|
            [ test "decodes an formatted interval into an Interval Int" <|
                \_ ->
                    let
                        json =
                            E.string "22|44"
                    in
                    decodeValue intervalDecoder json
                        |> Expect.equal
                            (Ok (Interval.from 22 44))
            ]
        , describe "textOverlayDecoder"
            [ fuzz string "maps to a textOverlay" <|
                \text ->
                    let
                        json =
                            E.string text
                    in
                    decodeValue textOverlayDecoder json
                        |> Expect.equal
                            (Ok (Text text))
            ]
        , describe "overlayDecoder"
            [ fuzz2 string string "maps to an overlay" <|
                \buttonText content ->
                    let
                        interval =
                            "1|4"

                        json =
                            E.object
                                [ ( "interval", E.string interval )
                                , ( "buttonText", E.string buttonText )
                                , ( "overlay"
                                  , E.object
                                        [ ( "type", E.string "text" )
                                        , ( "content", E.string content )
                                        ]
                                  )
                                ]
                    in
                    decodeValue overlayDecoder json
                        |> Expect.equal
                            (Ok
                                { interval = Interval.from 1 4
                                , buttonText = buttonText
                                , content = Text content
                                }
                            )
            ]
        ]
