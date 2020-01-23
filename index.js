import { MediaApp } from "./mediaApp.js"
import { Elm } from "./src/Main.elm"

(function() {
  let elmApp = Elm.Main.init({
    node: document.getElementById("video")
  });

  elmApp.ports.outbound.subscribe(MediaApp.portHandler);
})()
