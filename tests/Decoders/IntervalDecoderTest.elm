module Decoders.IntervalDecoderTest exposing (..)

import Expect exposing (Expectation)
import Interval exposing (Interval)
import Json.Decode exposing (decodeString)
import Json.Encode as E
import Main exposing (intervalDecoder)
import Test exposing (..)


suite : Test
suite =
    describe "intervalDecoder" <|
        [ test "decodes an formatted interval into an Interval Int" <|
            \_ ->
                let
                    json =
                        """
                        "22|44"
                        """
                in
                decodeString intervalDecoder json
                    |> Expect.equal
                        (Ok (Interval.from 22 44))
        ]
