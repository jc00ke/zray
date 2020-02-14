module Decoders.FlagsDecoderTest exposing (..)

import Expect exposing (Expectation)
import Interval
import Json.Decode exposing (decodeString)
import Main exposing (OverlayContent(..), flagsDecoder)
import String.Interpolate exposing (interpolate)
import Test exposing (..)


suite : Test
suite =
    describe "flagsDecoder"
        [ test "maps text to flags" <|
            \_ ->
                let
                    url =
                        "https://example.com/main.mp4"

                    length =
                        50

                    json_ =
                        """
                        {
                            "mainVideoUrl": "{0}",
                            "videoLength": {1},
                            "overlays": []
                        }
                        """

                    json =
                        interpolate json_ [ url, length ]
                in
                decodeString flagsDecoder json
                    |> Expect.equal
                        (Ok
                            { mainVideoUrl = url
                            , videoLength = length
                            , overlays = []
                            }
                        )
        ]
