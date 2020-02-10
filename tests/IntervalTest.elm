module IntervalTest exposing (..)

import Expect
import Fuzz exposing (Fuzzer, int, list, string)
import Interval exposing (Interval)
import Main exposing (formattedStringToIntInterval)
import Test exposing (..)


suite : Test
suite =
    describe "formattedStringToIntInterval"
        [ fuzz2 int int "formattedStringToIntInterval parses 'M-N' and returns Interval M N" <|
            \m length ->
                let
                    n =
                        m + length

                    s =
                        String.fromInt m ++ "|" ++ String.fromInt n
                in
                formattedStringToIntInterval s
                    |> Expect.equal
                        (Interval.from
                            m
                            n
                        )
        ]
