module Decoders.TextOverlayDecoderTest exposing (..)

import Expect
import Json.Decode exposing (decodeString)
import Main exposing (OverlayContent(..), textOverlayDecoder)
import String.Interpolate exposing (interpolate)
import Test exposing (..)


suite : Test
suite =
    describe "textOverlayDecoder"
        [ test "maps to a Text overlay" <|
            \_ ->
                let
                    text =
                        "some text content"

                    json_ =
                        """
                        { "text": "{0}" }
                        """

                    json =
                        interpolate json_ [ text ]
                in
                decodeString textOverlayDecoder json
                    |> Expect.equal
                        (Ok (Text text))
        ]
