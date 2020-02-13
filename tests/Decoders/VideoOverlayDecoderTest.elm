module Decoders.VideoOverlayDecoderTest exposing (..)

import Expect
import Json.Decode exposing (decodeString)
import Main exposing (OverlayContent(..), videoOverlayDecoder)
import String.Interpolate exposing (interpolate)
import Test exposing (..)


suite : Test
suite =
    describe "textOverlayDecoder"
        [ test "maps to a Video overlay" <|
            \_ ->
                let
                    url =
                        "https://www.example.com/video.mp4"

                    json_ =
                        """
                        { "url": "{0}" }
                        """

                    json =
                        interpolate json_ [ url ]
                in
                decodeString videoOverlayDecoder json
                    |> Expect.equal
                        (Ok (Video url))
        ]
