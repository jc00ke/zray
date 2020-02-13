module Decoders.OverlayDecoderTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (string)
import Interval
import Json.Decode exposing (decodeValue)
import Json.Encode as E
import Main exposing (OverlayContent(..), overlayDecoder)
import Test exposing (..)


suite : Test
suite =
    skip <|
        describe "Decoders"
            [ describe "overlayDecoder"
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
