module DecodersTest exposing (..)
--import Expect exposing (Expectation)
--import Fuzz exposing (Fuzzer, int, list, string)
--import Interval exposing (Interval)
--import Json.Decode exposing (decodeValue)
--import Json.Encode as E
import Test exposing (..)
suite : Test
suite =
    skip <|
    describe "text overlay decoder"
--[ fuzz4 int int string string "textOverlayDecoder maps to a textOverlay" <|
--\start length buttonText content ->
--let
--end =
--start + length
--interval =
--String.fromInt start ++ "-" ++ String.fromInt end
--json =
--E.object
--[ "interval" E.string interval
--, "buttonText" E.string buttonText
--, "content" E.string content
--]
--in
--decodeValue textOverlayDecoder json
--|> Expect.equal
--(Ok
--{ interval = Interval.from start end
--, buttonText = buttonText
--, content = content
--}
--)
--]


module Main exposing (..)
